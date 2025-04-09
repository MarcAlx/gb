import Foundation

public enum LCDStatMode: UInt8 {
    case HBLANK         = 0b0000_0000
    case VBLANK         = 0b0000_0001
    case OAM_SEARCH     = 0b0000_0010
    case PIXEL_TRANSFER = 0b0000_0011
}

/// Pixel Processing Unit
public class PPU: Component, Clockable {
    /// white frame, for init and debug purpose
    private static let blankFrame:Data = Data(repeating: 0xFF, count: GBConstants.PixelCount*4)//color are stored with 4 components rgba
    
    private let mmu:MMU
    private let ios:LCDInterface
    private let interrupts:InterruptsControlInterface
    private let pManager:PaletteManager
    
    public private(set) var cycles:Int = 0
    
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
    
    init(mmu:MMU, pm:PaletteManager) {
        self.mmu = mmu
        self.ios = mmu
        self.interrupts = mmu
        self.pManager = pm
        self.prepareNextFrame()
    }
    
    public func reset() {
        self.cycles = 0
        self.frameSync = 0
        self.lineSync = 0
        self.windowLineCounter = 0
        self._frameBuffer = pManager.currentEmptyFrame
    }
    
    public func flush(){
        self.nextFrame = PPU.blankFrame
        self.commitFrame()
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
        mmu.LY = ly
        
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
            
            //update LCD STATUS -> mode
            ios.writeLCDStatMode(newMode)
        }
        
        //operate at 4 t cycles speed as it's 1m cycle (minimal)
        self.frameSync = self.frameSync &+ GBConstants.MCycleLength
        self.cycles = self.cycles &+ GBConstants.MCycleLength
    }
    
    /// scan LY line then render to frame buffer
    /// rendering by line is needed as game usually update drawing between lines to produce special effects
    private func scanline() -> Void {
        //current line
        let ly = ios.LY
        //tile width
        let tw = GBConstants.TileWidth
        //destination y
        let desty:Byte = ly
        
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
            //viewport y
            let vpy:Byte = (ly &+ scy) //avoid overflow and ensure horizontal wrap arround (all bg not only screen)
            //palette for bg and win
            let bgWinPalette = ColorPalette(paletteData: ios.LCD_BGP, reference: pManager.currentPalette)
            
            //draw BG / WIN
            
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
            //read obj size to determine tile size (based on lcdc)
            let useLargeTile = ios.readLCDControlFlag(.OBJ_SIZE)
            //identify obj tile height
            let th = useLargeTile ? GBConstants.LargeTileHeight : GBConstants.StandardTileHeight
            //tiles to consider for line
            let tiles = self.listObjTilesByDrawingOrder(line: ly, withHeight: th)
            //pre-fetch obj palettes
            let obp0 = ios.LCD_OBP0
            let obp1 = ios.LCD_OBP1
            
            //for each tile (horizontal priority is handled by previous ordering)
            for tile in tiles {
                //obj palette considering obj palette flag
                let objPalette = ColorPalette(paletteData: tile.useObjPalette1 ? obp1 : obp0,
                                              reference: pManager.currentPalette)
                
                //tile line considering y flip flag
                let tileLine = Byte(tile.isYFlipped ? Int(th) - (Int(ly) - tile.viewportYPos) - 1
                                                    : Int(ly) - tile.viewportYPos)
                
                //tile index in case of large tile is precedent even number (clear Bit_0 to acheive it)
                let tileIndex = useLargeTile ? clear(.Bit_0, tile.tileIndex) : tile.tileIndex;
                
                //tile address is linear following tile index
                let tileAddress:Short = self.getAddressAt(index: Short(tileIndex) * Short(GBConstants.TileLength),
                                                          range: MMUAddressSpaces.OBJ_TILE_DATA_AREA)
                //each obj tile has 2 bytes per line
                let lineAddr = tileAddress + Short(tileLine * 2)
                
                //effective tile pos considering offset
                let effectivex:Byte = Byte(tile.viewportXPos)
                
                //identify nb bits to draw with overflowing screen width
                let nbBitsToDraw = min(Byte(GBConstants.ScreenWidth) - effectivex , tw)
                
                //loop through tile bits to draw
                for curBit in 0...(nbBitsToDraw-1)
                {
                    //destx is absolute to tile pos
                    let destx:Byte = effectivex + curBit
                    
                    //pixel of tile is not below BG/WIN and above a Color 0 pixel -> draw
                    if(!tile.isBelowBGWIN || self.bgWinColorIndexes[Int(destx)][Int(desty)] == 0)
                    {
                        //tile bit considering x flip flag (condition inversed as msb represents left most pixel)
                        let tileBit = tile.isXFlipped ? curBit : tw - curBit - 1
                        
                        //decode color using the two bytes (b1, b2) of the tile line that contains the pixel to draw (at)
                        let (colorIndex, effectiveColor) = self.decodeColor(palette: objPalette,
                                                                            b1: self.mmu.read(address: lineAddr),
                                                                            b2: self.mmu.read(address: lineAddr+1),
                                                                            at: IntToByteMask[Int(tileBit)])
                        //color 0 for a tile means transparent (do not draw)
                        if(colorIndex != 0){
                            //draw pixel
                            self.drawPixelAt(x: destx, y: desty, withColor: effectiveColor)
                        }
                    }
                }
            }
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
        let dest:Int = (((Int(y) * GBConstants.ScreenWidth) + Int(x)) * 4)
        
        //draw color to frame buffer
        self.nextFrame[dest]   = withColor.r //r
        self.nextFrame[dest+1] = withColor.g //g
        self.nextFrame[dest+2] = withColor.b //b
        self.nextFrame[dest+3] = 0xFF        //a
    }
    
    ///lists obj tiles:
    /// - on screen for a give line
    /// - considering a tile height (8 or 16)
    /// - ordered by drawing priority
    ///
    /// n.b as DMG can only displays 10 tiles, this func won't return more than 10 items
    private func listObjTilesByDrawingOrder(line:Byte,withHeight:Byte) -> [ObjectAttributes] {
        var res:[ObjectAttributes] = []
        var curOAMAddress:Short = MMUAddresses.OBJECT_ATTRIBUTE_MEMORY.rawValue
        //walkthrough OAM, under obj limit per line
        while(curOAMAddress < MMUAddresses.OBJECT_ATTRIBUTE_MEMORY_END.rawValue && res.count < GBConstants.ObjLimitPerLine){
            //identify tile range
            let start = Int(curOAMAddress)
            let end = Int(curOAMAddress+GBConstants.ObjTileInfoSize)
            //decode tile
            let tileInfo = ObjectAttributes(curOAMAddress, Array(self.mmu.directRead(range: start...end)))
            //check visibility
            if(tileInfo.isVerticallyVisible(onLine: line, withHeight: withHeight)){
                res.append(tileInfo)
            }
            //move to next tile info
            curOAMAddress += GBConstants.ObjTileInfoSize
        }
        
        //keep only onscreen tiles (n.b offscreen tiles count in the 10 obj per line limit, so not filtered before)
        res = res.filter { obj in obj.isHorizontallyVisible() }
        
        //sorted by drawing priority
        return res.sorted {//returns true if $0 should be before $1
            if($0.xPos == $1.xPos){
                return $0.OamAddress > $1.OamAddress
            }
            else {
                return $0.xPos > $1.xPos
            }
            
            //n.b the lower the x the later to be drawn (as lower x has more priority)
            //    otherwise the lower OAM address the later to be drawn (as lower address has more priority)
        }
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
