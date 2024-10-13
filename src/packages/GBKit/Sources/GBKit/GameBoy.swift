public class GameBoy {
    ///underlaying motherboard
    private let motherboard:Motherboard = Motherboard.sharedInstance
    
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
        self.motherboard.powerUp()
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
}
