public enum InterruptFlag : Byte {
    case VBlank  = 0b0000_0001
    case LCDStat = 0b0000_0010
    case Timer   = 0b0000_0100
    case Serial  = 0b0000_1000
    case Joypad  = 0b0001_0000
}

/// Interrupts controller
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
    
    /// Interrupt Enabled
    public var IE:Byte  {
        /*get {
            return self.enabledInterrupts
        }
        set {
            self.enabledInterrupts = newValue
        }*/
        get {
            return self.mmu[MMUAddresses.INTERRUPT_ENABLE_REGISTER.rawValue]
        }
        set {
            self.mmu[MMUAddresses.INTERRUPT_ENABLE_REGISTER.rawValue] = newValue
        }
    }
    
    /// Interrupt Flagged
    public var IF:Byte {
        get {
            return self.mmu[MMUAddresses.INTERRUPT_FLAG_REGISTER.rawValue]
        }
        set {
            self.mmu[MMUAddresses.INTERRUPT_FLAG_REGISTER.rawValue] = newValue
        }
        /*get {
            return self.flaggedInterrupts
        }
        set {
            self.flaggedInterrupts = newValue
        }*/
    }
    
    /// if false no interrupt can occur
    private var masterEnable:Bool = true
    ///stores in its 5 lsb which interrupts are flagged (ready to fire)
    public private(set) var flaggedInterrupts:Byte = 0
    ///stores in its 5 lsb which interrupts are enabled
    public private(set) var enabledInterrupts:Byte = 0
    
    private init() {
    }
    
    public func reset() {
        self.masterEnable = true
        self.enabledInterrupts = 0x00
        self.flaggedInterrupts = 0xE1
    }
    
    /// set interrrupt enabled value
    public func setInterruptEnableValue(_ interrupt:InterruptFlag, _ enable:Bool) {
        let res:Byte = enable ? self.enabledInterrupts | interrupt.rawValue : self.enabledInterrupts & ~interrupt.rawValue;
        self.IE = res
    }
    
    /// set interrrupt flagged value
    public func setInterruptFlagValue(_ interrupt:InterruptFlag, _ enable:Bool) {
        let res:Byte = enable ? self.IF | interrupt.rawValue : self.IF & ~interrupt.rawValue;
        self.IF = res
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
