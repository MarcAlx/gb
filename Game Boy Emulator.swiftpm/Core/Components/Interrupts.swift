public enum InterruptFlag : Byte {
    case VBlank  = 0b0000_0001
    case LCDStat = 0b0000_0010
    case Timer   = 0b0000_0100
    case Serial  = 0b0000_1000
    case Joypad  = 0b0001_0000
}

/// Interrupts controller
///
/// i.e: an interrupt is raised if IME is true AND enabled (by code/game) via IE AND flagged at runtime (by PPU) via IF
///    for LCDStat on top of these conditions some bits must be set (by code/game) to true in LCD_STATUS (4 cases may trigger LCDStat : LYeqLYC, HBlank, VBLANK, OAM)
class Interrupts: Component {
    public static let sharedInstance:Interrupts = Interrupts()
    
    private let mmu:MMU = MMU.sharedInstance
    
    /// Interrupts Master Enable
    public var IME:Bool {
        get {
            return self.masterEnable
        }
        set {
            self.masterEnable = newValue
        }
    }
    
    /// Interrupt Enabled, stores in its 5 lsb which interrupts are enabled
    public var IE:Byte  {
        get {
            return self.mmu[MMUAddresses.INTERRUPT_ENABLE_REGISTER.rawValue]
        }
        set {
            self.mmu[MMUAddresses.INTERRUPT_ENABLE_REGISTER.rawValue] = newValue
        }
    }
    
    /// Interrupt Flagged, stores in its 5 lsb which interrupts are flagged (ready to fire)
    public var IF:Byte {
        get {
            return self.mmu[MMUAddresses.INTERRUPT_FLAG_REGISTER.rawValue]
        }
        set {
            self.mmu[MMUAddresses.INTERRUPT_FLAG_REGISTER.rawValue] = newValue
        }
    }
    
    /// if false no interrupt can occur
    private var masterEnable:Bool = true
    
    private init() {
    }
    
    public func reset() {
        self.masterEnable = true
        self.IE = 0x00
        self.IF = 0xE1
    }
    
    /// set interrrupt enabled value
    public func setInterruptEnableValue(_ interrupt:InterruptFlag, _ enable:Bool) {
        self.IE = enable ? self.IE | interrupt.rawValue
                         : self.IE & ~interrupt.rawValue;
    }
    
    /// set interrrupt flagged value
    public func setInterruptFlagValue(_ interrupt:InterruptFlag, _ enable:Bool) {
        self.IF = enable ? self.IF | interrupt.rawValue
                         : self.IF & ~interrupt.rawValue;
    }
    
    /// true if interrupt is enabled
    public func isInterruptEnabled(_ interrupt:InterruptFlag) -> Bool {
        return (self.IE & interrupt.rawValue) > 0
    }
    
    ///true if interrupt is flagged
    public func isInterruptFlagged(_ interrupt:InterruptFlag) -> Bool {
        return (self.IF & interrupt.rawValue) > 0
    }
}
