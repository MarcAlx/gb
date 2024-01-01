import Foundation

enum LCDStatMode: UInt8 {
    case HBLANK         = 0b0000_0000
    case VBLANK         = 0b0000_0001
    case OAM_SEARCH     = 0b0000_0010
    case PIXEL_TRANSFER = 0b0000_0011
}

/// Pixel Processing Unit
class PPU: Component, Clockable {
    public static let sharedInstance = PPU()
    
    private let cpu:CPU = CPU.sharedInstance
    private let mmu:MMU = MMU.sharedInstance
    private let ios:IOInterface = IOInterface.sharedInstance
    private let interrupts:Interrupts = Interrupts.sharedInstance
    private let pManager:PaletteManager = PaletteManager.sharedInstance
    
    private (set) var cycles:Int = 0
    
    private var _frameBuffer:Data = PPU.generateBlankFrame()
    // last commited frame, ready to display
    public var frameBuffer:Data {
        get {
            //return a copy to avoid concurrent access
            return Data(self._frameBuffer)
        }
    }
    
    //next frame to be drawn (currently built by render scanline)
    private var nextFrame:Data = PPU.generateBlankFrame()
    
    private init() {
    }
    
    public func reset() {
        self._frameBuffer = PPU.generateBlankFrame()
    }
    
    /// true if a new line is being drawn
    private var newLine:Bool = true
    private var _currentScanlineTiming:Int = 0
    // to track where we are in term of scanline rendering
    var currentScanlineTiming:Int {
        get {
            return self._currentScanlineTiming
        }
        set {
            self.newLine = (newValue == ScanlineRenderingLength)
            if(self.newLine) {
                self._currentScanlineTiming = 0
            }
            else {
                self._currentScanlineTiming = newValue
            }
        }
    }
    
    func tick(_ masterCycles:Int, _ frameCycles:Int) -> Void {
        
        if(self.cycles > masterCycles) {
            return
        }
        
        //LCD disabled, do nothing
        if(!ios.readLCDControlFlag(LCDControlMask.LCD_AND_PPU_ENABLE)){
            self.currentScanlineTiming = 0
            ios.LY = 0
            self.cycles = 0
            ios.writeLCDStatMode(.HBLANK) // reset to mode 0
            return
        }
        
        // if true stat interrupt will be Flagged (fired)
        var statInterruptTriggered:Bool = false
        //lcd stat mode
        let curMode:LCDStatMode = ios.readLCDStatMode()
        var newMode:LCDStatMode = curMode
        
        //all scanline have been rendered we are now in VBLANK
        if(ScreenHeight <= ios.LY) {
            newMode = LCDStatMode.VBLANK
            //trigger stat interrupt if VBlank LCDStatus bit is set
            statInterruptTriggered = ios.readLCDStatusFlag(.VBlankInterruptSource)
            //yes there's two VBlank interrupt sources (STAT and VBLANK)
        }
        //OAM hasn't finish
        else if(self.currentScanlineTiming < PPUTimings.OAM_SEARCH_LENGTH.rawValue) {
            newMode = LCDStatMode.OAM_SEARCH
            //trigger stat interrupt if OAM LCDStatus bit is set
            statInterruptTriggered = ios.readLCDStatusFlag(.OAMInterruptSource)
        }
        //PIXEL RENDER hasn't finish
        else if(self.currentScanlineTiming < PPUTimings.PIXEL_RENDER_LENGTH.rawValue) {
            //print(self.currentScanlineTiming)
            newMode = LCDStatMode.PIXEL_TRANSFER
            if(curMode.rawValue != newMode.rawValue) {
                self.scanline()
            }
        }
        //HBLANK hasn't finish
        else if(self.currentScanlineTiming < PPUTimings.HBLANK_LENGTH.rawValue) {
            newMode = LCDStatMode.HBLANK
            //trigger stat interrupt if HBLANK LCDStatus bit is set
            statInterruptTriggered = ios.readLCDStatusFlag(.HBlankInterruptSource)
        }
        
        // LY === LYC is constantly checked
        if(ios.LY == ios.LYC) {
            //trigger stat interrupt if LYeqLYC LCDStatus bit is set
            statInterruptTriggered = statInterruptTriggered ||  ios.readLCDStatusFlag(.LYCeqLYInterruptSource)
            ios.setLCDStatFlag(.LYCeqLY, enabled: true)
        }
        else {
            ios.setLCDStatFlag(.LYCeqLY, enabled: false)
        }
        
        //update LY
        if(self.newLine) {
            ios.LY += 1 // circularity of LY is handled in ios
            //trigger VBlank
            if(ScreenHeight==ly){
                self.interrupts.setInterruptFlagValue(.VBlank,true);
            }
        }
        
        //Trigger LCD STAT
        if(curMode != newMode) {
            self.interrupts.setInterruptFlagValue(.LCDStat, statInterruptTriggered)
        }
        
        //update LCD STATUS -> mode
        ios.writeLCDStatMode(newMode)
        
        //operate at 4 m cycles speed as it's 1t cycle (minimal)
        self.currentScanlineTiming += 4
        self.cycles = self.cycles &+ 4
    }
    
