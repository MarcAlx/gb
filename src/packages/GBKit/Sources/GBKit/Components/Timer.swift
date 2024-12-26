///wraps timer logic
class TimerInterface : Component, Clockable {
    public static let sharedInstance = TimerInterface()
    
    private let mmu:MMU = MMU.sharedInstance
    
    ///cycles this clock has elapsed
    var cycles: Int = 0
    
    /// perform a single tick on a clock, masterCycles and frameCycles  are provided for synchronisation purpose
    func tick(_ masterCycles:Int, _ frameCycles:Int) -> Void {
        //DIV ticks every 64 M so 256 T
        if(masterCycles % 64 == 0){
            var val:Byte = self.mmu.read(address: IOAddresses.DIV.rawValue) &+ 1
            self.mmu.directWrite(address: IOAddresses.DIV.rawValue, val: val)
        }
        
        self.cycles = self.cycles &+ GBConstants.TCycleLength
    }
    
    public func reset(){
    }
}
