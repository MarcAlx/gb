/// maps Timer clock mode to its corresponding M cycle frequency
public let TimerClockModeToFrequency:[Byte] = [
    64, // 0b00
    1,  // 0b01
    4,  // 0b10
    8   // 0b11
]

///wraps timer logic
public class TimerInterface : Component, Clockable {
    private let mmu:MMU
    private let interrupts:InterruptsControlInterface
    
    public init(mmu: MMU) {
        self.mmu = mmu
        self.interrupts = mmu
    }
    
    ///cycles this clock has elapsed
    public private(set) var cycles: Int = 0
    
    /// perform a single tick on a clock, masterCycles and frameCycles  are provided for synchronisation purpose
    public func tick(_ masterCycles:Int, _ frameCycles:Int) -> Void {
        //update div
        if(masterCycles % GBConstants.DivTimerFrequency == 0){
            var val:Byte = self.mmu.read(address: IOAddresses.DIV.rawValue) &+ 1
            self.mmu.directWrite(address: IOAddresses.DIV.rawValue, val: val)
        }
        
        //check if TAC is enable and corresponding frequency to increment TMA
        if(isBitSet(.Bit_2, self.mmu[IOAddresses.TAC.rawValue])
        && masterCycles % Int(TacClockFrequency) == 0){
            var curTima:Byte = self.mmu.read(address: IOAddresses.TIMA.rawValue)
            var newTima:Byte = curTima &+ self.TacClockFrequency
            //newTima is over cur value increments TIMA, otherwise (overflow) resets to the value stored at TMA
            if(curTima<newTima){
                self.mmu.directWrite(address: IOAddresses.TIMA.rawValue, val: newTima)
            }
            else {
                //timer modulo
                var tma:Byte = self.mmu.read(address: IOAddresses.TMA.rawValue)
                self.mmu.directWrite(address: IOAddresses.TIMA.rawValue, val: tma)
                //trigger interrupt
                self.interrupts.setInterruptFlagValue(.Timer, true)
            }
        }
        
        self.cycles = self.cycles &+ GBConstants.TCycleLength
    }
    
    //Tac clock frequency in M-cycles as expressed by Tac mode
    private var TacClockFrequency:Byte {
        get {
            return TimerClockModeToFrequency[Int(self.mmu[IOAddresses.TAC.rawValue] & 0b0000_0011 /*keep only first two bits*/)]
        }
    }
    
    public func reset(){
    }
}
