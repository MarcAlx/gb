import Foundation

public class GameBoy {
    ///underlaying motherboard
    public let motherboard:Motherboard = Motherboard()
    
    ///true if is turned on
    public var isOn:Bool {
        get {
            return self.motherboard.isOn
        }
    }
    
    public init() {
    }

    ///insert a cartridge
    public func insert(cartridge:Cartridge) {
        self.motherboard.insert(cartridge: cartridge)
    }
    
    ///turn on system
    public func turnOn() {
        self.motherboard.powerOn()
    }
    
    ///turn off system
    public func turnOff() {
        self.motherboard.powerOff()
    }
    
    /// set button state (true = pressed, released else)
    public func setButtonState(_ button: JoyPadButtons, _ state:Bool) {
        self.motherboard.joypad.setButtonState(button, state)
    }
    
    ///update method should be called every frame
    public func update() {
        self.motherboard.update()
    }
    
    /// current framebuffer
    public var frameBuffer:Data {
        self.motherboard.ppu.frameBuffer
    }
    
    /// current audio buffer
    public var audioBuffer:[AudioSample] {
        self.motherboard.apu.audioBuffer
    }
    
    /// apu configuration
    public var apuConfiguration:APUConfiguration {
        set {
            self.motherboard.apu.configuration = newValue
        }
        
        get {
            self.motherboard.apu.configuration
        }
    }
}
