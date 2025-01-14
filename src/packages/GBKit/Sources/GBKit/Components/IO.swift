enum LCDStatMask: UInt8 {
    //bit 6
    case LYCeqLYInterruptSource = 0b0100_0000
    //bit 5
    case OAMInterruptSource     = 0b0010_0000
    //bit 4
    case VBlankInterruptSource  = 0b0001_0000
    //bit 3
    case HBlankInterruptSource  = 0b0000_1000
    //bit 2
    case LYCeqLY                = 0b0000_0100
    //bit 1-0
    case Mode                   = 0b0000_0011
}

enum LCDControlMask: UInt8 {
    case LCD_AND_PPU_ENABLE           = 0b1000_0000
    case WINDOW_TILE_AREA             = 0b0100_0000
    case WINDOW_ENABLE                = 0b0010_0000
    case BG_AND_WINDOW_TILE_DATA_AREA = 0b0001_0000
    case BG_TILE_MAP_AREA             = 0b0000_1000
    case OBJ_SIZE                     = 0b0000_0100
    case OBJ_ENABLE                   = 0b0000_0010
    case BG_AND_WINDOW_ENABLE         = 0b0000_0001
}

/// Inputs / Outputs are not really a component, but a set of
/// this class acts as an ease of access to the various memory location their values are stored
class IOInterface: Component {
    public static let sharedInstance = IOInterface()
    
    private let mmu:MMU = MMU.sharedInstance
    
    private init() {
    }
    
    /// fill ios with initial values, as bootrom would set it
    func fillWithInitialValues() {
        //@see https://gbdev.io/pandocs/Power_Up_Sequence.html (DMG)
        mmu.directWrite(address: IOAddresses.JOYPAD_INPUT.rawValue, val: Byte(0xCF))
        mmu.directWrite(address: IOAddresses.SERIAL_TRANSFER_SB.rawValue, val: Byte(0x00))
        mmu.directWrite(address: IOAddresses.SERIAL_TRANSFER_SC.rawValue, val: Byte(0x7E))
        mmu.directWrite(address: IOAddresses.DIV.rawValue, val: Byte(0xAB))
        mmu.directWrite(address: IOAddresses.TIMA.rawValue, val: Byte(0x00))
        mmu.directWrite(address: IOAddresses.TMA.rawValue, val: Byte(0x00))
        mmu.directWrite(address: IOAddresses.TAC.rawValue, val: Byte(0xF8))
        mmu.directWrite(address: IOAddresses.AUDIO_NR10.rawValue, val: Byte(0x80))
        mmu.directWrite(address: IOAddresses.AUDIO_NR11.rawValue, val: Byte(0xBF))
        mmu.directWrite(address: IOAddresses.AUDIO_NR12.rawValue, val: Byte(0xF3))
        mmu.directWrite(address: IOAddresses.AUDIO_NR13.rawValue, val: Byte(0xFF))
        mmu.directWrite(address: IOAddresses.AUDIO_NR14.rawValue, val: Byte(0xBF))
        mmu.directWrite(address: IOAddresses.AUDIO_NR21.rawValue, val: Byte(0x3F))
        mmu.directWrite(address: IOAddresses.AUDIO_NR22.rawValue, val: Byte(0x00))
        mmu.directWrite(address: IOAddresses.AUDIO_NR23.rawValue, val: Byte(0xFF))
        mmu.directWrite(address: IOAddresses.AUDIO_NR24.rawValue, val: Byte(0xBF))
        mmu.directWrite(address: IOAddresses.AUDIO_NR30.rawValue, val: Byte(0x7F))
        mmu.directWrite(address: IOAddresses.AUDIO_NR31.rawValue, val: Byte(0xFF))
        mmu.directWrite(address: IOAddresses.AUDIO_NR32.rawValue, val: Byte(0x9F))
        mmu.directWrite(address: IOAddresses.AUDIO_NR33.rawValue, val: Byte(0xFF))
        mmu.directWrite(address: IOAddresses.AUDIO_NR34.rawValue, val: Byte(0xBF))
        mmu.directWrite(address: IOAddresses.AUDIO_NR41.rawValue, val: Byte(0xFF))
        mmu.directWrite(address: IOAddresses.AUDIO_NR42.rawValue, val: Byte(0x00))
        mmu.directWrite(address: IOAddresses.AUDIO_NR43.rawValue, val: Byte(0x00))
        mmu.directWrite(address: IOAddresses.AUDIO_NR44.rawValue, val: Byte(0xBF))
        mmu.directWrite(address: IOAddresses.AUDIO_NR50.rawValue, val: Byte(0x77))
        mmu.directWrite(address: IOAddresses.AUDIO_NR51.rawValue, val: Byte(0xF3))
        mmu.directWrite(address: IOAddresses.AUDIO_NR52.rawValue, val: Byte(0xF1))
        mmu.directWrite(address: IOAddresses.LCD_CONTROL.rawValue, val: Byte(0x91))
        mmu.directWrite(address: IOAddresses.LCD_STATUS.rawValue,  val: Byte(0x85))
        mmu.directWrite(address: IOAddresses.LCD_SCY.rawValue,     val: Byte(0x00))
        mmu.directWrite(address: IOAddresses.LCD_SCX.rawValue,     val: Byte(0x00))
        mmu.directWrite(address: IOAddresses.LCD_LY.rawValue,      val: Byte(0x00))
        mmu.directWrite(address: IOAddresses.LCD_LYC.rawValue,     val: Byte(0x00))
        mmu.directWrite(address: IOAddresses.LCD_DMA.rawValue,     val: Byte(0xFF))
        mmu.directWrite(address: IOAddresses.LCD_BGP.rawValue,     val: Byte(0xFC))
        mmu.directWrite(address: IOAddresses.LCD_OBP0.rawValue,    val: Byte(0x00))
        mmu.directWrite(address: IOAddresses.LCD_OBP1.rawValue,    val: Byte(0x00))
        mmu.directWrite(address: IOAddresses.LCD_WX.rawValue,      val: Byte(0x00))
        mmu.directWrite(address: IOAddresses.LCD_WY.rawValue,      val: Byte(0x00))
    }
    
