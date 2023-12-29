import Foundation

// CPU states
enum CPUState {
    //CPU is running
    case RUNNING
    //CPU is in panic (error case)
    case PANIC
}

/**
 * The Gameboy CPU
 */
class CPU: Component, Clockable, GameBoyInstructionSet {
    public static let sharedInstance = CPU()
    
    private let mmu:MMU = MMU.sharedInstance
    private let interrupts:Interrupts = Interrupts.sharedInstance
    private let instructionDecoder:InstructionDecoder = InstructionDecoder.sharedInstance
    public  let registers:Registers
    
    //cycles this cpu has run
    public private(set) var cycles:Int = 0
    
    public private(set) var state:CPUState = CPUState.RUNNING
    
    //if true interrupt can't be handled (are skipped)
    private var interruptsJustEnabled:Bool = false //@see InstrusctionSet.ei
    
    private init() {
        self.registers = Registers()
        self.instructionDecoder.setup(gbInstructions: self)
    }
    
    public func reset() {
        self.cycles = 0
        self.registers.reset()
        //@see https://gbdev.io/pandocs/Power_Up_Sequence.html
        self.registers.conditionalSet(cond: self.mmu.currentCartridge.headers.headerChecksum != 0x00, flag: .HALF_CARRY)
        self.registers.conditionalSet(cond: self.mmu.currentCartridge.headers.headerChecksum != 0x00, flag: .CARRY)
        self.state = CPUState.RUNNING
    }
    
    public func tick(_ masterCycles:Int) {
        //as cycles are incremented during execute, keep up with motherboard before doing the next instruction
        if(self.cycles > masterCycles) {
            return
        }
        
        if(self.state == CPUState.PANIC) { 
            //do nothing
        }
        else if(self.state == CPUState.RUNNING) {
            //clear this flag, as handleInterrupt will only execute after the next op complete
            self.interruptsJustEnabled = false;
            
            //to ease PC debugging in Xcode
            let pc = self.registers.PC
            //if(pc == 0x01D2){
            //    print("add breakpoint here")
            //}
            
            //fetch
            let op = self.fetch() //on real hardware fetch are done during last 4 cycles of previous instuction, but as cycles are incremented during execute don't care
            
            //decode
            if let instruction = self.instructionDecoder.decode(opCode: op.opCode, isExtended:op.isExtended) {
                //execute
                let duration = self.execute(instruction: instruction)
                //incr cycle count
                self.cycles = self.cycles &+ duration
                //LogService.log(LogCategory.CPU, "# \(self.registers.describe())")
                //LogService.log(LogCategory.CPU, "t \(self.cycles)")
            }
            else {
                self.state = CPUState.PANIC
                ErrorService.report(error: errors.unsupportedInstruction(opCode: op.opCode, isExtended: op.isExtended,fountAt: self.registers.PC-1-(op.isExtended ? 1 : 0)))
            }
        }
    }
    
    /// fetch an opcode from PC
    /// - returns a tuple with a bool that indicates if opcode is extended, and the fetched opcode
    private func fetch() -> (isExtended:Bool, opCode:UInt8) {
        let opCode = self.readIncrPC()
        if opCode == ExtentedInstructionSetOpcode {
            return (true, self.readIncrPC())
        }
        return (false,opCode)
    }
    
    /// execute an instruction and return the cycle it has consumed
    private func execute(instruction:Instruction) -> Int {
        //execute
        switch(instruction.length) {
        case InstructionLength.OneByte:
            //LogService.log(LogCategory.CPU,"; \(instruction.name)")
            instruction.execute()
            break
        case InstructionLength.TwoBytes:
            let arg = self.readIncrPC()
            //LogService.log(LogCategory.CPU,"; \(String(format: instruction.name, arg))")
            instruction.execute(arg)
            break
        case InstructionLength.ThreeBytes:
            let arg = EnhancedShort(self.readIncrPC(), self.readIncrPC())
            //LogService.log(LogCategory.CPU,"; \(String(format: instruction.name, arg.value))")
            instruction.execute(nil/*not sure why it's needed*/,arg)
            break
        }
        return instruction.duration
    }
    
    /// read an increment PC
    private func readIncrPC() -> Byte  {
        let res:Byte = mmu[self.registers.PC]// mmu.read(address: self.registers.PC)
        self.registers.PC = self.registers.PC &+ 1
        return res
    }
    
    /// mark - interrupts handling
    
    /// poll and trigger interrupts by priority
    public func handleInterrupts() {
        //handle interrupt only if not just enabled (cpu should wait one op on ei()), IME, enabled, flagged
        if(!self.interruptsJustEnabled && self.interrupts.IME && self.interrupts.IE > 0 && self.interrupts.IF > 0){
            //check interrupt following IE, IF corresponding bit order, 0 VBLANK -> 4 Joypad
            if(self.interrupts.isInterruptEnabled(.VBlank) && self.interrupts.isInterruptFlagged(.VBlank)){
                self.handleInterrupt(.VBlank, ReservedMemoryLocationAddresses.INTERRUPT_VBLANK.rawValue)
            }
            if(self.interrupts.isInterruptEnabled(.LCDStat) && self.interrupts.isInterruptFlagged(.LCDStat)){
                self.handleInterrupt(.LCDStat, ReservedMemoryLocationAddresses.INTERRUPT_LCD_STAT.rawValue)
            }
            if(self.interrupts.isInterruptEnabled(.Timer) && self.interrupts.isInterruptFlagged(.Timer)){
                self.handleInterrupt(.Timer, ReservedMemoryLocationAddresses.INTERRUPT_JOYPAD.rawValue)
            }
            if(self.interrupts.isInterruptEnabled(.Serial) && self.interrupts.isInterruptFlagged(.Serial)){
                self.handleInterrupt(.Serial, ReservedMemoryLocationAddresses.INTERRUPT_SERIAL.rawValue)
            }
            if(self.interrupts.isInterruptEnabled(.Joypad) && self.interrupts.isInterruptFlagged(.Joypad)){
                self.handleInterrupt(.Joypad, ReservedMemoryLocationAddresses.INTERRUPT_JOYPAD.rawValue)
            }
        }
    }
    
    /// handle interrupt
    private func handleInterrupt(_ interrupt:InterruptFlag,_ interruptLoc:Short) {
        //disable flag
        self.interrupts.setInterruptFlagValue(interrupt, false)
        //disable IME
        self.interrupts.IME = false
        //write PC to stack
        self.writeToStack(self.registers.PC)
        //move PC to associated interrupt address
        self.registers.PC = interruptLoc
    }
    
    /// - mark : underlaying intructions
    
    /// add val to HL, assign flag and return val
    private func add_hl(_ val:Short) -> Void {
        let res:Short = self.registers.HL &+ val
        self.registers.clearFlag(.NEGATIVE)
        self.registers.conditionalSet(cond: isAddHalfCarry(self.registers.HL, val), flag: .HALF_CARRY)
        self.registers.conditionalSet(cond: hasCarry(val, res), flag: .CARRY)
        self.registers.HL = res
    }
    
    /// add val to HL, assign flag and return val
    private func add_sp(_ val:Short) -> Void {
        let res:Short = self.registers.SP &+ val
        self.registers.clearFlag(.ZERO)
        self.registers.clearFlag(.NEGATIVE)
        self.registers.conditionalSet(cond: isAddHalfCarry(self.registers.SP, Short(val)), flag: .HALF_CARRY)
        self.registers.conditionalSet(cond: hasCarry(val, res), flag: .CARRY)
        self.registers.SP = res
    }
    
