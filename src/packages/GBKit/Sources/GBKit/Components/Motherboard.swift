class Motherboard: Clockable {
    public static let sharedInstance = Motherboard()
    
    private(set) public var insertedCartridge:Cartridge? = nil
    public private(set) var cycles:Int = 0
    private(set) public var isOn:Bool = false
    
    private let cpu:CPU = CPU.sharedInstance
    private let mmu:MMU = MMU.sharedInstance
    private let ppu:PPU = PPU.sharedInstance
    private let ios:IOInterface = IOInterface.sharedInstance
    private let interrupts:Interrupts = Interrupts.sharedInstance
    public  let joypad:JoyPadInterface = JoyPadInterface.sharedInstance
    
    public var hasCartridgeInserted:Bool {
        get {
            return self.insertedCartridge != nil
        }
    }
    
    private init() {
    }
    
    public func insert(cartridge:Cartridge) {
        self.insertedCartridge = cartridge
    }
    
    private func reset() {
        self.mmu.reset()
        self.cpu.reset()
        self.ppu.reset()
        self.ios.reset()
        self.joypad.reset()
        self.interrupts.reset()
    }
    
    public func powerUp() {
        if(self.hasCartridgeInserted) {
            self.reset()
            self.mmu.loadCartridge(cartridge: self.insertedCartridge!)
            GBLogService.log(LogCategory.MOTHERBOARD,"# \(self.cpu.registers.describe())")
        }
        self.isOn = true
    }
    
    public func powerOff() {
        self.isOn = false
    }
    
    public func tick(_ masterCycles:Int, _ frameCycles:Int) {
        self.cycles = self.cycles &+ 4
    }
    
    public func update() {
        if(self.isOn && self.hasCartridgeInserted) {
            var tmpCycles = 0
            while(tmpCycles < GBConstants.MCyclesPerFrame){
                self.cpu.tick(self.cycles, tmpCycles)
                self.mmu.tick(self.cycles, tmpCycles)
                self.ppu.tick(self.cycles, tmpCycles)
                ////check interrupts
                self.cpu.handleInterrupts()
                self.tick(self.cycles, tmpCycles)
                tmpCycles += GBConstants.TCycleLength
            }
        }
    }
}

///a motherboard component
protocol Component {
    ///resets this component
    func reset()
}

public protocol Clockable {
    ///cycles this clock has elapsed
    var cycles:Int {get}
    
    /// perform a single tick on a clock, masterCycles and frameCycles  are provided for synchronisation purpose
    func tick(_ masterCycles:Int, _ frameCycles:Int) -> Void
}
