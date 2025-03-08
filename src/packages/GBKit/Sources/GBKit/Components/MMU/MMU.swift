/**
 * MMU core implementation
 */
public class MMU: MMUCore, InterruptsControlInterface, IOInterface, TimerInterface {
    private var masterEnable:Bool = true
    
    public override func reset() {
        super.reset()
        
        //interrups
        self.masterEnable = true
        self.IE = 0x00
        self.IF = 0xE1
        
        //io interface
        self.fillWithInitialValues()
    }
    
    // mark: InterruptsControlInterface
    
    public var IME:Bool {
        get {
            return self.masterEnable
        }
        set {
            self.masterEnable = newValue
        }
    }
    
    public var IE:Byte  {
        get {
            return self[MMUAddresses.INTERRUPT_ENABLE_REGISTER.rawValue]
        }
        set {
            self[MMUAddresses.INTERRUPT_ENABLE_REGISTER.rawValue] = newValue
        }
    }
    
    public var IF:Byte {
        get {
            return self[MMUAddresses.INTERRUPT_FLAG_REGISTER.rawValue]
        }
        set {
            self[MMUAddresses.INTERRUPT_FLAG_REGISTER.rawValue] = newValue
        }
    }
    
    public func setInterruptEnableValue(_ interrupt:InterruptFlag, _ enable:Bool) {
        self.IE = enable ? self.IE | interrupt.rawValue
                         : self.IE & ~interrupt.rawValue;
    }
    
    public func setInterruptFlagValue(_ interrupt:InterruptFlag, _ enable:Bool) {
        self.IF = enable ? self.IF | interrupt.rawValue
                         : self.IF & ~interrupt.rawValue;
    }
    
    public func isInterruptEnabled(_ interrupt:InterruptFlag) -> Bool {
        return (self.IE & interrupt.rawValue) > 0
    }
    
    public func isInterruptFlagged(_ interrupt:InterruptFlag) -> Bool {
        return (self.IF & interrupt.rawValue) > 0
    }
    
    // mark: IOInterface
    
    public func fillWithInitialValues() {
        //@see https://gbdev.io/pandocs/Power_Up_Sequence.html (DMG)
        self.directWrite(address: IOAddresses.JOYPAD_INPUT.rawValue, val: Byte(0xCF))
        self.directWrite(address: IOAddresses.SERIAL_TRANSFER_SB.rawValue, val: Byte(0x00))
        self.directWrite(address: IOAddresses.SERIAL_TRANSFER_SC.rawValue, val: Byte(0x7E))
        self.directWrite(address: IOAddresses.DIV.rawValue, val: Byte(0xAB))
        self.directWrite(address: IOAddresses.TIMA.rawValue, val: Byte(0x00))
        self.directWrite(address: IOAddresses.TMA.rawValue, val: Byte(0x00))
        self.directWrite(address: IOAddresses.TAC.rawValue, val: Byte(0xF8))
        self.directWrite(address: IOAddresses.AUDIO_NR10.rawValue, val: Byte(0x80))
        self.directWrite(address: IOAddresses.AUDIO_NR11.rawValue, val: Byte(0xBF))
        self.directWrite(address: IOAddresses.AUDIO_NR12.rawValue, val: Byte(0xF3))
        self.directWrite(address: IOAddresses.AUDIO_NR13.rawValue, val: Byte(0xFF))
        self.directWrite(address: IOAddresses.AUDIO_NR14.rawValue, val: Byte(0xBF))
        self.directWrite(address: IOAddresses.AUDIO_NR21.rawValue, val: Byte(0x3F))
        self.directWrite(address: IOAddresses.AUDIO_NR22.rawValue, val: Byte(0x00))
        self.directWrite(address: IOAddresses.AUDIO_NR23.rawValue, val: Byte(0xFF))
        self.directWrite(address: IOAddresses.AUDIO_NR24.rawValue, val: Byte(0xBF))
        self.directWrite(address: IOAddresses.AUDIO_NR30.rawValue, val: Byte(0x7F))
        self.directWrite(address: IOAddresses.AUDIO_NR31.rawValue, val: Byte(0xFF))
        self.directWrite(address: IOAddresses.AUDIO_NR32.rawValue, val: Byte(0x9F))
        self.directWrite(address: IOAddresses.AUDIO_NR33.rawValue, val: Byte(0xFF))
        self.directWrite(address: IOAddresses.AUDIO_NR34.rawValue, val: Byte(0xBF))
        self.directWrite(address: IOAddresses.AUDIO_NR41.rawValue, val: Byte(0xFF))
        self.directWrite(address: IOAddresses.AUDIO_NR42.rawValue, val: Byte(0x00))
        self.directWrite(address: IOAddresses.AUDIO_NR43.rawValue, val: Byte(0x00))
        self.directWrite(address: IOAddresses.AUDIO_NR44.rawValue, val: Byte(0xBF))
        self.directWrite(address: IOAddresses.AUDIO_NR50.rawValue, val: Byte(0x77))
        self.directWrite(address: IOAddresses.AUDIO_NR51.rawValue, val: Byte(0xF3))
        self.directWrite(address: IOAddresses.AUDIO_NR52.rawValue, val: Byte(0xF1))
        self.directWrite(address: IOAddresses.LCD_CONTROL.rawValue, val: Byte(0x91))
        self.directWrite(address: IOAddresses.LCD_STATUS.rawValue,  val: Byte(0x85))
        self.directWrite(address: IOAddresses.LCD_SCY.rawValue,     val: Byte(0x00))
        self.directWrite(address: IOAddresses.LCD_SCX.rawValue,     val: Byte(0x00))
        self.directWrite(address: IOAddresses.LCD_LY.rawValue,      val: Byte(0x00))
        self.directWrite(address: IOAddresses.LCD_LYC.rawValue,     val: Byte(0x00))
        self.directWrite(address: IOAddresses.LCD_DMA.rawValue,     val: Byte(0xFF))
        self.directWrite(address: IOAddresses.LCD_BGP.rawValue,     val: Byte(0xFC))
        self.directWrite(address: IOAddresses.LCD_OBP0.rawValue,    val: Byte(0x00))
        self.directWrite(address: IOAddresses.LCD_OBP1.rawValue,    val: Byte(0x00))
        self.directWrite(address: IOAddresses.LCD_WX.rawValue,      val: Byte(0x00))
        self.directWrite(address: IOAddresses.LCD_WY.rawValue,      val: Byte(0x00))
    }
    
