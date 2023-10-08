import SwiftUI

/**
 * View Model to interface GaemBoy core
 */
public class GameBoyViewModel:ObservableObject {
    ///error view model to notify errors
    public var errorViewModel:ErrorViewModel?
    
    private let gb:GameBoy = GameBoy()
    private var previousTime:Double = Date().timeIntervalSince1970
    @Published public var isOn:Bool = false
    
    /*
     * used to act at every frame
     */
    private var displayLink:CADisplayLink = CADisplayLink()
    
    /**
     * perform work on dedicated queue
     */
    private let workQueue:DispatchQueue
    
    public init() {
        self.workQueue = DispatchQueue(label: "gb serial queue", qos:.userInitiated)
        self.initDisplayLink()
    }
    
    ///init display link to setup framerate
    private func initDisplayLink() {
        self.displayLink = CADisplayLink(target: self, selector: #selector(update))
        //lock framerate, some device could go up to 120
        self.displayLink.preferredFrameRateRange = CAFrameRateRange(minimum: PreferredFrameRate, maximum: PreferredFrameRate, preferred: PreferredFrameRate)
        self.displayLink.isPaused = true
        self.displayLink.add(to: .current, forMode: .common)
    }
    
    ///turn on system
    public func turnOn() {
        self.previousTime = self.displayLink.timestamp
        self.displayLink.isPaused = false
        self.gb.turnOn()
        self.isOn = self.gb.isOn
    }
    
    ///turn off system
    public func turnOff() {
        self.displayLink.isPaused = true
        self.gb.turnOff()
        self.isOn = self.gb.isOn
    }
    
    ///insert cartridge
    public func insert(cartridge:Cartridge) {
        self.gb.insert(cartridge: cartridge)
    }
    
    ///called every frame by CADisplayLink
    @objc func update() {
        workQueue.sync {
            self.gb.update()
        }
    }
}