    /// scan LY line then render to frame buffer
    /// rendering by line is needed as game usually update drawing between lines to produce special effects
    private func scanline() -> Void {
        
        let ly  = ios.LY
        let tw  = TileWidth
        
        //BG an WINDOW are enabled
        if(ios.readLCDControlFlag(.BG_AND_WINDOW_ENABLE))
        {
            let scx = ios.SCX
            let scy = ios.SCY
            let effectiveY:Int = Int(ly) + Int(scy)
            let bgWinPalette = ColorPalette(paletteData: ios.LCD_BGP, reference: pManager.currentPalette)
            
            //draw BG
            
            //tile map contains which tile to use, tile data is where effective tile are stored
            
            //tile data to use for BG and WIN
            let tileDataFlag = ios.readLCDControlFlag(.BG_AND_WINDOW_TILE_DATA_AREA)
            let tiledata = tileDataFlag ? MMUAddressSpaces.BG_WINDOW_TILE_DATA_AREA_1 : MMUAddressSpaces.BG_WINDOW_TILE_DATA_AREA_0
            //tile map to use
            let bgTileMap = ios.readLCDControlFlag(.BG_TILE_MAP_AREA) ? MMUAddressSpaces.BG_TILE_MAP_AREA_1 : MMUAddressSpaces.BG_TILE_MAP_AREA_0
            
            //tile row considering viewport
            let tileRow = UInt8(effectiveY / 8)
            var offsetX:UInt8 = scx
            //x drawn without considering viewport
            var effectiveX = scx
            
            //for each tile in BG
            for vpx in stride(from: UInt8(0), to: UInt8(ScreenWidth), by: UInt8.Stride(tw)) {
                //tile column considering view port
                let tileCol = UInt8((Int(vpx) + Int(scx)) / 8)
                
                //index of tile in BG, (inline 2d array indexing), x32 -> tilemap are 32x32 square
                let index:UInt16 = (32 * UInt16(tileRow)) + UInt16(tileCol)
                
                //get tile index in tile map (value at indexed address in tile map)
                let tileIndex:Byte = mmu.read(address: self.getAddressAt(index: index,
                                                                         range: bgTileMap))
                
                //depending on tileDataFlag, tileindex must be considered as a signed Int8 or a Byte
                let effectiveTileIndex:Byte = tileDataFlag ? tileIndex : Byte(128 + Int(Int8(bitPattern: tileIndex)))
                
                //get tile starting address from tile index
                let tileAddress:Short = self.getAddressAt(index: UInt16(effectiveTileIndex) * UInt16(TileLength),
                                                          range: tiledata)
                
                //draw tile line
                let tileLine:UInt8 = UInt8(effectiveY % Int(tw))
                self.drawTileLine(tileAddress: tileAddress,
                                  withPalette: bgWinPalette,
                                  tileLine: tileLine,
                                  startX: vpx,
                                  startY: ly,
                                  offsetX: offsetX % tw,
                                  stopX: (vpx+tw != ScreenWidth) ? 0 : scx % tw)
                
                //reset offsetX after first use
                offsetX = 0
                
                //update effectiveX
                effectiveX += tw
            }
            
            if(ios.readLCDControlFlag(.WINDOW_ENABLE)) {
                //TODO draw Win
            }
        }
        
        //OBJ are enabled
        if(ios.readLCDControlFlag(.OBJ_ENABLE)) {
            //TODO draw OBJ
        }
    }
    
    
    /// from a range (of addresses) return address at index, e.g range=0x8000...0x9000, index=4 -> 0x8004
    private func getAddressAt(index:UInt16,range:ClosedRange<Short>) -> UInt16{
        return range.lowerBound+index
    }
    
    /// draw tileLine from tile at tileAddress) withPalette into framebuffer at (startX, startY)
    /// tile can be limited from start via offsetX or from end via stopX
    private func drawTileLine(tileAddress:Short, withPalette:ColorPalette, tileLine:UInt8, startX:UInt8, startY:UInt8, offsetX:UInt8 = 0, stopX:UInt8 = 0) {
        //each tile is 8x8, encoded on 16 bytes, 2 bytes per line
        let lineAddr = tileAddress + Short(tileLine * 2)
        //get two bytes of line to draw
        let byte1:Byte = self.mmu.read(address: lineAddr)
        let byte2:Byte = self.mmu.read(address: lineAddr+1)
        
        //inline 2d array indexy, *4 as each color is indexed with 4 values (rgba)
        var dest:Int = (((Int(startY) * ScreenWidth) + Int(startX)) * 4) //substracted to ScreenHeight as data are drawn in swift from bottom to top
        
        //from msb to lsb
        for col in stride(from: Int(TileWidth-offsetX-1), to: Int(stopX)-1, by: -1) {
            //decode each color
            var color = 0
            if(isBitSet(IntToByteMask[col], byte1)) {
                color += 1
            }
            if(isBitSet(IntToByteMask[col], byte2)) {
                color += 2
            }
            let effectiveColor = withPalette[color]
            
            //TODO decoding color in func
            
            //draw color to frame buffer
            self.nextFrame[dest]   = effectiveColor[0] //r
            self.nextFrame[dest+1] = effectiveColor[1] //g
            self.nextFrame[dest+2] = effectiveColor[2] //b
            self.nextFrame[dest+3] = 0xFF              //a
            
            //move dest by the number of component written
            dest += 4
        }
    }
    
    /// generate a random frame, for debug purpose
    private func generateRandomFrameBuffer() -> Data {
        return Data(stride(from: 0, to: PixelCount, by: 1).flatMap {
            _ in
            return [
                UInt8(drand48() * 255), // red
                UInt8(drand48() * 255), // green
                UInt8(drand48() * 255), // blue
                UInt8(255)              // alpha
            ]
        })
    }
    
    /// generate a blank frame, for debug purpose
    private static func generateBlankFrame() -> Data {
        return Data(stride(from: 0, to: PixelCount, by: 1).flatMap {
            _ in return [255,255,255,255]//R,G,B,A
        })
    }
    
    /// set frame as ready to use
    public func commitFrame() {
        //self._frameBuffer = self.generateRandomFrameBuffer()
        self._frameBuffer = self.nextFrame
    }
}
