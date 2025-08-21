import SwiftUI
import GBKit
import QuartzCore

/**
 * View Model to interface GaemBoy core
 */
public class GameBoyViewModel:ObservableObject {
    ///error view model to notify errors
    @EnvironmentObject public var errorViewModel:ErrorViewModel
    
    public let gb:GameBoy
    private var previousTime:Double = Date().timeIntervalSince1970
    @Published public var isOn:Bool = false
    @Published public var pressedButtons:Set<JoyPadButtons> = Set<JoyPadButtons>()
    private var pButtons:Set<JoyPadButtons> = Set<JoyPadButtons>()
    
    /// for audio playback
    let audioManager:AudioManager
    
    /*
     * used to act at every frame
     */
    private var displayLink:CADisplayLink = CADisplayLink()
    
    /**
     * perform work on dedicated queue
     */
    private let workQueue:DispatchQueue
    
    public init() {
        let gb = GameBoy();
        self.gb = gb
        self.workQueue = DispatchQueue(label: "gb serial queue", qos:.userInteractive)
        //init audio playback
        self.audioManager = AudioManager(frequency: 44_100 /*44,1 KHz*/, gb: gb)
        //init video rendering
        self.initDisplayLink()
    }
    
    ///init display link to setup framerate
    private func initDisplayLink() {
        self.displayLink = CADisplayLink(target: self, selector: #selector(update))
        //lock framerate (to what the GB is)
        self.displayLink.preferredFrameRateRange = CAFrameRateRange(minimum: GBConstants.ExactFrameRate, maximum: GBConstants.ExactFrameRate, preferred: GBConstants.ExactFrameRate)
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
    
    /// set button state (true = pressed, released else)
    public func setButtonState(_ button: JoyPadButtons, _ state:Bool) {
        var actualState = self.pButtons.contains(button)
        if(state){
            self.pButtons.insert(button)
        }
        else {
            self.pButtons.remove(button)
        }
        
        //n.b do not use pressedButtons to avoid SwiftUI slowdown
        
        if(state != actualState){
            self.gb.setButtonState(button, state)
        }
    }
    
    ///insert cartridge
    public func insert(cartridge:Cartridge) {
        self.gb.insert(cartridge: cartridge)
    }
    
    ///called every frame by CADisplayLink
    @objc func update() {
        workQueue.sync {
            self.gb.update()
            
            //let currentTime = Date().timeIntervalSince1970
            //let ellapsedTime = currentTime - self.previousTime
            //self.previousTime = currentTime
            //1/ellapsedTime
            
            // official from doc seems too stable
            //1.0 / (self.displayLink.targetTimestamp - self.displayLink.timestamp)
            
            //duration seems computed from preferredFrameRateRange, so it's not accurate
            //1.0 / self.displayLink!.duration
        }
    }
}