    /// add val to A
    private func add_a(_ val:Byte) -> Void {
        let res:Byte = self.registers.A &+ val
        self.registers.conditionalSet(cond: res==0, flag: .ZERO)
        self.registers.clearFlag(.NEGATIVE)
        self.registers.conditionalSet(cond: isAddHalfCarry(self.registers.A, val), flag: .HALF_CARRY)
        self.registers.conditionalSet(cond: hasCarry(val, res), flag: .CARRY)
        self.registers.A = res
    }
    
    /// add val + carry to A
    private func adc_a(_ val:Byte) -> Void {
        self.add_a(val &+ (self.registers.isFlagSet(.CARRY) ? 1 : 0))
    }
    
    /// and val with A then stores result in A
    private func and_a(_ val:Byte) {
        self.registers.A &= val
        self.registers.conditionalSet(cond: self.registers.A == 0, flag: .ZERO)
        self.registers.raiseFlag(.HALF_CARRY)
        self.registers.clearFlags(.NEGATIVE,.CARRY)
    }
    
    /// compare A with N
    private func cp_a(_ val:Byte) -> Void {
        self.registers.conditionalSet(cond: self.registers.A == val, flag: .ZERO)
        self.registers.raiseFlag(.NEGATIVE)
        self.registers.conditionalSet(cond: isSubHalfBorrow(self.registers.A, val), flag: .HALF_CARRY)
        self.registers.conditionalSet(cond: self.registers.A < val, flag: .CARRY)
    }
    
    /// decrements val, raises N flag, affects Z, HC flags
    private func dec(_ val:Byte) -> Byte {
        let res = val &- 1 // to avoid underflow, 0-1 -> 255 instead of error
        self.registers.conditionalSet(cond: isSubHalfBorrow(val, 1), flag: .HALF_CARRY)
        self.registers.conditionalSet(cond: res == 0 , flag: .ZERO)
        self.registers.raiseFlag(.NEGATIVE)
        return res
    }
    
    /// decrements short val (mainly to handle underflow)
    private func dec(_ val:Short) -> Short {
        return val &- 1 // to avoid underflow, 0-1 -> Short.MaxValue instead of error
    }
    
    /// increments val, raises N flag, affects Z, HC flags
    private func inc(_ val:Byte) -> Byte {
        let res = val &+ 1 // to avoid overflow, 255+1 -> 0 instead of error
        self.registers.conditionalSet(cond: isAddHalfCarry(val, 1), flag: .HALF_CARRY)
        self.registers.conditionalSet(cond: res == 0 , flag: .ZERO)
        self.registers.clearFlag(.NEGATIVE)
        return res
    }
    
    /// incremens short val (mainly to handle overflow)
    private func inc(_ val:Short) -> Short {
        return val &+ 1 // to avoid overflow, Short.MaxValue+1 -> 0 instead of error
    }
    
    /// jump to address, any provided flag is checked in order to conditionnaly jump, (if so a cycle overhead is applied by default 4), if inverseFlag is true flag are checked at inverse
    private func jumpTo(_ address:EnhancedShort, _ flags:[CPUFlag], _ inverseFlag:Bool = false, _ branchingCycleOverhead:Int = 4) {
        if(flags.isEmpty){
            self.registers.PC = address.value
        }
        else if((!inverseFlag &&  self.registers.areFlagsSet(flags))
             ||   inverseFlag && !self.registers.areFlagsSet(flags)) {
            self.registers.PC = address.value
            self.cycles += branchingCycleOverhead // jumping with condition implies some extra cycles
        }
        else {
            // all provided flag are not raised, do nothing
        }
    }
    
    /// - seealso: jumpTo (overload provided as array splatting is not yet available in swift)
    private func jumpTo(_ address:EnhancedShort, _ flags:CPUFlag..., inverseFlag:Bool = false, branchingCycleOverhead:Int = 4) {
        self.jumpTo(address, flags, inverseFlag, branchingCycleOverhead)
    }
    
    /// jump relative by val, any provided flag is checked in order to conditionnaly jump, (if so a cycle overhead is applied by default +4)
    private func jumpRelative(_ val:Byte, _ flags:CPUFlag..., inverseFlag:Bool = false, branchingCycleOverhead:Int = 4) {
        let delta:Int8 = Int8(bitPattern: val)//delta can be negative, aka two bit complement
        let newPC:Int = Int(self.registers.PC) + Int(delta)
        //a relative jump is just an absolute jump from PC
        self.jumpTo(EnhancedShort(fit(newPC)), flags, inverseFlag, branchingCycleOverhead)
    }
    
    /// call according to condition
    public func call(_ address:EnhancedShort, _ flags:CPUFlag..., inverseFlag:Bool = false, branchingCycleOverhead:Int = 4) {
        let oldPC = self.registers.PC
        self.jumpTo(address, flags, inverseFlag, branchingCycleOverhead)
        //branching has succeed write PC
        if(oldPC != self.registers.PC) {
            self.writeToStack(oldPC)
        }
    }
    
    /// save PC to stack then jump to address
    public func call(_ address: Short) {
        self.writeToStack(self.registers.PC)
        self.registers.PC = address
    }
    
    /// or val with A then stores result in A
    private func or_a(_ val:Byte){
        self.registers.A |= val
        self.registers.conditionalSet(cond: self.registers.A == 0, flag: .ZERO)
        self.registers.clearFlags(.NEGATIVE,.HALF_CARRY,.CARRY)
    }
    
    /// xor val with A then stores result in A
    private func xor_a(_ val: Byte) {
        self.registers.A ^= val
        self.registers.conditionalSet(cond: self.registers.A == 0, flag: .ZERO)
        self.registers.clearFlags(.NEGATIVE,.HALF_CARRY,.CARRY)
    }
    
    /// return by taking care of flags, if any flag branching occurs a cycle overhead of +12 is applied
    private func retrn(_ flags:CPUFlag..., inverseFlag:Bool = false) {
        self.jumpTo(EnhancedShort(self.readFromStack()), flags, inverseFlag, 12)
    }
    
    /// return and enable interrupt, same as RET+EI
    private func ret_i() {
        self.ret()
        self.e_i(false)//reti enable directly
    }
    
    /// enable interupt and skip next op
    private func e_i(_ skipNextOp:Bool = true) -> Void {
        interrupts.IME = true
        self.interruptsJustEnabled = skipNextOp
    }
    
    /// left rotate value, if circular msb is put in both lsb and carry flag, else carry flag is put into lsb
    public func rl(_ val:Byte, circular:Bool = false) -> Byte {
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
        self.registers.conditionalSet(cond: isBitSet(.Bit_0, val), flag: .CARRY)
        return res
    }
    
