/**
 * CPU raisable flags
 */
public enum CPUFlag: Byte {
    case ZERO       =  0b1000_0000
    case NEGATIVE   =  0b0100_0000
    case HALF_CARRY =  0b0010_0000
    case CARRY      =  0b0001_0000
}

class Registers: Component,Describable {
    private let mmu:MMU
    
    private var _AF:EnhancedShort = EnhancedShort()
    
    //accumulator
    public var A:Byte { get { return self._AF.msb } set { self._AF.msb = newValue} }
    //flags
    public var F:Byte { get { return self._AF.lsb } set { self._AF.lsb = newValue & 0xF0 } }
    public var AF:Short { get { return self._AF.value } set { self._AF.value = newValue & 0xFFF0 } }
    
    private var _BC:EnhancedShort = EnhancedShort()
    public var B:Byte { get { return self._BC.msb } set { self._BC.msb = newValue} }
    public var C:Byte { get { return self._BC.lsb } set { self._BC.lsb = newValue} }
    public var BC:Short { get { return self._BC.value } set { self._BC.value = newValue } }
    
    private var _DE:EnhancedShort = EnhancedShort()
    public var D:Byte { get { return self._DE.msb } set { self._DE.msb = newValue} }
    public var E:Byte { get { return self._DE.lsb } set { self._DE.lsb = newValue} }
    public var DE:Short { get { return self._DE.value } set { self._DE.value = newValue } }
    
    private var _HL:EnhancedShort = EnhancedShort()
    public var H:Byte { get { return self._HL.msb } set { self._HL.msb = newValue} }
    public var L:Byte { get { return self._HL.lsb } set { self._HL.lsb = newValue} }
    public var HL:Short { get { return self._HL.value } set { self._HL.value = newValue } }
    
    public var SP:Short = 0
    public var PC:Short = 0
    
    public init(mmu: MMU){
        self.mmu = mmu
        self.reset()
    }
    
    ///set a flag to 1
    public func raiseFlag(_ flag:CPUFlag) {
        self.F |= flag.rawValue
    }
    
    /// raise flags
    public func raiseFlags(_ flags:CPUFlag...) {
        for flag in flags {
            self.raiseFlag(flag)
        }
    }
    
    ///set a flag to 0
    public func clearFlag(_ flag:CPUFlag) {
        self.F &= ~flag.rawValue
    }
    
    /// clear flags
    public func clearFlags(_ flags:CPUFlag...) {
        for flag in flags {
            self.clearFlag(flag)
        }
    }
    
    ///true if given flag is set
    public func isFlagSet(_ flag:CPUFlag) -> Bool {
        return (self.F & flag.rawValue) > 0
    }
    
    //true if flag is clear
    public func isFlagCleared(_ flag:CPUFlag) -> Bool {
        return (self.F & flag.rawValue) == 0
    }
    
    /// raise or clear flag on condition
    public func conditionalSet(cond:Bool, flag:CPUFlag) {
        cond ? self.raiseFlag(flag) : self.clearFlag(flag)
    }
    
    func reset() {
        //same as DMG, @see: https://gbdev.io/pandocs/Power_Up_Sequence.html
        self.A = 0x01
        self.F = 0b1000_0000//ony Z set
        self.B = 0x00
        self.C = 0x13
        self.D = 0x00
        self.E = 0xD8
        self.H = 0x01
        self.L = 0x4D
        self.PC = UInt16(CHAddresses.ENTRY_POINT.rawValue)
        self.SP = 0xFFFE
    }
    
    public func describe() -> String {
        return String(format: "A:%02X F:%02X B:%02X C:%02X D:%02X E:%02X H:%02X L:%02X SP:%04X PC:%04X PCMEM:%02X,%02X,%02X,%02X (z:%d,n:%d,hc:%d,c:%d)",
                      self.A,self.F,self.B,self.C,self.D,self.E,self.H,self.L,
                      self.SP,
                      self.PC,
                      self.mmu[Short(self.PC)],self.mmu[Short(self.PC+1)],self.mmu[Short(self.PC+2)],self.mmu[Short(self.PC+3)],
                      self.isFlagSet(.ZERO),self.isFlagSet(.NEGATIVE),self.isFlagSet(.HALF_CARRY),self.isFlagSet(.CARRY))
    }
}
