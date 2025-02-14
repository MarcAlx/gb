public enum LCDStatMask: UInt8 {
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

public enum LCDControlMask: UInt8 {
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
public protocol IOInterface {
    /// fill ios with initial values, as bootrom would set it
    func fillWithInitialValues()
    
    /// read LCD stat corresponding flag
    func readLCDStatFlag(_ flag:LCDStatMask) -> Bool
    
    /// enable or disable corresponding LCD stat flag
    func setLCDStatFlag(_ flag:LCDStatMask, enabled:Bool)
    
    /// read lcd stat mode
    func readLCDStatMode() -> LCDStatMode
    
    /// set lcd stat mode
    func writeLCDStatMode(_ mode:LCDStatMode)
    
    /// read LCDControl corresponding flag
    func readLCDControlFlag(_ flag:LCDControlMask) -> Bool
    
    /// enable or disable corresponding LCD control flag
    func setLCDControlFlag(_ flag:LCDControlMask, enabled:Bool)
    
    /// ease access to LYC
    var LYC:UInt8 { get }
    
    /// ease access to LY
    var LY:UInt8 { get set }
    
    /// ease access to SCX
    var SCX:UInt8 { get }
    
    /// ease access to SCY
    var SCY:UInt8 { get }
    
    /// ease access to WX
    var WX:UInt8 { get }
    
    /// ease access to WY
    var WY:UInt8 { get }
    
    /// ease access to LCD_BGP
    var LCD_BGP:UInt8 { get }
    
    /// ease access to LCD_OBP0
    var LCD_OBP0:UInt8 { get }
    
    /// ease access to LCD_OBP1
    var LCD_OBP1:UInt8 { get }
}
