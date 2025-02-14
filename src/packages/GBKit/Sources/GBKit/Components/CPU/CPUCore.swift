/**
 * The Gameboy CPU
 */
public class CPUCore: Component {
    internal let mmu:MMU
    internal let interrupts:InterruptsControlInterface
    internal let registers:Registers
    
    public internal(set) var state:CPUState = CPUState.RUNNING
    //cycles this cpu has run
    public internal(set) var cycles:Int = 0
    //if true interrupt can't be handled (are skipped)
    internal var interruptsJustEnabled:Bool = false //@see InstrusctionSet.ei
    
    internal init(mmu:MMU) {
        self.registers = Registers(mmu: mmu)
        self.interrupts = mmu
        self.mmu = mmu
    }
    
    public func reset() {
        self.registers.reset()
        //@see https://gbdev.io/pandocs/Power_Up_Sequence.html
        self.registers.conditionalSet(cond: self.mmu.currentCartridge.headers.headerChecksum != 0x00, flag: .HALF_CARRY)
        self.registers.conditionalSet(cond: self.mmu.currentCartridge.headers.headerChecksum != 0x00, flag: .CARRY)
    }
    
    internal func panic() {
        self.state = CPUState.PANIC
        let pc = self.registers.PC-1//rewind pc
        let opCode = mmu[pc]
        GBErrorService.report(error: errors.unsupportedInstruction(opCode:(false, opCode) ,fountAt:pc))
    }
    
    internal func panic_ext() {
        self.state = CPUState.PANIC
        let pc = self.registers.PC-2//rewind pc, at -2 there's 0xCB, at -1 there's the effective opcode
        let opCode = mmu[self.registers.PC-1]
        GBErrorService.report(error: errors.unsupportedInstruction(opCode:(true, opCode) ,fountAt:pc))
    }
    
    /// - mark : underlaying intructions
    
    /// handle interrupt
    internal func handleInterrupt(_ interrupt:InterruptFlag,_ interruptLoc:Short) {
        //disable flag
        self.interrupts.setInterruptFlagValue(interrupt, false)
        //disable IME
        self.mmu.IME = false
        //handling interupt is: write PC to stack and move PC to associated interrupt address (a call...)
        self.call(interruptLoc)
        //restore cpu state
        self.state = CPUState.RUNNING
        //increments cycles
        self.cycles = self.cycles &+ 20
        //no documentation seems to explicit this timing of 20,
        //let's assume it's a call (24 cycles) without having to fetch opcode (4 cycles) so 24-4=20
    }
    
    /// add val to HL, assign flag and return val
    internal func add_hl(_ val:Short) -> Void {
        let old:Short = val
        let res:Short = self.registers.HL &+ val
        self.registers.clearFlag(.NEGATIVE)
        self.registers.conditionalSet(cond: isAddHalfCarry(self.registers.HL, val), flag: .HALF_CARRY)
        self.registers.conditionalSet(cond: hasOverflown(old, res), flag: .CARRY)
        self.registers.HL = res
    }
    
    /// add val to HL, assign flag and return val
    internal func add_sp(_ val:Short) -> Void {
        let old:Short = val
        let res:Short = self.registers.SP &+ val
        self.registers.clearFlag(.ZERO)
        self.registers.clearFlag(.NEGATIVE)
        self.registers.conditionalSet(cond: isAddHalfCarry(self.registers.SP, Short(val)), flag: .HALF_CARRY)
        self.registers.conditionalSet(cond: hasOverflown(old, res), flag: .CARRY)
        self.registers.SP = res
    }
    
    // add sp + n, assign flags and return result as short, n can be negative
    internal func _add_sp_i8(val:Byte) -> Short {
        let old:Short = self.registers.SP
        let res = add_short_i8(val: old, i8: val)
        
        //carry and half carry are checked over lsb part
        self.registers.conditionalSet(cond: hasOverflown(Byte(0xFF&old), Byte(0xFF&res)), flag: .CARRY)
        self.registers.conditionalSet(cond: isAddHalfCarry(old, val) , flag: .HALF_CARRY)
        
        self.registers.clearFlags(.NEGATIVE,.ZERO)
        return res
    }
    
    /// add val to A
    internal func add_a(_ val:Byte) -> Void {
        let old = val
        let res:Byte = self.registers.A &+ val
        self.registers.conditionalSet(cond: res==0, flag: .ZERO)
        self.registers.clearFlag(.NEGATIVE)
        self.registers.conditionalSet(cond: isAddHalfCarry(self.registers.A, val), flag: .HALF_CARRY)
        self.registers.conditionalSet(cond: hasOverflown(old, res), flag: .CARRY)
        self.registers.A = res
    }
    
