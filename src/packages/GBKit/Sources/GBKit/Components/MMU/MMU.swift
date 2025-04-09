/**
 * MMU core implementation
 */
public class MMU: MMUCore, InterruptsControlInterface,
                           LCDInterface,
                           TimerInterface,
                           JoyPadInterface,
                           AudioInterface {
    
    private var masterEnable:Bool = true
    
    public override func reset() {
        super.reset()
        
        //interrups
        self.masterEnable = true
        self.IE = 0x00
        self.IF = 0xE1
        
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
    
    // fill MMU with initial value
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
    
    public var LYC:Byte {
        get {
            return self.read(address: IOAddresses.LCD_LYC.rawValue)
        }
    }
    
    public var LY:Byte {
        get {
            return self.read(address: IOAddresses.LCD_LY.rawValue)
        }
        set {
            //LY should be between 0 and ScanLinesPerFrame-1
            self[IOAddresses.LCD_LY.rawValue] = newValue % UInt8(GBConstants.ScanlinesPerFrame)
        }
    }
    
    public var SCX:Byte {
        get {
            return self.read(address: IOAddresses.LCD_SCX.rawValue)
        }
    }
    
    public var SCY:Byte {
        get {
            return self.read(address: IOAddresses.LCD_SCY.rawValue)
        }
    }
    
    public var WX:Byte {
        get {
            return self.read(address: IOAddresses.LCD_WX.rawValue)
        }
    }
    
    public var WY:Byte {
        get {
            return self.read(address: IOAddresses.LCD_WY.rawValue)
        }
    }
    
    public var LCD_BGP:Byte {
        get {
            return self.read(address: IOAddresses.LCD_BGP.rawValue)
        }
    }
    
    public var LCD_OBP0:Byte {
        get {
            return self.read(address: IOAddresses.LCD_OBP0.rawValue)
        }
    }
    
    public var LCD_OBP1:Byte {
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
    
    public var DIV: Byte {
        get {
            return self.read(address: IOAddresses.DIV.rawValue)
        }
    }
    
    public var TMA: Byte {
        get {
            return self.read(address: IOAddresses.TMA.rawValue)
        }
    }
    
    public var TIMA: Byte {
        get {
            return self.read(address: IOAddresses.TIMA.rawValue)
        }
        set {
            self.write(address: IOAddresses.TIMA.rawValue, val: newValue)
        }
    }
    
    public var TAC: Byte {
        get {
            return self.read(address: IOAddresses.TAC.rawValue)
        }
    }
    
    // mark: JoypadInterface
    
    public var DPAD_STATE: Byte {
        get {
            return self.dpadState
        }
        set {
            self.dpadState = newValue
        }
    }
    
    public var BUTTONS_STATE: Byte {
        get {
            return self.buttonsState
        }
        set {
            self.buttonsState = newValue
        }
    }
    
    // mark: AudioInterface
    
    public func setAudioState(_ enabled: Bool) {
        let state = enabled ? self[IOAddresses.AUDIO_NR52.rawValue] | ByteMask.Bit_7.rawValue
                            : self[IOAddresses.AUDIO_NR52.rawValue] & NegativeByteMask.Bit_7.rawValue
        self.write(address: IOAddresses.AUDIO_NR52.rawValue, val: state)
    }

    public func isAudioEnabled() -> Bool {
        return isBitSet(ByteMask.Bit_7, self[IOAddresses.AUDIO_NR52.rawValue])
    }
    
    public func getDutyPattern(_ channel:DutyAudioChannelId) -> Byte {
        //only upper 2 bits of NR{1|2}1 (then shifted get value 0, 1, 2, 3)
        return (self[GBConstants.WaveDutyRegisters[channel.rawValue]] & 0b1100_0000) >> 6
    }
    
    public func getPeriod(_ channel:ChannelWithPeriodId) -> Short {
        //extract 16bits starting from NR{1|2|3}3 (thus overlaping NR{1|2|3}4)
        let val:Short = self.read(address: GBConstants.PeriodRegisters[channel.rawValue])
        //keep 3bits of NR{1|2|3}4 and 8bits of NR{1|2|3}3
        return val & 0b00000111_11111111
    }
    
    public func setPeriod(_ channel: DutyAudioChannelId, _ val:Short) {
        self.write(address: GBConstants.PeriodRegisters[channel.rawValue], val: val)
    }
    
    public func getLengthTimer(_ channel:AudioChannelId) -> Int {
        return self.lengthTimers[channel.rawValue]
    }

    public func resetLengthTimer(_ channel:AudioChannelId) {
        self.lengthTimers[channel.rawValue] = GBConstants.DefaultLengthTimer[channel.rawValue]
    }
    
    public func decrementLengthTimer(_ channel:AudioChannelId) {
        self.lengthTimers[channel.rawValue] -= 1
    }
    
    public func isLengthEnabled(_ channel:AudioChannelId) -> Bool {
        return isBitSet(ByteMask.Bit_6, self[GBConstants.AudioChannelControlRegisters[channel.rawValue]])
    }
    
    public func isTriggered(_ channel:AudioChannelId) -> Bool {
       return isBitSet(ByteMask.Bit_7, self[GBConstants.AudioChannelControlRegisters[channel.rawValue]])
    }
    
    public func resetTrigger(_ channel:AudioChannelId) {
        let addr:Short = GBConstants.AudioChannelControlRegisters[channel.rawValue]
        //clear trigger bit
        self[addr] = self[addr] & NegativeByteMask.Bit_7.rawValue
    }
    
    public func setAudioChannelState(_ channel:AudioChannelId, enabled:Bool) {
        let actualValue = self[IOAddresses.AUDIO_NR52.rawValue];
        let newVal:Byte = enabled ? actualValue |  (1 << channel.rawValue) //set concerned bit to 1
                                  : actualValue & ~(1 << channel.rawValue) //keep every bits but concerned one
        self[IOAddresses.AUDIO_NR52.rawValue] = newVal
    }
    
    ///returns enveloppe direction, 0 -> Descreasing, 1-> Increasing
    public func getEnvelopeDirection(_ channel:EnveloppableAudioChannelId) -> Byte {
        return (self[GBConstants.EnvelopeControlRegisters[channel.rawValue]] & 0b0000_1000) >> 3;
    }
    
    ///returns enveloppe pace, every each enveloppe tick of this value enveloppe is applied
    public func getEnvelopeSweepPace(_ channel:EnveloppableAudioChannelId) -> Byte {
        return self[GBConstants.EnvelopeControlRegisters[channel.rawValue]] & 0b0000_0111;
    }
    
    ///returns enveloppe pace, every each enveloppe tick of this value enveloppe is applied
    public func getEnvelopeInitialVolume(_ channel:EnveloppableAudioChannelId) -> Byte {
        return (self[GBConstants.EnvelopeControlRegisters[channel.rawValue]] & 0b1111_0000) >> 4;
    }
    
    public func getSweepPace() -> Byte {
        return (self[IOAddresses.AUDIO_NR10.rawValue] & 0b0111_0000) >> 4
    }
    
    public func getSweepDirection() -> Byte {
        return (self[IOAddresses.AUDIO_NR10.rawValue] & 0b0000_1000) >> 3
    }
    
    public func getSweepStep() -> Byte {
        return (self[IOAddresses.AUDIO_NR10.rawValue] & 0b0000_0111)
    }
    
    public func getWaveOutputLevel() -> Byte {
        return (self[IOAddresses.AUDIO_NR32.rawValue] & 0b0110_0000) >> 5
    }
    
    public func getNoiseClockShift() -> Byte {
        return (self[IOAddresses.AUDIO_NR43.rawValue] & 0b1111_0000) >> 4
    }
    
    public func hasNoiseShortWidth() -> Bool {
        //if bit 3 of NR43 is set then noise has short width
        return (self[IOAddresses.AUDIO_NR43.rawValue] & 0b0000_1000 >> 3) > 0
    }
    
    public func getNoiseClockDivisor() -> Int {
        let divisorCode:Int = (Int(self[IOAddresses.AUDIO_NR43.rawValue]) & 0b0000_0111)
        return GBConstants.APUNoiseDivisor[divisorCode]
    }
    
    public func getAPUChannelPanning() -> (CH4_L:Bool,
                                           CH3_L:Bool,
                                           CH2_L:Bool,
                                           CH1_L:Bool,
                                           CH4_R:Bool,
                                           CH3_R:Bool,
                                           CH2_R:Bool,
                                           CH1_R:Bool) {
        var panning = self[IOAddresses.AUDIO_NR51.rawValue];
        return (CH4_L: panning & 0b1000_0000 > 0,
                CH3_L: panning & 0b0100_0000 > 0,
                CH2_L: panning & 0b0010_0000 > 0,
                CH1_L: panning & 0b0001_0000 > 0,
                CH4_R: panning & 0b0000_1000 > 0,
                CH3_R: panning & 0b0000_0100 > 0,
                CH2_R: panning & 0b0000_0010 > 0,
                CH1_R: panning & 0b0000_0001 > 0)
    }
    
    public func getMasterVolume() -> (L:Byte, R:Byte) {
        var master = self[IOAddresses.AUDIO_NR50.rawValue];
        return (L:(master & 0b0111_0000) >> 4,
                R:(master & 0b0000_0111))
    }
    
    public func getVINPanning() -> (L:Bool, R:Bool) {
        var master = self[IOAddresses.AUDIO_NR50.rawValue];
        return (L:(master & 0b1000_0000) > 0,
                R:(master & 0b0000_1000) > 0)
    }
}
