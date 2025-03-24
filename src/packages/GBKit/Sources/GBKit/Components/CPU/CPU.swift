// CPU states
public enum CPUState {
    //CPU is running
    case RUNNING
    //CPU is in panic (error case)
    case PANIC
    //CPU is halted (via HALT 0x76)
    case HALTED
    //CPU is stopped (via STOP 0x10)
    case STOPPED
}

public class CPU: CPUImplementation, Clockable {
    public override func reset() {
        self.cycles = 0
        super.reset()
        self.state = CPUState.RUNNING
    }
    
    var standardInstructionSet:[Instruction] = []
    var extendedInstructionSet:[Instruction] = []
    
    public override init(mmu: MMU) {
        super.init(mmu: mmu)
        self.standardInstructionSet = self.asStandardInstructions()
        self.extendedInstructionSet = self.asExtentedInstructions()
    }
    
    public func tick(_ masterCycles:Int, _ frameCycles:Int) {
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
            //let pc = self.registers.PC
            //if(pc == 0x01D2){
            //    print("add breakpoint here")
            //}
            
            //print(self.registers.describe())
            
            //fetch
            let opCodeInstr = self.fetch() //on real hardware fetch are done during last 4 cycles of previous instuction, but as cycles are incremented during execute, don't care
            //decode
            let instruction = self.decode(opCode:opCodeInstr.0,instr:opCodeInstr.1)
            //execute
            let duration = self.execute(instruction: instruction)
            self.cycles = self.cycles &+ duration
            //print(self.registers.describe())
        }
    }
    
    private func decode(opCode:OperationCode,instr:[Instruction]) -> Instruction {
        return instr[Int(opCode.code)]
    }
    
    /// fetch an opcode from PC
    /// - returns a tuple with a bool that indicates if opcode is extended, and the fetched opcode
    private func fetch() -> (OperationCode,[Instruction]) {
        //return ((false, 0x21),standardInstructionSet)
        let opCode = self.readIncrPC()
        if opCode == GBConstants.ExtentedInstructionSetOpcode {
            return ((true, self.readIncrPC()),extendedInstructionSet)
        }
        return ((false,opCode),standardInstructionSet)
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
            let lsb = self.readIncrPC()
            let msb = self.readIncrPC()
            let arg = EnhancedShort(lsb,msb)
            //LogService.log(LogCategory.CPU,"; \(String(format: instruction.name, arg.value))")
            instruction.execute(arg)
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
                self.handleInterrupt(.Timer, ReservedMemoryLocationAddresses.INTERRUPT_TIMER.rawValue)
            }
            if(self.interrupts.isInterruptEnabled(.Serial) && self.interrupts.isInterruptFlagged(.Serial)){
                self.handleInterrupt(.Serial, ReservedMemoryLocationAddresses.INTERRUPT_SERIAL.rawValue)
            }
            if(self.interrupts.isInterruptEnabled(.Joypad) && self.interrupts.isInterruptFlagged(.Joypad)){
                self.handleInterrupt(.Joypad, ReservedMemoryLocationAddresses.INTERRUPT_JOYPAD.rawValue)
            }
        }
    }
}