    /// right rotate value, if circular lsb is put in both msb and carry flag, else carry flag is put into msb
    public func rr(_ val:Byte, circular:Bool = false) -> Byte {
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
    private func sub_a(_ val:Byte) -> Void {
        let res:Byte = self.registers.A &- val
        self.registers.conditionalSet(cond: res==0, flag: .ZERO)
        self.registers.clearFlag(.NEGATIVE)
        self.registers.conditionalSet(cond: isSubHalfBorrow(self.registers.A, val), flag: .HALF_CARRY)
        self.registers.conditionalSet(cond: self.registers.A < val, flag: .CARRY) // 
        self.registers.A = res
    }
    
    /// sub val + carry to A
    private func sbc_a(_ val:Byte) -> Void {
        self.add_a(val &+ (self.registers.isFlagSet(.CARRY) ? 1 : 0))
    }
    
    /// swap msb and lsb in val
    private func swap(_ val:Byte) -> Byte {
        self.registers.clearFlags(.CARRY, .HALF_CARRY, .NEGATIVE)
        self.registers.conditionalSet(cond: val == 0, flag: .ZERO) //swapped or not val remains 0
        return swap_lsb_msb(val)
    }
    
    /// test if bit is set in val
    private func test_bit(_ mask:ByteMask,_ val:Byte) -> Void {
        self.registers.conditionalSet(cond: isBitCleared(mask, val), flag: .ZERO)
        self.registers.clearFlag(.NEGATIVE)
        self.registers.raiseFlag(.HALF_CARRY)
    }
    
    // mark : stack related
    
    /// read a byte from stack along with PC increment
    public func readFromStack() -> Byte {
        self.registers.SP += 1
        let res:Byte = mmu.read(address: self.registers.SP)
        return res
    }
    
    /// read a short from stack along with PC increments
    public func readFromStack() -> Short {
        let msb:Byte = self.readFromStack()
        let lsb:Byte = self.readFromStack()
        return EnhancedShort(lsb,msb).value
    }
    
    /// write a byte to stack along with PC decrement
    public func writeToStack(_ val:Byte) -> Void {
        mmu.write(address: self.registers.SP, val: val)
        self.registers.SP -= 1
    }
    
    /// write a short to stack along with PC decrements
    public func writeToStack(_ val:Short) -> Void {
        let tmp = EnhancedShort(val)
        self.writeToStack(tmp)
    }
    
    /// write a short to stack along with PC decrements
    public func writeToStack(_ val:EnhancedShort) -> Void {
        self.writeToStack(val.lsb)
        self.writeToStack(val.msb)
    }
    
    // mark: standard instructions set
    
    // n.b if behavior differs from doc, read CPU manual to understand behavior
    
    func nop() -> Void {/*do nothing*/}
    func ld_bc_nn(val:EnhancedShort) -> Void { self.registers.BC = val.value }
    func ld_bcp_a() -> Void { mmu.write( address: self.registers.BC, val: self.registers.A) }
    func inc_bc() -> Void { self.registers.BC = self.inc(self.registers.BC) }
    func inc_b() -> Void { self.registers.B = self.inc(self.registers.B) }
    func dec_b() -> Void { self.registers.B = self.dec(self.registers.B) }
    func ld_b_n(val:Byte) -> Void { self.registers.B = val }
    func rlca() -> Void { self.registers.A = rl(self.registers.A, circular: true) }
    func ld_nnp_sp(address:EnhancedShort) -> Void { mmu.write(address: mmu.read(address: address.value), val: self.registers.SP) }
    func add_hl_bc() -> Void { self.add_hl(self.registers.BC) }
    func ld_a_bcp() -> Void { self.registers.A = mmu.read(address: self.registers.BC) }
    func dec_bc() -> Void { self.registers.BC -= 1 }
    func inc_c() -> Void { self.registers.C = self.inc(self.registers.C) }
    func dec_c() -> Void { self.registers.C = self.dec(self.registers.C) }
    func ld_c_n(val:Byte) -> Void { self.registers.C = val }
    func rrca() -> Void { self.registers.A = rr(self.registers.A, circular: true) }
    func stop() -> Void { /*todo*/ }
    func ld_de_nn(val:EnhancedShort) -> Void { self.registers.DE = val.value }
    func ld_dep_a() -> Void { mmu.write(address: self.registers.DE, val: self.registers.A) }
    func inc_de() -> Void { self.registers.DE = self.inc(self.registers.DE) }
    func inc_d() -> Void { self.registers.D = self.inc(self.registers.D) }
    func dec_d() -> Void { self.registers.D = self.dec(self.registers.D) }
    func ld_d_n(val:Byte) -> Void { self.registers.D = val }
    func rla() -> Void { /*todo*/ }
    func jr_n(val:Byte) -> Void { jumpRelative(val) }
    func add_hl_de() -> Void { self.add_hl(self.registers.DE) }
    func ld_a_dep() -> Void { self.registers.A = mmu.read(address: self.registers.DE) }
    func dec_de() -> Void { self.registers.DE = self.dec(self.registers.DE) }
    func inc_e() -> Void { self.registers.E = self.inc(self.registers.E) }
    func dec_e() -> Void { self.registers.E = self.dec(self.registers.E) }
    func ld_e_n(val:Byte) -> Void { self.registers.E = val }
    func rra() -> Void { self.registers.A = rr(self.registers.A) }
    func jr_nz_n(val:Byte) -> Void { jumpRelative(val, .ZERO, inverseFlag: true) }
    func ld_hl_nn(val:EnhancedShort) -> Void { self.registers.HL = val.value }
    func ld_hlip_a() -> Void { mmu.write(address: self.registers.HL, val: self.registers.A); self.registers.HL+=1 }
    func inc_hl() -> Void { self.registers.HL = self.inc(self.registers.HL) }
    func inc_h() -> Void { self.registers.H = self.inc(self.registers.H) }
    func dec_h() -> Void { self.registers.H = self.dec(self.registers.H) }
    func ld_h_n(val:Byte) -> Void { self.registers.H = val }
    func daa() -> Void { /*todo*/ }
    func jr_z_n(val:Byte) -> Void { jumpRelative(val, .ZERO) }
    func add_hl_hl() -> Void { self.add_hl(self.registers.HL) }
    func ld_a_hlip() -> Void { self.registers.A = mmu.read(address: self.registers.HL); self.registers.HL+=1 }
    func dec_hl() -> Void { self.registers.HL = self.dec(self.registers.HL) }
    func inc_l() -> Void { self.registers.L = self.inc(self.registers.L) }
    func dec_l() -> Void { self.registers.L = self.dec(self.registers.L) }
    func ld_l_n(val:Byte) -> Void { self.registers.L = val }
    func cpl() -> Void { self.registers.A ^= self.registers.A }
    func jr_nc_n(val:Byte) -> Void { jumpRelative(val, .NEGATIVE, .CARRY) }
    func ld_sp_nn(val:EnhancedShort) -> Void { self.registers.SP = val.value }
    func ld_hlpd_a() -> Void { mmu.write(address: self.registers.HL, val: self.registers.A); self.registers.HL-=1 }
    func inc_sp() -> Void { self.registers.SP = self.inc(self.registers.SP) }
    func inc_hlp() -> Void { mmu.write(address: self.registers.HL, val: self.inc(mmu.read(address: self.registers.HL) as Short)) }
    func dec_hlp() -> Void { mmu.write(address: self.registers.HL, val: self.dec(mmu.read(address: self.registers.HL) as Short)) }
    func ld_hlp_n(val:Byte) -> Void { mmu.write(address: self.registers.HL, val: val) }
    func scf() -> Void { self.registers.clearFlags(.NEGATIVE,.HALF_CARRY); self.registers.raiseFlag(.CARRY) }
    func jr_c_n(val:Byte) -> Void { jumpRelative(val, .CARRY) }
    func add_hl_sp() -> Void { self.add_hl(self.registers.SP) }
    func ld_a_hlpd() -> Void { self.registers.A = mmu.read(address: self.registers.HL); self.registers.HL -= 1 }
    func dec_sp() -> Void { self.registers.SP -= 1 }
    func inc_a() -> Void { self.registers.A = self.inc(self.registers.A) }
    func dec_a() -> Void { self.registers.A = self.dec(self.registers.A) }
    func ld_a_n(val:Byte) -> Void { self.registers.A = val }
    func ccf() -> Void { self.registers.clearFlags(.NEGATIVE,.HALF_CARRY); self.registers.isFlagSet(.CARRY) ? self.registers.clearFlag(.CARRY) : self.registers.raiseFlag(.CARRY) }
    func ld_b_b() -> Void { self.registers.B = self.registers.B }
    func ld_b_c() -> Void { self.registers.B = self.registers.C }
    func ld_b_d() -> Void { self.registers.B = self.registers.D }
    func ld_b_e() -> Void { self.registers.B = self.registers.E }
    func ld_b_h() -> Void { self.registers.B = self.registers.H }
    func ld_b_l() -> Void { self.registers.B = self.registers.L }
    func ld_b_hlp() -> Void { self.registers.B = mmu.read(address: self.registers.HL) }
    func ld_b_a() -> Void { self.registers.B = self.registers.A }
    func ld_c_b() -> Void { self.registers.C = self.registers.B }
    func ld_c_c() -> Void { self.registers.C = self.registers.C }
    func ld_c_d() -> Void { self.registers.C = self.registers.D }
    func ld_c_e() -> Void { self.registers.C = self.registers.E }
    func ld_c_h() -> Void { self.registers.C = self.registers.H }
    func ld_c_l() -> Void { self.registers.C = self.registers.L }
    func ld_c_hlp() -> Void { self.registers.C = mmu.read(address: self.registers.HL) }
    func ld_c_a() -> Void { self.registers.C = self.registers.A }
    func ld_d_b() -> Void { self.registers.D = self.registers.B }
    func ld_d_c() -> Void { self.registers.D = self.registers.C }
    func ld_d_d() -> Void { self.registers.D = self.registers.D }
    func ld_d_e() -> Void { self.registers.D = self.registers.E }
    func ld_d_h() -> Void { self.registers.D = self.registers.H }
    func ld_d_l() -> Void { self.registers.D = self.registers.L }
    func ld_d_hlp() -> Void { self.registers.D = mmu.read(address: self.registers.HL) }
    func ld_d_a() -> Void { self.registers.D = self.registers.A }
    func ld_e_b() -> Void { self.registers.E = self.registers.B }
    func ld_e_c() -> Void { self.registers.E = self.registers.C }
    func ld_e_d() -> Void { self.registers.E = self.registers.D }
    func ld_e_e() -> Void { self.registers.E = self.registers.E }
    func ld_e_h() -> Void { self.registers.E = self.registers.H }
    func ld_e_l() -> Void { self.registers.E = self.registers.L }
    func ld_e_hlp() -> Void { self.registers.E = mmu.read(address: self.registers.HL) }
    func ld_e_a() -> Void { self.registers.E = self.registers.A }
    func ld_h_b() -> Void { self.registers.H = self.registers.B }
    func ld_h_c() -> Void { self.registers.H = self.registers.C }
    func ld_h_d() -> Void { self.registers.H = self.registers.D }
    func ld_h_e() -> Void { self.registers.H = self.registers.E }
    func ld_h_h() -> Void { self.registers.H = self.registers.H }
    func ld_h_l() -> Void { self.registers.H = self.registers.L }
    func ld_h_hlp() -> Void { self.registers.H = mmu.read(address: self.registers.HL) }
    func ld_h_a() -> Void { self.registers.H = self.registers.A }
    func ld_l_b() -> Void { self.registers.L = self.registers.B }
    func ld_l_c() -> Void { self.registers.L = self.registers.C }
    func ld_l_d() -> Void { self.registers.L = self.registers.D }
    func ld_l_e() -> Void { self.registers.L = self.registers.E }
    func ld_l_h() -> Void { self.registers.L = self.registers.H }
    func ld_l_l() -> Void { self.registers.L = self.registers.L }
    func ld_l_hlp() -> Void { self.registers.L = mmu.read(address: self.registers.HL) }
    func ld_l_a() -> Void { self.registers.L = self.registers.A }
    func ld_hlp_b() -> Void { mmu.write(address: self.registers.HL, val: self.registers.B) }
    func ld_hlp_c() -> Void { mmu.write(address: self.registers.HL, val: self.registers.C) }
    func ld_hlp_d() -> Void { mmu.write(address: self.registers.HL, val: self.registers.D) }
    func ld_hlp_e() -> Void { mmu.write(address: self.registers.HL, val: self.registers.E) }
    func ld_hlp_h() -> Void { mmu.write(address: self.registers.HL, val: self.registers.H) }
    func ld_hlp_l() -> Void { mmu.write(address: self.registers.HL, val: self.registers.L) }
    func halt() -> Void { /*todo*/ }
    func ld_hlp_a() -> Void { mmu.write(address: self.registers.HL, val: self.registers.A) }
    func ld_a_b() -> Void { self.registers.A = self.registers.B }
    func ld_a_c() -> Void { self.registers.A = self.registers.C }
    func ld_a_d() -> Void { self.registers.A = self.registers.D }
    func ld_a_e() -> Void { self.registers.A = self.registers.E }
    func ld_a_h() -> Void { self.registers.A = self.registers.H }
    func ld_a_l() -> Void { self.registers.A = self.registers.L }
    func ld_a_hlp() -> Void { self.registers.A = mmu.read(address: self.registers.HL)  }
    func ld_a_a() -> Void { self.registers.A = self.registers.A  }
    func add_a_b() -> Void { self.add_a(self.registers.B) }
    func add_a_c() -> Void { self.add_a(self.registers.C) }
    func add_a_d() -> Void { self.add_a(self.registers.D) }
    func add_a_e() -> Void { self.add_a(self.registers.E) }
    func add_a_h() -> Void { self.add_a(self.registers.H) }
    func add_a_l() -> Void { self.add_a(self.registers.L) }
    func add_a_hlp() -> Void { self.add_a(mmu.read(address: self.registers.HL)) }
    func add_a_a() -> Void { self.add_a(self.registers.A) }
    func adc_a_b() -> Void { self.adc_a(self.registers.B) }
    func adc_a_c() -> Void { self.adc_a(self.registers.C) }
    func adc_a_d() -> Void { self.adc_a(self.registers.D) }
    func adc_a_e() -> Void { self.adc_a(self.registers.E) }
    func adc_a_h() -> Void { self.adc_a(self.registers.H) }
    func adc_a_l() -> Void { self.adc_a(self.registers.L) }
    func adc_a_hlp() -> Void { self.adc_a(mmu.read(address: self.registers.HL)) }
    func adc_a_a() -> Void { self.adc_a(self.registers.A) }
    func sub_a_b() -> Void { self.sub_a(self.registers.B) }
    func sub_a_c() -> Void { self.sub_a(self.registers.C) }
    func sub_a_d() -> Void { self.sub_a(self.registers.D) }
    func sub_a_e() -> Void { self.sub_a(self.registers.E) }
    func sub_a_h() -> Void { self.sub_a(self.registers.H) }
    func sub_a_l() -> Void { self.sub_a(self.registers.L) }
    func sub_a_hlp() -> Void { self.sub_a(mmu.read(address: self.registers.HL)) }
    func sub_a_a() -> Void { self.sub_a(self.registers.A) }
    func sbc_a_b() -> Void { self.sbc_a(self.registers.B) }
    func sbc_a_c() -> Void { self.sbc_a(self.registers.C) }
    func sbc_a_d() -> Void { self.sbc_a(self.registers.D) }
    func sbc_a_e() -> Void { self.sbc_a(self.registers.E) }
    func sbc_a_h() -> Void { self.sbc_a(self.registers.H) }
    func sbc_a_l() -> Void { self.sbc_a(self.registers.L) }
    func sbc_a_hlp() -> Void { self.sbc_a(mmu.read(address: self.registers.HL)) }
    func sbc_a_a() -> Void { self.sbc_a(self.registers.A) }
    func and_a_b() -> Void { self.and_a(self.registers.B) }
    func and_a_c() -> Void { self.and_a(self.registers.C) }
    func and_a_d() -> Void { self.and_a(self.registers.D) }
    func and_a_e() -> Void { self.and_a(self.registers.E) }
    func and_a_h() -> Void { self.and_a(self.registers.H) }
    func and_a_l() -> Void { self.and_a(self.registers.L) }
    func and_a_hlp() -> Void { self.and_a(mmu.read(address: self.registers.HL)) }
    func and_a_a() -> Void { self.and_a(self.registers.A) }
    func xor_a_b() -> Void { self.xor_a(self.registers.B) }
    func xor_a_c() -> Void { self.xor_a(self.registers.C) }
    func xor_a_d() -> Void { self.xor_a(self.registers.D) }
    func xor_a_e() -> Void { self.xor_a(self.registers.E) }
    func xor_a_h() -> Void { self.xor_a(self.registers.H) }
    func xor_a_l() -> Void { self.xor_a(self.registers.L) }
    func xor_a_hlp() -> Void { self.xor_a(mmu.read(address: self.registers.HL)) }
    func xor_a_a() -> Void { self.xor_a(self.registers.A) }
    func or_a_b() -> Void { self.or_a(self.registers.B) }
    func or_a_c() -> Void { self.or_a(self.registers.C) }
    func or_a_d() -> Void { self.or_a(self.registers.D) }
    func or_a_e() -> Void { self.or_a(self.registers.E) }
    func or_a_h() -> Void { self.or_a(self.registers.H) }
    func or_a_l() -> Void { self.or_a(self.registers.L) }
    func or_a_hlp() -> Void { self.or_a(mmu.read(address: self.registers.HL)) }
    func or_a_a() -> Void { self.or_a(self.registers.A) }
    func cp_a_b() -> Void { self.cp_a(self.registers.B) }
    func cp_a_c() -> Void { self.cp_a(self.registers.C) }
    func cp_a_d() -> Void { self.cp_a(self.registers.D) }
    func cp_a_e() -> Void { self.cp_a(self.registers.E) }
    func cp_a_h() -> Void { self.cp_a(self.registers.H) }
    func cp_a_l() -> Void { self.cp_a(self.registers.L) }
    func cp_a_hlp() -> Void { self.cp_a(mmu.read(address: self.registers.HL)) }
    func cp_a_a() -> Void { self.cp_a(self.registers.A) }
    func ret_nz() -> Void { self.retrn(.ZERO, inverseFlag: true) }
    func pop_bc() -> Void { self.registers.BC = self.readFromStack() }
    func jp_nz_nn(address:EnhancedShort) -> Void { jumpTo(address,.ZERO,inverseFlag: true) }
    func jp_nn(address:EnhancedShort) -> Void { jumpTo(address) }
    func call_nz_nn(address:EnhancedShort) -> Void { self.call(address, .ZERO, inverseFlag: true, branchingCycleOverhead: 12) }
    func push_bc() -> Void { self.writeToStack(self.registers.BC) }
    func add_a_n(val:Byte) -> Void { self.add_a(val) }
    func rst_00h() -> Void { self.call(ReservedMemoryLocationAddresses.RESTART_00.rawValue) }
    func ret_z() -> Void { self.retrn(.ZERO) }
    func ret() -> Void { self.retrn() }
    func jp_z_nn(address:EnhancedShort) -> Void { jumpTo(address,.ZERO) }
    func call_z_nn(address:EnhancedShort) -> Void { self.call(address, .ZERO, inverseFlag: false, branchingCycleOverhead: 12) }
    func call_nn(address:EnhancedShort) -> Void { self.call(address) }
    func adc_a_n(val:Byte) -> Void { self.adc_a(val) }
    func rst_08h() -> Void { self.call(ReservedMemoryLocationAddresses.RESTART_08.rawValue) }
    func ret_nc() -> Void { self.retrn(.NEGATIVE,.CARRY) }
    func pop_de() -> Void { self.registers.DE = self.readFromStack() }
    func jp_nc_nn(address:EnhancedShort) -> Void { jumpTo(address,.NEGATIVE,.CARRY) }
    func call_nc_nn(address:EnhancedShort) -> Void { self.call(address, .CARRY, inverseFlag: true, branchingCycleOverhead: 12) }
    func push_de() -> Void { self.writeToStack(self.registers.DE) }
    func sub_a_n(val:Byte) -> Void { self.sub_a(val) }
    func rst_10h() -> Void { self.call(ReservedMemoryLocationAddresses.RESTART_10.rawValue) }
    func ret_c() -> Void { self.retrn(.CARRY) }
    func reti() -> Void { self.ret_i() }
    func jp_c_nn(address:EnhancedShort) -> Void { jumpTo(address,.CARRY) }
    func call_c_nn(address:EnhancedShort) -> Void { self.call(address, .CARRY, inverseFlag: false, branchingCycleOverhead: 12) }
    func sbc_a_n(val:Byte) -> Void { self.sbc_a(val) }
    func rst_18h() -> Void { self.call(ReservedMemoryLocationAddresses.RESTART_18.rawValue) }
    func ld_ff00pn_a(val:Byte) -> Void { mmu.write(address: 0xFF00+UInt16(val), val: self.registers.A) }
    func pop_hl() -> Void { self.registers.HL = self.readFromStack() }
    func ld_ff00pc_a() -> Void { mmu.write(address: 0xFF00+UInt16(self.registers.C), val: self.registers.A) }
    func push_hl() -> Void { self.writeToStack(self.registers.HL) }
    func and_a_n(val:Byte) -> Void { self.and_a(val) }
    func rst_20h() -> Void { self.call(ReservedMemoryLocationAddresses.RESTART_20.rawValue) }
    func add_sp_n(val:EnhancedShort) -> Void { self.add_sp(val.value) }
    func jp_hl() -> Void { self.registers.PC = self.registers.HL }
    func ld_nnp_a(address:EnhancedShort) -> Void { mmu.write(address: address.value, val: self.registers.A) }
    func xor_a_n(val:Byte) -> Void { self.xor_a(val) }
    func rst_28h() -> Void { self.call(ReservedMemoryLocationAddresses.RESTART_28.rawValue) }
    func ld_a_ff00pn(val:Byte) -> Void { self.registers.A = mmu.read(address: 0xFF00 &+ UInt16(val)) }
    func pop_af() -> Void { self.registers.AF = self.readFromStack() }
    func ld_a_ff00pc() -> Void { self.registers.A = mmu.read(address: 0xFF00 &+ UInt16(self.registers.C)) }
    func di() -> Void { interrupts.IME = false }
    func push_af() -> Void { self.writeToStack(self.registers.AF) }
    func or_a_n(val:Byte) -> Void { self.or_a(val) }
    func rst_30h() -> Void { self.call(ReservedMemoryLocationAddresses.RESTART_30.rawValue) }
    func ld_hl_sppn(val:EnhancedShort) -> Void { 
        let res:Short = self.registers.SP &+ val.value
        self.registers.conditionalSet(cond: hasCarry(self.registers.SP, res) , flag: .CARRY)
        self.registers.conditionalSet(cond: isAddHalfCarry(self.registers.SP, val.value) , flag: .HALF_CARRY)
        self.registers.clearFlags(.NEGATIVE,.ZERO)
        self.registers.HL = res
    }
    func ld_sp_hl() -> Void { self.registers.SP = self.registers.HL }
    func ld_a_nnp(address:EnhancedShort) -> Void { self.registers.A = mmu.read(address: address.value) }
    func ei() -> Void { self.e_i(true) }
    func cp_a_n(val:Byte) -> Void { self.cp_a(val) }
    func rst_38h() -> Void { self.call(ReservedMemoryLocationAddresses.RESTART_38.rawValue) }
    
    // mark: extended instruction set
    func rlc_b() -> Void { self.registers.B = self.rl(self.registers.B, circular: true) }
    func rlc_c() -> Void { self.registers.C = self.rl(self.registers.C, circular: true) }
    func rlc_d() -> Void { self.registers.D = self.rl(self.registers.D, circular: true) }
    func rlc_e() -> Void { self.registers.E = self.rl(self.registers.E, circular: true) }
    func rlc_h() -> Void { self.registers.H = self.rl(self.registers.H, circular: true) }
    func rlc_l() -> Void { self.registers.L = self.rl(self.registers.L, circular: true) }
    func rlc_hlp() -> Void { mmu.write(address: self.registers.HL, val: self.rl(mmu.read(address: self.registers.HL),circular: true)) }
    func rlc_a() -> Void { self.registers.A = self.rl(self.registers.A, circular: true) }
    func rrc_b() -> Void { self.registers.B = self.rr(self.registers.B, circular: true) }
    func rrc_c() -> Void { self.registers.C = self.rr(self.registers.C, circular: true) }
    func rrc_d() -> Void { self.registers.D = self.rr(self.registers.D, circular: true) }
    func rrc_e() -> Void { self.registers.E = self.rr(self.registers.E, circular: true) }
    func rrc_h() -> Void { self.registers.H = self.rr(self.registers.H, circular: true) }
    func rrc_l() -> Void { self.registers.L = self.rr(self.registers.L, circular: true) }
    func rrc_hlp() -> Void { mmu.write(address: self.registers.HL, val: self.rr(mmu.read(address: self.registers.HL),circular: true)) }
    func rrc_a() -> Void { self.registers.B = self.rr(self.registers.A, circular: true) }
    func rl_b() -> Void { self.registers.B = self.rl(self.registers.B) }
    func rl_c() -> Void { self.registers.C = self.rl(self.registers.C) }
    func rl_d() -> Void { self.registers.D = self.rl(self.registers.D) }
    func rl_e() -> Void { self.registers.E = self.rl(self.registers.E) }
    func rl_h() -> Void { self.registers.H = self.rl(self.registers.H) }
    func rl_l() -> Void { self.registers.L = self.rl(self.registers.L) }
    func rl_hlp() -> Void { mmu.write(address: self.registers.HL, val: self.rl(mmu.read(address: self.registers.HL))) }
    func rl_a() -> Void { self.registers.A = self.rl(self.registers.A) }
    func rr_b() -> Void { self.registers.B = self.rr(self.registers.B) }
    func rr_c() -> Void { self.registers.C = self.rr(self.registers.C) }
    func rr_d() -> Void { self.registers.D = self.rr(self.registers.D) }
    func rr_e() -> Void { self.registers.E = self.rr(self.registers.E) }
    func rr_h() -> Void { self.registers.H = self.rr(self.registers.H) }
    func rr_l() -> Void { self.registers.L = self.rr(self.registers.L) }
    func rr_hlp() -> Void { mmu.write(address: self.registers.HL, val: self.rr(mmu.read(address: self.registers.HL))) }
    func rr_a() -> Void { self.registers.A = self.rr(self.registers.A) }
    func sla_b() -> Void { /*todo*/ }
    func sla_c() -> Void { /*todo*/ }
    func sla_d() -> Void { /*todo*/ }
    func sla_e() -> Void { /*todo*/ }
    func sla_h() -> Void { /*todo*/ }
    func sla_l() -> Void { /*todo*/ }
    func sla_hlp() -> Void { /*todo*/ }
    func sla_a() -> Void { /*todo*/ }
    func sra_b() -> Void { /*todo*/ }
    func sra_c() -> Void { /*todo*/ }
    func sra_d() -> Void { /*todo*/ }
    func sra_e() -> Void { /*todo*/ }
    func sra_h() -> Void { /*todo*/ }
    func sra_l() -> Void { /*todo*/ }
    func sra_hlp() -> Void { /*todo*/ }
    func sra_a() -> Void { /*todo*/ }
    func swap_b() -> Void { self.registers.B = self.swap(self.registers.B) }
    func swap_c() -> Void { self.registers.C = self.swap(self.registers.C) }
    func swap_d() -> Void { self.registers.D = self.swap(self.registers.D) }
    func swap_e() -> Void { self.registers.E = self.swap(self.registers.E) }
    func swap_h() -> Void { self.registers.H = self.swap(self.registers.H) }
    func swap_l() -> Void { self.registers.L = self.swap(self.registers.L) }
    func swap_hlp() -> Void { mmu.write(address: self.registers.HL, val: self.swap(mmu.read(address: self.registers.HL))) }
    func swap_a() -> Void { self.registers.A = self.swap(self.registers.A) }
    func srl_b() -> Void { /*todo*/ }
    func srl_c() -> Void { /*todo*/ }
    func srl_d() -> Void { /*todo*/ }
    func srl_e() -> Void { /*todo*/ }
    func srl_h() -> Void { /*todo*/ }
    func srl_l() -> Void { /*todo*/ }
    func srl_hlp() -> Void { /*todo*/ }
    func srl_a() -> Void { /*todo*/ }
    func bit_0_b() -> Void { test_bit(.Bit_0, self.registers.B) }
    func bit_0_c() -> Void { test_bit(.Bit_0, self.registers.C) }
    func bit_0_d() -> Void { test_bit(.Bit_0, self.registers.D) }
    func bit_0_e() -> Void { test_bit(.Bit_0, self.registers.E) }
    func bit_0_h() -> Void { test_bit(.Bit_0, self.registers.H) }
    func bit_0_l() -> Void { test_bit(.Bit_0, self.registers.L) }
    func bit_0_hlp() -> Void { test_bit(.Bit_0, mmu.read(address: self.registers.HL)) }
    func bit_0_a() -> Void { test_bit(.Bit_0, self.registers.A) }
    func bit_1_b() -> Void { test_bit(.Bit_1, self.registers.B) }
    func bit_1_c() -> Void { test_bit(.Bit_1, self.registers.C) }
    func bit_1_d() -> Void { test_bit(.Bit_1, self.registers.D) }
    func bit_1_e() -> Void { test_bit(.Bit_1, self.registers.E) }
    func bit_1_h() -> Void { test_bit(.Bit_1, self.registers.H) }
    func bit_1_l() -> Void { test_bit(.Bit_1, self.registers.L) }
    func bit_1_hlp() -> Void { test_bit(.Bit_1, mmu.read(address: self.registers.HL)) }
    func bit_1_a() -> Void { test_bit(.Bit_1, self.registers.A) }
    func bit_2_b() -> Void { test_bit(.Bit_2, self.registers.B) }
    func bit_2_c() -> Void { test_bit(.Bit_2, self.registers.C) }
    func bit_2_d() -> Void { test_bit(.Bit_2, self.registers.D) }
    func bit_2_e() -> Void { test_bit(.Bit_2, self.registers.E) }
    func bit_2_h() -> Void { test_bit(.Bit_2, self.registers.H) }
    func bit_2_l() -> Void { test_bit(.Bit_2, self.registers.L) }
    func bit_2_hlp() -> Void { test_bit(.Bit_2, mmu.read(address: self.registers.HL)) }
    func bit_2_a() -> Void { test_bit(.Bit_2, self.registers.A) }
    func bit_3_b() -> Void { test_bit(.Bit_3, self.registers.B) }
    func bit_3_c() -> Void { test_bit(.Bit_3, self.registers.C) }
    func bit_3_d() -> Void { test_bit(.Bit_3, self.registers.D) }
    func bit_3_e() -> Void { test_bit(.Bit_3, self.registers.E) }
    func bit_3_h() -> Void { test_bit(.Bit_3, self.registers.H) }
    func bit_3_l() -> Void { test_bit(.Bit_3, self.registers.L) }
    func bit_3_hlp() -> Void { test_bit(.Bit_3, mmu.read(address: self.registers.HL)) }
    func bit_3_a() -> Void { test_bit(.Bit_3, self.registers.A) }
    func bit_4_b() -> Void { test_bit(.Bit_4, self.registers.B) }
    func bit_4_c() -> Void { test_bit(.Bit_4, self.registers.C) }
    func bit_4_d() -> Void { test_bit(.Bit_4, self.registers.D) }
    func bit_4_e() -> Void { test_bit(.Bit_4, self.registers.E) }
    func bit_4_h() -> Void { test_bit(.Bit_4, self.registers.H) }
    func bit_4_l() -> Void { test_bit(.Bit_4, self.registers.L) }
    func bit_4_hlp() -> Void { test_bit(.Bit_4, mmu.read(address: self.registers.HL)) }
    func bit_4_a() -> Void { test_bit(.Bit_4, self.registers.A) }
    func bit_5_b() -> Void { test_bit(.Bit_5, self.registers.B) }
    func bit_5_c() -> Void { test_bit(.Bit_5, self.registers.C) }
    func bit_5_d() -> Void { test_bit(.Bit_5, self.registers.D) }
    func bit_5_e() -> Void { test_bit(.Bit_5, self.registers.E) }
    func bit_5_h() -> Void { test_bit(.Bit_5, self.registers.H) }
    func bit_5_l() -> Void { test_bit(.Bit_5, self.registers.L) }
    func bit_5_hlp() -> Void { test_bit(.Bit_5, mmu.read(address: self.registers.HL)) }
    func bit_5_a() -> Void { test_bit(.Bit_5, self.registers.A) }
    func bit_6_b() -> Void { test_bit(.Bit_6, self.registers.B) }
    func bit_6_c() -> Void { test_bit(.Bit_6, self.registers.C) }
    func bit_6_d() -> Void { test_bit(.Bit_6, self.registers.D) }
    func bit_6_e() -> Void { test_bit(.Bit_6, self.registers.E) }
    func bit_6_h() -> Void { test_bit(.Bit_6, self.registers.H) }
    func bit_6_l() -> Void { test_bit(.Bit_6, self.registers.L) }
    func bit_6_hlp() -> Void { test_bit(.Bit_6, mmu.read(address: self.registers.HL)) }
    func bit_6_a() -> Void { test_bit(.Bit_6, self.registers.A) }
    func bit_7_b() -> Void { test_bit(.Bit_7, self.registers.B) }
    func bit_7_c() -> Void { test_bit(.Bit_7, self.registers.C) }
    func bit_7_d() -> Void { test_bit(.Bit_7, self.registers.D) }
    func bit_7_e() -> Void { test_bit(.Bit_7, self.registers.E) }
    func bit_7_h() -> Void { test_bit(.Bit_7, self.registers.H) }
    func bit_7_l() -> Void { test_bit(.Bit_7, self.registers.L) }
    func bit_7_hlp() -> Void { test_bit(.Bit_7, mmu.read(address: self.registers.HL)) }
    func bit_7_a() -> Void { test_bit(.Bit_7, self.registers.A) }
    func res_0_b() -> Void { self.registers.B = clear(.Bit_0, self.registers.B) }
    func res_0_c() -> Void { self.registers.C = clear(.Bit_0, self.registers.C) }
    func res_0_d() -> Void { self.registers.D = clear(.Bit_0, self.registers.D) }
    func res_0_e() -> Void { self.registers.E = clear(.Bit_0, self.registers.E) }
    func res_0_h() -> Void { self.registers.H = clear(.Bit_0, self.registers.H) }
    func res_0_l() -> Void { self.registers.L = clear(.Bit_0, self.registers.L) }
    func res_0_hlp() -> Void { mmu.write(address: self.registers.HL, val: clear(.Bit_0,mmu.read(address: self.registers.HL))) }
    func res_0_a() -> Void { self.registers.A = clear(.Bit_0, self.registers.A) }
    func res_1_b() -> Void { self.registers.B = clear(.Bit_1, self.registers.B) }
    func res_1_c() -> Void { self.registers.C = clear(.Bit_1, self.registers.C) }
    func res_1_d() -> Void { self.registers.D = clear(.Bit_1, self.registers.D) }
    func res_1_e() -> Void { self.registers.E = clear(.Bit_1, self.registers.E) }
    func res_1_h() -> Void { self.registers.H = clear(.Bit_1, self.registers.H) }
    func res_1_l() -> Void { self.registers.L = clear(.Bit_1, self.registers.L) }
    func res_1_hlp() -> Void { mmu.write(address: self.registers.HL, val: clear(.Bit_1,mmu.read(address: self.registers.HL))) }
    func res_1_a() -> Void { self.registers.A = clear(.Bit_1, self.registers.A) }
    func res_2_b() -> Void { self.registers.B = clear(.Bit_2, self.registers.B) }
    func res_2_c() -> Void { self.registers.C = clear(.Bit_2, self.registers.C) }
    func res_2_d() -> Void { self.registers.D = clear(.Bit_2, self.registers.D) }
    func res_2_e() -> Void { self.registers.E = clear(.Bit_2, self.registers.E) }
    func res_2_h() -> Void { self.registers.H = clear(.Bit_2, self.registers.H) }
    func res_2_l() -> Void { self.registers.L = clear(.Bit_2, self.registers.L) }
    func res_2_hlp() -> Void { mmu.write(address: self.registers.HL, val: clear(.Bit_2,mmu.read(address: self.registers.HL))) }
    func res_2_a() -> Void { self.registers.A = clear(.Bit_2, self.registers.A) }
    func res_3_b() -> Void { self.registers.B = clear(.Bit_3, self.registers.B) }
    func res_3_c() -> Void { self.registers.C = clear(.Bit_3, self.registers.C) }
    func res_3_d() -> Void { self.registers.D = clear(.Bit_3, self.registers.D) }
    func res_3_e() -> Void { self.registers.E = clear(.Bit_3, self.registers.E) }
    func res_3_h() -> Void { self.registers.H = clear(.Bit_3, self.registers.H) }
    func res_3_l() -> Void { self.registers.L = clear(.Bit_3, self.registers.L) }
    func res_3_hlp() -> Void { mmu.write(address: self.registers.HL, val: clear(.Bit_3,mmu.read(address: self.registers.HL))) }
    func res_3_a() -> Void { self.registers.A = clear(.Bit_3, self.registers.A) }
    func res_4_b() -> Void { self.registers.B = clear(.Bit_4, self.registers.B) }
    func res_4_c() -> Void { self.registers.C = clear(.Bit_4, self.registers.C) }
    func res_4_d() -> Void { self.registers.D = clear(.Bit_4, self.registers.D) }
    func res_4_e() -> Void { self.registers.E = clear(.Bit_4, self.registers.E) }
    func res_4_h() -> Void { self.registers.H = clear(.Bit_4, self.registers.H) }
    func res_4_l() -> Void { self.registers.L = clear(.Bit_4, self.registers.L) }
    func res_4_hlp() -> Void { mmu.write(address: self.registers.HL, val: clear(.Bit_4,mmu.read(address: self.registers.HL))) }
    func res_4_a() -> Void { self.registers.A = clear(.Bit_4, self.registers.A) }
    func res_5_b() -> Void { self.registers.B = clear(.Bit_5, self.registers.B) }
    func res_5_c() -> Void { self.registers.C = clear(.Bit_5, self.registers.C) }
    func res_5_d() -> Void { self.registers.D = clear(.Bit_5, self.registers.D) }
    func res_5_e() -> Void { self.registers.E = clear(.Bit_5, self.registers.E) }
    func res_5_h() -> Void { self.registers.H = clear(.Bit_5, self.registers.H) }
    func res_5_l() -> Void { self.registers.L = clear(.Bit_5, self.registers.L) }
    func res_5_hlp() -> Void { mmu.write(address: self.registers.HL, val: clear(.Bit_5,mmu.read(address: self.registers.HL))) }
    func res_5_a() -> Void { self.registers.A = clear(.Bit_5, self.registers.A) }
    func res_6_b() -> Void { self.registers.B = clear(.Bit_6, self.registers.B) }
    func res_6_c() -> Void { self.registers.C = clear(.Bit_6, self.registers.C) }
    func res_6_d() -> Void { self.registers.D = clear(.Bit_6, self.registers.D) }
    func res_6_e() -> Void { self.registers.E = clear(.Bit_6, self.registers.E) }
    func res_6_h() -> Void { self.registers.H = clear(.Bit_6, self.registers.H) }
    func res_6_l() -> Void { self.registers.L = clear(.Bit_6, self.registers.L) }
    func res_6_hlp() -> Void { mmu.write(address: self.registers.HL, val: clear(.Bit_6,mmu.read(address: self.registers.HL))) }
    func res_6_a() -> Void { self.registers.A = clear(.Bit_6, self.registers.A) }
    func res_7_b() -> Void { self.registers.B = clear(.Bit_7, self.registers.B) }
    func res_7_c() -> Void { self.registers.C = clear(.Bit_7, self.registers.C) }
    func res_7_d() -> Void { self.registers.D = clear(.Bit_7, self.registers.D) }
    func res_7_e() -> Void { self.registers.E = clear(.Bit_7, self.registers.E) }
    func res_7_h() -> Void { self.registers.H = clear(.Bit_7, self.registers.H) }
    func res_7_l() -> Void { self.registers.L = clear(.Bit_7, self.registers.L) }
    func res_7_hlp() -> Void { mmu.write(address: self.registers.HL, val: clear(.Bit_7,mmu.read(address: self.registers.HL))) }
    func res_7_a() -> Void { self.registers.A = clear(.Bit_7, self.registers.A) }
    func set_0_b() -> Void { self.registers.B = set(.Bit_0, self.registers.B) }
    func set_0_c() -> Void { self.registers.C = set(.Bit_0, self.registers.C) }
    func set_0_d() -> Void { self.registers.D = set(.Bit_0, self.registers.D) }
    func set_0_e() -> Void { self.registers.E = set(.Bit_0, self.registers.E) }
    func set_0_h() -> Void { self.registers.H = set(.Bit_0, self.registers.H) }
    func set_0_l() -> Void { self.registers.L = set(.Bit_0, self.registers.L) }
    func set_0_hlp() -> Void { mmu.write(address: self.registers.HL, val: set(.Bit_0,mmu.read(address: self.registers.HL))) }
    func set_0_a() -> Void { self.registers.A = set(.Bit_0, self.registers.A) }
    func set_1_b() -> Void { self.registers.B = set(.Bit_1, self.registers.B) }
    func set_1_c() -> Void { self.registers.C = set(.Bit_1, self.registers.C) }
    func set_1_d() -> Void { self.registers.D = set(.Bit_1, self.registers.D) }
    func set_1_e() -> Void { self.registers.E = set(.Bit_1, self.registers.E) }
    func set_1_h() -> Void { self.registers.H = set(.Bit_1, self.registers.H) }
    func set_1_l() -> Void { self.registers.L = set(.Bit_1, self.registers.L) }
    func set_1_hlp() -> Void { mmu.write(address: self.registers.HL, val: set(.Bit_1,mmu.read(address: self.registers.HL))) }
    func set_1_a() -> Void { self.registers.A = set(.Bit_1, self.registers.A) }
    func set_2_b() -> Void { self.registers.B = set(.Bit_2, self.registers.B) }
    func set_2_c() -> Void { self.registers.C = set(.Bit_2, self.registers.C) }
    func set_2_d() -> Void { self.registers.D = set(.Bit_2, self.registers.D) }
    func set_2_e() -> Void { self.registers.E = set(.Bit_2, self.registers.E) }
    func set_2_h() -> Void { self.registers.H = set(.Bit_2, self.registers.H) }
    func set_2_l() -> Void { self.registers.L = set(.Bit_2, self.registers.L) }
    func set_2_hlp() -> Void { mmu.write(address: self.registers.HL, val: set(.Bit_2,mmu.read(address: self.registers.HL))) }
    func set_2_a() -> Void { self.registers.A = set(.Bit_2, self.registers.A) }
    func set_3_b() -> Void { self.registers.B = set(.Bit_3, self.registers.B) }
    func set_3_c() -> Void { self.registers.C = set(.Bit_3, self.registers.C) }
    func set_3_d() -> Void { self.registers.D = set(.Bit_3, self.registers.D) }
    func set_3_e() -> Void { self.registers.E = set(.Bit_3, self.registers.E) }
    func set_3_h() -> Void { self.registers.H = set(.Bit_3, self.registers.H) }
    func set_3_l() -> Void { self.registers.L = set(.Bit_3, self.registers.L) }
    func set_3_hlp() -> Void { mmu.write(address: self.registers.HL, val: set(.Bit_3,mmu.read(address: self.registers.HL))) }
    func set_3_a() -> Void { self.registers.A = set(.Bit_3, self.registers.A) }
    func set_4_b() -> Void { self.registers.B = set(.Bit_4, self.registers.B) }
    func set_4_c() -> Void { self.registers.C = set(.Bit_4, self.registers.C) }
    func set_4_d() -> Void { self.registers.D = set(.Bit_4, self.registers.D) }
    func set_4_e() -> Void { self.registers.E = set(.Bit_4, self.registers.E) }
    func set_4_h() -> Void { self.registers.H = set(.Bit_4, self.registers.H) }
    func set_4_l() -> Void { self.registers.L = set(.Bit_4, self.registers.L) }
    func set_4_hlp() -> Void { mmu.write(address: self.registers.HL, val: set(.Bit_4,mmu.read(address: self.registers.HL))) }
    func set_4_a() -> Void { self.registers.A = set(.Bit_4, self.registers.A) }
    func set_5_b() -> Void { self.registers.B = set(.Bit_5, self.registers.B) }
    func set_5_c() -> Void { self.registers.C = set(.Bit_5, self.registers.C) }
    func set_5_d() -> Void { self.registers.D = set(.Bit_5, self.registers.D) }
    func set_5_e() -> Void { self.registers.E = set(.Bit_5, self.registers.E) }
    func set_5_h() -> Void { self.registers.H = set(.Bit_5, self.registers.H) }
    func set_5_l() -> Void { self.registers.L = set(.Bit_5, self.registers.L) }
    func set_5_hlp() -> Void { mmu.write(address: self.registers.HL, val: set(.Bit_5,mmu.read(address: self.registers.HL))) }
    func set_5_a() -> Void { self.registers.A = set(.Bit_5, self.registers.A) }
    func set_6_b() -> Void { self.registers.B = set(.Bit_6, self.registers.B) }
    func set_6_c() -> Void { self.registers.C = set(.Bit_6, self.registers.C) }
    func set_6_d() -> Void { self.registers.D = set(.Bit_6, self.registers.D) }
    func set_6_e() -> Void { self.registers.E = set(.Bit_6, self.registers.E) }
    func set_6_h() -> Void { self.registers.H = set(.Bit_6, self.registers.H) }
    func set_6_l() -> Void { self.registers.L = set(.Bit_6, self.registers.L) }
    func set_6_hlp() -> Void { mmu.write(address: self.registers.HL, val: set(.Bit_6,mmu.read(address: self.registers.HL))) }
    func set_6_a() -> Void { self.registers.A = set(.Bit_6, self.registers.A) }
    func set_7_b() -> Void { self.registers.B = set(.Bit_7, self.registers.B) }
    func set_7_c() -> Void { self.registers.C = set(.Bit_7, self.registers.C) }
    func set_7_d() -> Void { self.registers.D = set(.Bit_7, self.registers.D) }
    func set_7_e() -> Void { self.registers.E = set(.Bit_7, self.registers.E) }
    func set_7_h() -> Void { self.registers.H = set(.Bit_7, self.registers.H) }
    func set_7_l() -> Void { self.registers.L = set(.Bit_7, self.registers.L) }
    func set_7_hlp() -> Void { mmu.write(address: self.registers.HL, val: set(.Bit_7,mmu.read(address: self.registers.HL))) }
    func set_7_a() -> Void { self.registers.A = set(.Bit_7, self.registers.A) }
}