    /// add val + carry to A
    internal func adc_a(_ val:Byte) -> Void {
        let carry:Byte = (self.registers.isFlagSet(.CARRY) ? 1 : 0)
        let res:Byte = self.registers.A &+ val &+ carry
        self.registers.conditionalSet(cond: res==0, flag: .ZERO)
        self.registers.clearFlag(.NEGATIVE)
        self.registers.conditionalSet(cond: isAddHalfCarry(val, self.registers.A, carry), flag: .HALF_CARRY)
        //carry if sum is over 255
        self.registers.conditionalSet(cond: isAddCarry(self.registers.A, val, carry), flag: .CARRY)
        self.registers.A = res
    }
    
    /// and val with A then stores result in A
    internal func and_a(_ val:Byte) {
        self.registers.A &= val
        self.registers.conditionalSet(cond: self.registers.A == 0, flag: .ZERO)
        self.registers.raiseFlag(.HALF_CARRY)
        self.registers.clearFlags(.NEGATIVE,.CARRY)
    }
    
    /// compare A with N
    internal func cp_a(_ val:Byte) -> Void {
        self.registers.conditionalSet(cond: self.registers.A == val, flag: .ZERO)
        self.registers.raiseFlag(.NEGATIVE)
        self.registers.conditionalSet(cond: isSubHalfBorrow(self.registers.A, val), flag: .HALF_CARRY)
        self.registers.conditionalSet(cond: self.registers.A < val, flag: .CARRY)
    }
    
    /// decrements val, raises N flag, affects Z, HC flags
    internal func dec(_ val:Byte) -> Byte {
        let res = val &- 1 // to avoid underflow, 0-1 -> 255 instead of error
        self.registers.conditionalSet(cond: isSubHalfBorrow(val, 1), flag: .HALF_CARRY)
        self.registers.conditionalSet(cond: res == 0 , flag: .ZERO)
        self.registers.raiseFlag(.NEGATIVE)
        return res
    }
    
    /// decrements short val (mainly to handle underflow)
    internal func dec(_ val:Short) -> Short {
        return val &- 1 // to avoid underflow, 0-1 -> Short.MaxValue instead of error
    }
    
    /// increments val, raises N flag, affects Z, HC flags
    internal func inc(_ val:Byte) -> Byte {
        let res = val &+ 1 // to avoid overflow, 255+1 -> 0 instead of error
        self.registers.conditionalSet(cond: isAddHalfCarry(val, 1), flag: .HALF_CARRY)
        self.registers.conditionalSet(cond: res == 0 , flag: .ZERO)
        self.registers.clearFlag(.NEGATIVE)
        return res
    }
    
    /// incremens short val (mainly to handle overflow)
    internal func inc(_ val:Short) -> Short {
        return val &+ 1 // to avoid overflow, Short.MaxValue+1 -> 0 instead of error
    }
    
    // deciamal adjust A (BCD)
    internal func _daa() -> Void {
        // basically obtaining DAA consists in :
        // - adding 0x60 if A overflow 0x99
        // - adding 0x06 if lsb of A greater than 0x09
        // for negative don't check overflow, and substract instead
        //
        // DAA is more Binary coded Hex than Binary coded decimal,
        //     each char of the hex reprensentation of a number is encoded in a 4bits nibble
        //
        // ex don't think 32(0x20) as 0b0011_0010 i.e 3(0b0011) 2(0b0010)
        //    think       32(0x20) as 0b0001_0000 i.e 2(0b0001) 0(0b0000)
        //    whereas     50(0x32) is 0b0011_0010 i.e 3(0b0011) 2(0b0010)
        //    where       20(0x14) is 0b0001_0100 i.e 1(0b0001) 4(0b0100)
        
        var raiseCarry = false
        
        if(self.registers.isFlagSet(.NEGATIVE)) // after substraction
        {
            if(self.registers.isFlagSet(.CARRY)){
                self.registers.A = self.registers.A &- 0x60;
                raiseCarry = true
            }
            if(self.registers.isFlagSet(.HALF_CARRY)){
                self.registers.A = self.registers.A &- 0x06;
            }
        }
        else //after addition
        {
            if(self.registers.isFlagSet(.CARRY) || self.registers.A > 0x99){
                self.registers.A = self.registers.A &+ 0x60;
                raiseCarry = true
            }
            if(self.registers.isFlagSet(.HALF_CARRY) || (self.registers.A & 0x0F) > 0x09){
                self.registers.A = self.registers.A &+ 0x06;
            }
        }
        
        //carry raised if positive and above 0x99, or negative with carry
        self.registers.conditionalSet(cond: raiseCarry, flag: .CARRY)
        self.registers.clearFlag(.HALF_CARRY)
        self.registers.conditionalSet(cond: self.registers.A == 0, flag: .ZERO)
    }
    