    public func readLCDStatFlag(_ flag:LCDStatMask) -> Bool {
        return (self.directRead(address: IOAddresses.LCD_STATUS.rawValue) & flag.rawValue) > 0
    }
    
    public func setLCDStatFlag(_ flag:LCDStatMask, enabled:Bool) {
        let cur:Byte = self.read(address: IOAddresses.LCD_STATUS.rawValue)
        let val:Byte = enabled ? cur | flag.rawValue : cur & ~flag.rawValue
        self.directWrite(address: IOAddresses.LCD_STATUS.rawValue, val: val)
    }
    
    public func readLCDStatMode() -> LCDStatMode {
        return LCDStatMode(rawValue: self.directRead(address: IOAddresses.LCD_STATUS.rawValue) & LCDStatMask.Mode.rawValue)!
    }
    
    public func writeLCDStatMode(_ mode:LCDStatMode) {
        let cur:Byte = self.read(address: IOAddresses.LCD_STATUS.rawValue)
        let val:Byte = (cur & ~LCDStatMask.Mode.rawValue) | mode.rawValue
        self.directWrite(address: IOAddresses.LCD_STATUS.rawValue, val: val)
    }
    
    public func readLCDControlFlag(_ flag:LCDControlMask) -> Bool {
        let val:Byte = self.read(address: IOAddresses.LCD_CONTROL.rawValue)
        return ((val) & flag.rawValue) > 0
    }
    
    public func setLCDControlFlag(_ flag:LCDControlMask, enabled:Bool) {
        let cur:Byte = self.read(address: IOAddresses.LCD_CONTROL.rawValue)
        let val:Byte = enabled ? cur | flag.rawValue : cur & ~flag.rawValue
        self.write(address: IOAddresses.LCD_CONTROL.rawValue, val: val)
    }
    
    public var LYC:UInt8 {
        get {
            return self.read(address: IOAddresses.LCD_LYC.rawValue)
        }
    }
    
    public var LY:UInt8 {
        get {
            return self.read(address: IOAddresses.LCD_LY.rawValue)
        }
        set {
            //LY should be between 0 and ScanLinesPerFrame-1
            self[IOAddresses.LCD_LY.rawValue] = newValue % UInt8(GBConstants.ScanlinesPerFrame)
        }
    }
    
    public var SCX:UInt8 {
        get {
            return self.read(address: IOAddresses.LCD_SCX.rawValue)
        }
    }
    
    public var SCY:UInt8 {
        get {
            return self.read(address: IOAddresses.LCD_SCY.rawValue)
        }
    }
    
    public var WX:UInt8 {
        get {
            return self.read(address: IOAddresses.LCD_WX.rawValue)
        }
    }
    
    public var WY:UInt8 {
        get {
            return self.read(address: IOAddresses.LCD_WY.rawValue)
        }
    }
    
    public var LCD_BGP:UInt8 {
        get {
            return self.read(address: IOAddresses.LCD_BGP.rawValue)
        }
    }
    
    public var LCD_OBP0:UInt8 {
        get {
            return self.read(address: IOAddresses.LCD_OBP0.rawValue)
        }
    }
    
    public var LCD_OBP1:UInt8 {
        get {
            return self.read(address: IOAddresses.LCD_OBP1.rawValue)
        }
    }
    
    override func onLYCSet(_ newVal: Byte)
    {
        //on lyc set check flag
        self.setLCDStatFlag(.LYCeqLY, enabled: newVal == self[IOAddresses.LCD_LY.rawValue])
    }
    
    // mark: TimerInterface
    
    public var DIV: UInt8 {
        get {
            return self.read(address: IOAddresses.DIV.rawValue)
        }
    }
    
    public var TMA: UInt8 {
        get {
            return self.read(address: IOAddresses.TMA.rawValue)
        }
    }
    
    public var TIMA: UInt8 {
        get {
            return self.read(address: IOAddresses.TIMA.rawValue)
        }
        set {
            self.write(address: IOAddresses.TIMA.rawValue, val: newValue)
        }
    }
    
    public var TAC: UInt8 {
        get {
            return self.read(address: IOAddresses.TAC.rawValue)
        }
    }
}
