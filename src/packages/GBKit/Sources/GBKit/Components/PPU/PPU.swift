import Foundation

enum LCDStatMode: UInt8 {
    case HBLANK         = 0b0000_0000
    case VBLANK         = 0b0000_0001
    case OAM_SEARCH     = 0b0000_0010
    case PIXEL_TRANSFER = 0b0000_0011
}

/// Pixel Processing Unit
public class PPU: Component, Clockable {
    /// white frame, for init and debug purpose
    private static let blankFrame:Data = Data(repeating: 0xFF, count: GBConstants.PixelCount*4)//color are stored with 4 components rgba
    
    public static let sharedInstance = PPU()
    
    private let mmu:MMU = MMU.sharedInstance
    private let ios:IOInterface = IOInterface.sharedInstance
    private let interrupts:Interrupts = Interrupts.sharedInstance
    private let pManager:PaletteManager = PaletteManager.sharedInstance
    
    public private (set) var cycles:Int = 0
    
    private var _frameBuffer:Data = PPU.blankFrame
    /// last commited frame, ready to display
    public var frameBuffer:Data {
        get {
            //return a copy to avoid concurrent access
            return Data(self._frameBuffer)
        }
    }
    
    //next frame to be drawn (currently built by render scanline)
    private var nextFrame:Data = PPU.blankFrame
    
    //stores bg and win color indexes to ease obj priority application
    private var bgWinColorIndexes:[[Int]] = []
    
    private init() {
        self.prepareNextFrame()
    }
    
    public func reset() {
        self.cycles = 0
        self.frameSync = 0
        self.lineSync = 0
        self.windowLineCounter = 0
        self._frameBuffer = pManager.currentEmptyFrame
    }
    
    private var _lineSync:Int = 0
    //current timing of scanline
    private var lineSync:Int {
        get {
            return self._lineSync
        }
        set {
            self._lineSync = newValue % GBConstants.MCyclesPerScanline
        }
    }
    
    private var _frameSync:Int = 0
    //current timing of frame
    private var frameSync:Int {
        get {
            return self._frameSync
        }
        set {
            self._frameSync = newValue % GBConstants.MCyclesPerFrame
        }
    }
    
    ///window has its own line counter
    private var windowLineCounter:Byte = 0
    
    public func tick(_ masterCycles:Int, _ frameCycles:Int) -> Void {
        //LCD disabled, do nothing
        if(!ios.readLCDControlFlag(LCDControlMask.LCD_AND_PPU_ENABLE)){
            self.reset()
            return;
        }
        
        //current timing in line draw
        self.lineSync = self.frameSync % GBConstants.MCyclesPerScanline;
        //set LY
        let ly = UInt8((self.frameSync) / GBConstants.MCyclesPerScanline);
        ios.LY = ly
        
        //lcd stat mode
        let curMode:LCDStatMode = ios.readLCDStatMode()
        var newMode:LCDStatMode = curMode
        // if true stat interrupt will be Flagged (fired)
        var statInterruptTriggered:Bool = false
        
        if(ly >= GBConstants.ScreenHeight)
        {
            newMode = LCDStatMode.VBLANK
            //trigger stat interrupt if VBlank LCDStatus bit is set
            statInterruptTriggered = ios.readLCDStatFlag(.VBlankInterruptSource)
        }
        else if(self.lineSync < GBConstants.PIXEL_RENDER_TRIGGER)
        {
            newMode = LCDStatMode.OAM_SEARCH
            //trigger stat interrupt if OAM LCDStatus bit is set
            statInterruptTriggered = ios.readLCDStatFlag(.OAMInterruptSource)
        }
        else if(self.lineSync < GBConstants.HBLANK_TRIGGER)
        {
            newMode = LCDStatMode.PIXEL_TRANSFER
        }
        else if(self.lineSync < GBConstants.MCyclesPerScanline)
        {
            newMode = LCDStatMode.HBLANK
            //trigger stat interrupt if HBLANK LCDStatus bit is set
            statInterruptTriggered = ios.readLCDStatFlag(.HBlankInterruptSource)
        }
               
        // LY === LYC is constantly checked
        let lyEqLyc = (ly == ios.LYC);
        //trigger stat interrupt if LYeqLYC LCDStatus bit is set
        statInterruptTriggered = statInterruptTriggered || (lyEqLyc && ios.readLCDStatFlag(.LYCeqLYInterruptSource))
        ios.setLCDStatFlag(.LYCeqLY, enabled: lyEqLyc)
        
        //mode has changed
        if(curMode != newMode) {
            //trigger LCD STAT
            self.interrupts.setInterruptFlagValue(.LCDStat, statInterruptTriggered)
            
            //entering pixel transfer -> draw line
            if(newMode == .PIXEL_TRANSFER){
                self.scanline()
            }
            //entering vblank -> trigger
            else if(newMode == .VBLANK){
                //yes there's two VBlank interrupt sources (STAT and VBLANK)
                self.interrupts.setInterruptFlagValue(.VBlank,true);
                //commit frame
                self.commitFrame()
            }
            //entering new frame
            else if(curMode == .VBLANK && newMode == .OAM_SEARCH){
                self.prepareNextFrame()
            }
        }
        
        //update LCD STATUS -> mode
        ios.writeLCDStatMode(newMode)
        
        //operate at 4 m cycles speed as it's 1t cycle (minimal)
        self.frameSync = self.frameSync &+ 4
        self.cycles = self.cycles &+ 4
    }
    