    /// jump to address, any provided flag is checked in order to conditionnaly jump, (if so a cycle overhead is applied by default 4), if inverseFlag is true flag are checked at inverse
    internal func jumpTo(_ address:EnhancedShort, _ flag:CPUFlag, inverseFlag:Bool = false, _ branchingCycleOverhead:Int = 4) {
        if((!inverseFlag &&  self.registers.isFlagSet(flag))
        ||  (inverseFlag && !self.registers.isFlagSet(flag))) {
            self.jumpTo(address)
            self.cycles += branchingCycleOverhead // jumping with condition implies some extra cycles
        }
        else {
            // all provided flag are not raised, do nothing
        }
    }
    
    /// jump to address
    internal func jumpTo(_ address:EnhancedShort) {
        self.registers.PC = address.value
    }
    
    /// jump relative by val, any provided flag is checked in order to conditionnaly jump, (if so a cycle overhead is applied by default +4)
    internal func jumpRelative(_ val:Byte, _ flag:CPUFlag, inverseFlag:Bool = false, branchingCycleOverhead:Int = 4) {
        let res = add_short_i8(val: self.registers.PC, i8: val)
        //a relative jump is just an absolute jump from PC
        self.jumpTo(EnhancedShort(res), flag, inverseFlag: inverseFlag, branchingCycleOverhead)
    }
    
    /// perform a relative jump
    internal func jumpRelative(_ val:Byte) {
        let delta:Int8 = Int8(bitPattern: val)//delta can be negative, aka two bit complement
        let newPC:Int = Int(self.registers.PC) + Int(delta)
        //a relative jump is just an absolute jump from PC
        self.jumpTo(EnhancedShort(fit(newPC)))
    }
    
    /// call according to condition (flag)
    internal func call(_ address:EnhancedShort, _ flag:CPUFlag, inverseFlag:Bool = false, branchingCycleOverhead:Int = 4) {
        let oldPC = self.registers.PC
        self.jumpTo(address, flag, inverseFlag: inverseFlag, branchingCycleOverhead)
        //branching has succeed write PC
        if(oldPC != self.registers.PC) {
            self.pushToStack(oldPC)
        }
    }
    
    /// save PC to stack then jump to address
    internal func call(_ address: Short) {
        self.call(EnhancedShort(address))
    }
    
    /// save PC to stack then jump to address
    internal func call(_ address: EnhancedShort) {
        self.pushToStack(self.registers.PC)
        self.jumpTo(address)
    }
    
    /// or val with A then stores result in A
    internal func or_a(_ val:Byte){
        self.registers.A |= val
        self.registers.conditionalSet(cond: self.registers.A == 0, flag: .ZERO)
        self.registers.clearFlags(.NEGATIVE,.HALF_CARRY,.CARRY)
    }
    
    /// xor val with A then stores result in A
    internal func xor_a(_ val: Byte) {
        self.registers.A ^= val
        self.registers.conditionalSet(cond: self.registers.A == 0, flag: .ZERO)
        self.registers.clearFlags(.NEGATIVE,.HALF_CARRY,.CARRY)
    }
    
    /// return by taking care of flags, if any flag branching occurs a cycle overhead of +12 is applied
    internal func retrn(_ flag:CPUFlag, inverseFlag:Bool = false) {
        let oldPC = self.registers.PC
        self.jumpTo(EnhancedShort(self.readFromStack()), flag, inverseFlag: inverseFlag, 12)
        if(oldPC != self.registers.PC){
            self.retrn()
        }
    }
    
    /// return by taking care of flags, if any flag branching occurs a cycle overhead of +12 is applied
    internal func retrn() {
        self.registers.PC = self.popFromStack()
    }
    
    /// enable interupt and skip next op
    internal func e_i(_ skipNextOp:Bool = true) -> Void {
        mmu.IME = true
        self.interruptsJustEnabled = skipNextOp
    }
    
    /// left rotate value, if circular msb is put in both lsb and carry flag, else carry flag is put into lsb
    internal func rl(_ val:Byte, circular:Bool = false) -> Byte {
        var res = val << 1
        
        //if rotation is circular, bit 7 is put at bit 0
        if(circular) {
            res |= val >> 7
        }
        //else carry clag is forwarded to bit 0
        else if(self.registers.isFlagSet(.CARRY)) {
            res |= ByteMask.Bit_0.rawValue
        }
        
        self.registers.conditionalSet(cond: res == 0, flag: .ZERO)
        self.registers.clearFlags(.HALF_CARRY,.NEGATIVE)
        self.registers.conditionalSet(cond: isBitSet(.Bit_7, val), flag: .CARRY)
        return res
    }
    
