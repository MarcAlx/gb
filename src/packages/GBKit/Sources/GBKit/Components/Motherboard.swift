public class Motherboard: Clockable {
    private(set) public var insertedCartridge:Cartridge? = nil
    public private(set) var cycles:Int = 0
    private(set) public var isOn:Bool = false
    
    public let cpu:CPU
    public let mmu:MMU
    public let ppu:PPU
    public let apu:APU
    public let timer:Timer
    public let joypad:JoyPad
    
    public var hasCartridgeInserted:Bool {
        get {
            return self.insertedCartridge != nil
        }
    }
    
    public init() {
        self.mmu = MMU()
        self.ppu = PPU(mmu: self.mmu, pm: PaletteManager.sharedInstance)
        self.cpu = CPU(mmu: self.mmu)
        self.apu = APU(mmu: self.mmu)
        self.joypad = JoyPad(mmu: self.mmu)
        self.timer = Timer(mmu: self.mmu)
    }
    
    public func insert(cartridge:Cartridge) {
        self.insertedCartridge = cartridge
    }
    
    private func reset() {
        self.mmu.reset()
        self.cpu.reset()
        self.ppu.reset()
        self.apu.reset()
        self.timer.reset()
        self.joypad.reset()
    }
    
    public func powerOn() {
        if(self.hasCartridgeInserted) {
            self.reset()
            self.mmu.loadCartridge(cartridge: self.insertedCartridge!)
            GBLogService.log(LogCategory.MOTHERBOARD,"# \(self.cpu.registers.describe())")
        }
        self.isOn = true
    }
    
    public func powerOff() {
        self.isOn = false
        self.ppu.flush()//flush to avoid remaining graphics when off
    }
    
    public func tick(_ masterCycles:Int, _ frameCycles:Int) {
        self.cycles = self.cycles &+ GBConstants.MCycleLength
    }
    
    public func update() {
        if(self.isOn && self.hasCartridgeInserted) {
            var tmpCycles = 0
            while(tmpCycles < GBConstants.MCyclesPerFrame){
                self.timer.tick(self.cycles, tmpCycles)
                self.cpu.tick(self.cycles, tmpCycles)
                self.mmu.tick(self.cycles, tmpCycles)
                self.ppu.tick(self.cycles, tmpCycles)
                self.apu.tick(self.cycles, tmpCycles)
                ////check interrupts
                self.cpu.handleInterrupts()
                self.tick(self.cycles, tmpCycles)
                tmpCycles += GBConstants.MCycleLength
            }
        }
    }
}

///a motherboard component
public protocol Component {
    ///resets this component
    func reset()
}

public protocol Clockable {
    ///cycles this clock has elapsed
    var cycles:Int {get}
    
    /// perform a single tick on a clock, masterCycles and frameCycles  are provided for synchronisation purpose
    func tick(_ masterCycles:Int, _ frameCycles:Int) -> Void
}
