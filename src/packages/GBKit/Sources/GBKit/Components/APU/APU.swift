public class APU: Component, Clockable {
    
    public private(set) var cycles:Int = 0
    
    private let mmu:MMU
    
    init(mmu:MMU) {
        self.mmu = mmu
    }
    
    public func tick(_ masterCycles: Int, _ frameCycles: Int) {
        self.cycles = self.cycles &+ 4
    }
    
    func reset() {
        self.cycles = 0
    }
    
}