    /// right rotate value, if circular lsb is put in both msb and carry flag, else carry flag is put into msb
    internal func rr(_ val:Byte, circular:Bool = false) -> Byte {
        var res = val >> 1
        
        //if rotation is circular, bit 0 is put at bit 7
        if(circular) {
            res |= val << 7
        }
        //else carry clag is forwarded to bit 7
        else if(self.registers.isFlagSet(.CARRY)) {
            res |= ByteMask.Bit_7.rawValue
        }
        
        self.registers.conditionalSet(cond: res == 0, flag: .ZERO)
        self.registers.clearFlags(.HALF_CARRY,.NEGATIVE)
        self.registers.conditionalSet(cond: isBitSet(.Bit_0, val), flag: .CARRY)
        return res
    }
    
    /// sub val to A
    internal func sub_a(_ val:Byte) -> Void {
        let res:Byte = self.registers.A &- val
        self.registers.conditionalSet(cond: res==0, flag: .ZERO)
        self.registers.raiseFlag(.NEGATIVE)
        self.registers.conditionalSet(cond: isSubHalfBorrow(self.registers.A, val), flag: .HALF_CARRY)
        self.registers.conditionalSet(cond: self.registers.A < val, flag: .CARRY) //
        self.registers.A = res
    }
    
    /// sub val + carry to A
    internal func sbc_a(_ val:Byte) -> Void {
        let carry:Byte = (self.registers.isFlagSet(.CARRY) ? 1 : 0)
        let res:Byte = self.registers.A &- val &- carry
        self.registers.conditionalSet(cond: res==0, flag: .ZERO)
        self.registers.raiseFlag(.NEGATIVE)
        
        //sub borrow
        self.registers.conditionalSet(cond: isSubHalfBorrow(self.registers.A, val, carry), flag: .HALF_CARRY)
        //carry if borrow
        self.registers.conditionalSet(cond: isSubBorrow(self.registers.A, val, carry), flag: .CARRY)
        self.registers.A = res
    }
    
    /// perform an arithemtical shift left of val (same as logical one)
    internal func sla(_ val:Byte) -> Byte {
        return self.sll(val)
    }
    
    /// perform an logical shift left of val (not exposed in 0xCB)
    internal func sll(_ val:Byte) -> Byte {
        let res = val << 1;
        self.registers.conditionalSet(cond: res == 0, flag: .ZERO)
        self.registers.clearFlag(.NEGATIVE)
        self.registers.clearFlag(.HALF_CARRY)
        self.registers.conditionalSet(cond: isBitSet(.Bit_7, val), flag: .CARRY)
        return res;
    }
    
    /// perform an logical shift left of val
    internal func srl(_ val:Byte) -> Byte {
        let res = val >> 1;
        self.registers.conditionalSet(cond: res == 0, flag: .ZERO)
        self.registers.clearFlag(.NEGATIVE)
        self.registers.clearFlag(.HALF_CARRY)
        self.registers.conditionalSet(cond: isBitSet(.Bit_0, val), flag: .CARRY)
        return res;
    }
    
    /// perform an arithmetic shift right of val (same as logical but old 7bit MSB is stored in new 7bit MSB
    internal func sra(_ val:Byte) -> Byte {
        var res = self.srl(val)
        if(isBitSet(.Bit_7, val)){
            res = res | ByteMask.Bit_7.rawValue
        }
        self.registers.conditionalSet(cond: res == 0, flag: .ZERO)
        return res;
    }
    
    /// swap msb and lsb in val
    internal func swap(_ val:Byte) -> Byte {
        self.registers.clearFlags(.CARRY, .HALF_CARRY, .NEGATIVE)
        self.registers.conditionalSet(cond: val == 0, flag: .ZERO) //swapped or not val remains 0
        return swap_lsb_msb(val)
    }
    
    /// test if bit is set in val
    internal func test_bit(_ mask:ByteMask,_ val:Byte) -> Void {
        self.registers.conditionalSet(cond: isBitCleared(mask, val), flag: .ZERO)
        self.registers.clearFlag(.NEGATIVE)
        self.registers.raiseFlag(.HALF_CARRY)
    }
    
    // mark : stack related
    /// read a short from stack
    internal func readFromStack() -> Short {
        return self.mmu.read(address: self.registers.SP)
    }
    
    /// read a byte from stack along with PC increment
    internal func popFromStack() -> Short {
        let res:Short = self.mmu.read(address: self.registers.SP)
        self.registers.SP += 2
        return res
    }
    
    /// write a short to stack along with PC decrements
    internal func pushToStack(_ val:Short) -> Void {
        self.writeToStack(EnhancedShort(val))
    }
    
    /// write a short to stack along with PC decrements
    internal func writeToStack(_ val:EnhancedShort) -> Void {
        self.registers.SP -= 2
        self.mmu.write(address: self.registers.SP, val: val)
    }
}
