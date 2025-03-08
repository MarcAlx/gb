public enum JoyPadButtons: String {
    case A      = "button_a"
    case B      = "button_b"
    case START  = "button_start"
    case SELECT = "button_select"
    case UP     = "dpad_up"
    case DOWN   = "dpad_down"
    case LEFT   = "dpad_left"
    case RIGHT  = "dpad_right"
}

/// input buttons are considered by group
public enum ButtonGroups:Byte {
    ///A, B, Start, Select
    case BUTTONS = 0
    
    ///UP, DOWN, LEFT, RIGHT
    case DPAD    = 1
}

///To identify button modifiers
public enum ButtonModifiers: Byte {
    case BUTTONS_ACTIVE     = 0b1101_1111
    case DPAD_ACTIVE        = 0b1110_1111
    
    case ALL_RELEASED       = 0b0000_1111
    
    case START_DOWN_PRESSED = 0b1111_0111
    case SELECT_UP_PRESSED  = 0b1111_1011
    case B_LEFT_PRESSED     = 0b1111_1101
    case A_RIGHT_PRESSED    = 0b1111_1110
}

/// defines  properties used by JoyPad that must be available
public protocol JoyPadInterface {
    ///stores current buttons state, should be updated by JoyPad
    var BUTTONS_STATE:Byte { get set }
    
    ///stores current dpad state, should be updated by JoyPad
    var DPAD_STATE:Byte { get set }
}

/// wraps button logic
public class JoyPad : Component {
    
    private let ints:InterruptsControlInterface
    
    private let mmu:MMU
    
    /// map each button to its pressed state (true -> pressed, released else)
    private var buttonState:[JoyPadButtons:Bool] = [
        JoyPadButtons.A      : false,
        JoyPadButtons.B      : false,
        JoyPadButtons.START  : false,
        JoyPadButtons.SELECT : false,
        JoyPadButtons.UP     : false,
        JoyPadButtons.DOWN   : false,
        JoyPadButtons.LEFT   : false,
        JoyPadButtons.RIGHT  : false,
    ]
    
    public init(mmu:MMU){
        self.ints = mmu;
        self.mmu = mmu
    }
    
    /// Set button state (true -> pressed, released else)
    public func setButtonState(_ button: JoyPadButtons, _ state:Bool) {
        //print("\(button) - state \(state)")//for debug purpose
        
        //button goes from released to pressed -> trigger interrupt
        if(!buttonState[button]! && state){
            ints.setInterruptFlagValue(.Joypad, true);
        }
        
        buttonState[button] = state
        //ensure dpad pressed consistency
        if(button.rawValue.starts(with: "dpad")){
            self.checkDPADConsistency()
        }
        
        self.mmu.BUTTONS_STATE = self.getButtonGroupState(group: .BUTTONS)
        self.mmu.DPAD_STATE = self.getButtonGroupState(group: .DPAD)
    }
    
    /// true if button pressed
    public func isButtonPressed(_ button: JoyPadButtons) -> Bool {
        return self.buttonState[button] ?? false
    }
    
    public func reset(){
        //debounce all keys
        self.setButtonState(.A, false)
        self.setButtonState(.B, false)
        self.setButtonState(.SELECT, false)
        self.setButtonState(.START, false)
        self.setButtonState(.UP, false)
        self.setButtonState(.DOWN, false)
        self.setButtonState(.LEFT, false)
        self.setButtonState(.RIGHT, false)
    }
    
    /// Avoid two opposites directions being pressed at the same time, it's not possible on real hardware, and it may break some games
    private func checkDPADConsistency() {
        if(self.isButtonPressed(.LEFT) && self.isButtonPressed(.RIGHT)){
            self.buttonState[JoyPadButtons.RIGHT] = false
        }
        if(self.isButtonPressed(.UP) && self.isButtonPressed(.DOWN)){
            self.buttonState[JoyPadButtons.DOWN] = false
        }
    }
    
    /// return a byte representing lower nibble of joypad input according to concerned button group selected
    public func getButtonGroupState(group: ButtonGroups) -> Byte {
        var res = ButtonModifiers.ALL_RELEASED.rawValue
        
        if(group == ButtonGroups.BUTTONS){
            if(self.isButtonPressed(.A)){
                res &= ButtonModifiers.A_RIGHT_PRESSED.rawValue
            }
            if(self.isButtonPressed(.B)){
                res &= ButtonModifiers.B_LEFT_PRESSED.rawValue
            }
            if(self.isButtonPressed(.START)){
                res &= ButtonModifiers.START_DOWN_PRESSED.rawValue
            }
            if(self.isButtonPressed(.SELECT)){
                res &= ButtonModifiers.SELECT_UP_PRESSED.rawValue
            }
        }
        else if(group == ButtonGroups.DPAD){
            if(self.isButtonPressed(.RIGHT)){
                res &= ButtonModifiers.A_RIGHT_PRESSED.rawValue
            }
            if(self.isButtonPressed(.LEFT)){
                res &= ButtonModifiers.B_LEFT_PRESSED.rawValue
            }
            if(self.isButtonPressed(.DOWN)){
                res &= ButtonModifiers.START_DOWN_PRESSED.rawValue
            }
            if(self.isButtonPressed(.UP)){
                res &= ButtonModifiers.SELECT_UP_PRESSED.rawValue
            }
        }
        
        return res;
    }
}