    public func reset() {
        self.fillWithInitialValues()
    }
    
    /// read LCD stat corresponding flag
    public func readLCDStatFlag(_ flag:LCDStatMask) -> Bool {
        return (mmu.directRead(address: IOAddresses.LCD_STATUS.rawValue) & flag.rawValue) > 0
    }
    
    /// enable or disable corresponding LCD stat flag
    public func setLCDStatFlag(_ flag:LCDStatMask, enabled:Bool) {
        let cur:Byte = mmu.read(address: IOAddresses.LCD_STATUS.rawValue)
        let val:Byte = enabled ? cur | flag.rawValue : cur & ~flag.rawValue
        mmu.directWrite(address: IOAddresses.LCD_STATUS.rawValue, val: val)
    }
    
    /// read lcd stat mode
    public func readLCDStatMode() -> LCDStatMode {
        return LCDStatMode(rawValue: mmu.directRead(address: IOAddresses.LCD_STATUS.rawValue) & LCDStatMask.Mode.rawValue)!
    }
    
    /// set lcd stat mode
    public func writeLCDStatMode(_ mode:LCDStatMode) {
        let cur:Byte = mmu.read(address: IOAddresses.LCD_STATUS.rawValue)
        let val:Byte = (cur & ~LCDStatMask.Mode.rawValue) | mode.rawValue
        mmu.directWrite(address: IOAddresses.LCD_STATUS.rawValue, val: val)
    }
    
    /// read LCDControl corresponding flag
    public func readLCDControlFlag(_ flag:LCDControlMask) -> Bool {
        let val:Byte = mmu.read(address: IOAddresses.LCD_CONTROL.rawValue)
        return ((val) & flag.rawValue) > 0
    }
    
    /// enable or disable corresponding LCD control flag
    public func setLCDControlFlag(_ flag:LCDControlMask, enabled:Bool) {
        let cur:Byte = mmu.read(address: IOAddresses.LCD_CONTROL.rawValue)
        let val:Byte = enabled ? cur | flag.rawValue : cur & ~flag.rawValue
        mmu.write(address: IOAddresses.LCD_CONTROL.rawValue, val: val)
    }
    
    // ease access to LYC
    public var LYC:UInt8 {
        get {
            return mmu.read(address: IOAddresses.LCD_LYC.rawValue)
        }
    }
    
    // ease access to LY
    public var LY:UInt8 {
        get {
            return mmu.read(address: IOAddresses.LCD_LY.rawValue)
        }
        set {
            //LY should be between 0 and ScanLinesPerFrame-1
            mmu[IOAddresses.LCD_LY.rawValue] = newValue % UInt8(GBConstants.ScanlinesPerFrame)
        }
    }
    
    // ease access to SCX
    public var SCX:UInt8 {
        get {
            return mmu.read(address: IOAddresses.LCD_SCX.rawValue)
        }
    }
    
    // ease access to SCY
    public var SCY:UInt8 {
        get {
            return mmu.read(address: IOAddresses.LCD_SCY.rawValue)
        }
    }
    
    // ease access to WX
    public var WX:UInt8 {
        get {
            return mmu.read(address: IOAddresses.LCD_WX.rawValue)
        }
    }
    
    // ease access to WY
    public var WY:UInt8 {
        get {
            return mmu.read(address: IOAddresses.LCD_WY.rawValue)
        }
    }
    
    // ease access to LCD_BGP
    public var LCD_BGP:UInt8 {
        get {
            return mmu.read(address: IOAddresses.LCD_BGP.rawValue)
        }
    }
    
    // ease access to LCD_OBP0
    public var LCD_OBP0:UInt8 {
        get {
            return mmu.read(address: IOAddresses.LCD_OBP0.rawValue)
        }
    }
    
    // ease access to LCD_OBP1
    public var LCD_OBP1:UInt8 {
        get {
            return mmu.read(address: IOAddresses.LCD_OBP1.rawValue)
        }
    }
}