    /// scan LY line then render to frame buffer
    /// rendering by line is needed as game usually update drawing between lines to produce special effects
    private func scanline() -> Void {
        
        let ly = ios.LY
        let tw = GBConstants.TileWidth
        
        //BG an WINDOW are enabled
        if(ios.readLCDControlFlag(.BG_AND_WINDOW_ENABLE))
        {
            //scroll x
            let scx:Byte = ios.SCX
            //scrol y
            let scy:Byte = ios.SCY
            //window x
            let wx:Byte = ios.WX &- GBConstants.WinXOffset
            //window y
            let wy:Byte = ios.WY
            //destination y
            let desty:Byte = ly
            //viewport y
            let vpy:Byte = (ly &+ scy) //avoid overflow and ensure horizontal wrap arround (all bg not only screen)
            //palette for bg and win
            let bgWinPalette = ColorPalette(paletteData: ios.LCD_BGP, reference: pManager.currentPalette)
            
            //draw BG
            
            //tile map contains which tile to use, tile data is where effective tile are stored
            
            //tile data to use for BG and WIN
            let tileDataFlag = ios.readLCDControlFlag(.BG_AND_WINDOW_TILE_DATA_AREA)
            let tiledata = tileDataFlag ? MMUAddressSpaces.BG_WINDOW_TILE_DATA_AREA_1 
                                        : MMUAddressSpaces.BG_WINDOW_TILE_DATA_AREA_0
            //tile maps to use
            let bgTileMap = ios.readLCDControlFlag(.BG_TILE_MAP_AREA) ? MMUAddressSpaces.BG_TILE_MAP_AREA_1
                                                                      : MMUAddressSpaces.BG_TILE_MAP_AREA_0
            let winTileMap = ios.readLCDControlFlag(.WINDOW_TILE_AREA) ? MMUAddressSpaces.WINDOW_TILE_MAP_AREA_1
                                                                       : MMUAddressSpaces.WINDOW_TILE_MAP_AREA_0
            
            //effective tile map (differs between BG/Win)
            var tileMap:ClosedRange<Short>
            //tile column (in tileMap) considering view port
            var tileCol:Byte = 0
            //tile row (in tileMap) considering viewport
            var tileRow:Byte = 0
            //bit in tile line to consider
            var tileBit:Byte = 0
            //line in tile to consider
            var tileLine:Byte = 0
            //line has window ?
            var lineHasWindow = false
            
            //for each pixel in line
            for destx in stride(from:Byte(0), to: Byte(GBConstants.ScreenWidth), by: Byte.Stride(1)){
                //adjust params for window drawing
                if(ios.readLCDControlFlag(.WINDOW_ENABLE) && ly >= wy && destx>=wx) {
                    tileMap = winTileMap
                    tileBit = 7 - ((destx-wx)%tw) //(7 minus value as bits are indexed from msb to lsb)
                    tileLine = self.windowLineCounter % GBConstants.StandardTileHeight
                    tileCol = (destx-wx) / tw
                    tileRow = self.windowLineCounter / GBConstants.StandardTileHeight
                    lineHasWindow = true
                }
                //adjust params for BG drawing
                else {
                    //viewport x
                    let vpx:Byte = (destx &+ scx) // avoid overflow and ensure vertical wrap arround (all bg not only screen)
                    tileMap = bgTileMap
                    tileBit = 7 - (vpx % tw) //(7 minus value as bits are indexed from msb to lsb)
                    tileLine = vpy % GBConstants.StandardTileHeight
                    tileCol = vpx / tw
                    tileRow = vpy / GBConstants.StandardTileHeight
                }
                
                //index of tile in BG, (inline 2d array indexing), x32 -> tilemap are 32x32 square
                let index:Short = (32 * Short(tileRow)) + Short(tileCol)
                
                //get tile index in tile map (value at indexed address in tile map)
                let tileIndex:Byte = mmu.read(address: self.getAddressAt(index: index,
                                                                         range: tileMap))
                
                //depending on tileDataFlag, tileindex must be considered as a signed Int8 or a Byte
                let effectiveTileIndex:Byte = tileDataFlag ? tileIndex : add_byte_i8(val: 128, i8: tileIndex)
                
                //get tile starting address from tile index
                let tileAddress:Short = self.getAddressAt(index: Short(effectiveTileIndex) * Short(GBConstants.TileLength),
                                                          range: tiledata)
                
                //each bg tile is 8x8, encoded on 16 bytes, 2 bytes per line
                let lineAddr = tileAddress + Short(tileLine * 2)
                
                //decode color using the two bytes (b1, b2) of the tile line that contains the pixel to draw (at)
                let (colorIndex, effectiveColor) = self.decodeColor(palette: bgWinPalette,
                                                      b1: self.mmu.read(address: lineAddr),
                                                      b2: self.mmu.read(address: lineAddr+1),
                                                      at: IntToByteMask[Int(tileBit)])
                
                //draw pixel
                self.drawPixelAt(x: destx, y: desty, withColor: effectiveColor)
                
                //store pixel type
                self.bgWinColorIndexes[Int(destx)][Int(desty)] = colorIndex
            }
            
            //update line counter
            if(lineHasWindow){
                self.windowLineCounter += 1
            }
        }
        else {
            //no bg or win, Color 0 should be drawn, see beginFrame that initializes frame with color 0
        }
        
        //OBJ are enabled
        if(ios.readLCDControlFlag(.OBJ_ENABLE)) {
            //identify obj tile height based on lcdc
            let th = ios.readLCDControlFlag(.OBJ_SIZE) ? GBConstants.LargeTileHeight : GBConstants.StandardTileHeight
            
            //TODO draw OBJ
        }
    }
    
    /// from a range (of addresses) return address at index, e.g range=0x8000...0x9000, index=4 -> 0x8004
    private func getAddressAt(index:UInt16,range:ClosedRange<Short>) -> UInt16{
        return range.lowerBound+index
    }
    
    /// from two bytes and a ByteMask identifies color to use from palette
    /// following the bit blending rule the GB uses
    private func decodeColor(palette:ColorPalette, b1:Byte, b2:Byte, at:ByteMask) -> (Int,Color) {
        var color = 0
        if(isBitSet(at, b1)) {
            color += 1
        }
        if(isBitSet(at, b2)) {
            color += 2
        }
        return (color,palette[color])
    }
    
    /// draw color at given x,y
    private func drawPixelAt(x:Byte, y:Byte, withColor:Color) {
        //inline 2d array indexy, *4 as each color is indexed with 4 values (rgba)
        var dest:Int = (((Int(y) * GBConstants.ScreenWidth) + Int(x)) * 4)
        
        //draw color to frame buffer
        self.nextFrame[dest]   = withColor.r //r
        self.nextFrame[dest+1] = withColor.g //g
        self.nextFrame[dest+2] = withColor.b //b
        self.nextFrame[dest+3] = 0xFF        //a
    }
    
    /// generate a random frame, for debug purpose
    private func generateRandomFrameBuffer() -> Data {
        return Data(stride(from: 0, to: GBConstants.PixelCount, by: 1).flatMap {
            _ in
            return [
                UInt8(drand48() * 255), // red
                UInt8(drand48() * 255), // green
                UInt8(drand48() * 255), // blue
                UInt8(255)              // alpha
            ]
        })
    }
    
    //prepare next frame to be drawn
    private func prepareNextFrame() {
        //frame has ended reset window line counter
        self.windowLineCounter = 0
        
        //needed to avoid pixel persistance accross frame generation, fill frame background with color 0
        let bgWinPalette = ColorPalette(paletteData: ios.LCD_BGP, reference: pManager.currentPalette)
        self.nextFrame = Data(stride(from: 0, to: GBConstants.PixelCount, by: 1).flatMap {
            _ in return [bgWinPalette[0].r,bgWinPalette[0].g,bgWinPalette[0].b,255]//R,G,B,A
        })
        
        //fill pixel types with BG_0
        self.bgWinColorIndexes = Array(repeating: Array(repeating: 0, count: GBConstants.ScreenHeight), count: GBConstants.ScreenWidth)
    }
    
    /// set current frame as ready to use
    private func commitFrame() {
        //self._frameBuffer = self.generateRandomFrameBuffer()
        self._frameBuffer = self.nextFrame
    }
}
