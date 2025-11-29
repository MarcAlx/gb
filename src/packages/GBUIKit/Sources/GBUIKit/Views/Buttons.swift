import SwiftUI
import GBKit
import SpriteKit

/// button mapping configuration
class ButtonMapping: ObservableObject {
    @Published var forButtonA:Int = UIKeyboardHIDUsage.keyboardX.rawValue
    @Published var forButtonB:Int = UIKeyboardHIDUsage.keyboardC.rawValue
    @Published var forButtonStart:Int = UIKeyboardHIDUsage.keyboardSpacebar.rawValue
    @Published var forButtonSelect:Int = UIKeyboardHIDUsage.keyboardV.rawValue
    @Published var forButtonUp:Int = UIKeyboardHIDUsage.keyboardUpArrow.rawValue
    @Published var forButtonDown:Int = UIKeyboardHIDUsage.keyboardDownArrow.rawValue
    @Published var forButtonLeft:Int = UIKeyboardHIDUsage.keyboardLeftArrow.rawValue
    @Published var forButtonRight:Int = UIKeyboardHIDUsage.keyboardRightArrow.rawValue
}

/// focusable SKView that watches key presses
class FocusableSKView: SKView {
    private var gVM:GameBoyViewModel = GameBoyViewModel()
    
    override var canBecomeFirstResponder: Bool { true }
    
    private var buttonMapping:ButtonMapping = ButtonMapping()
    
    public func with(gvm:GameBoyViewModel, andMapping:ButtonMapping)-> FocusableSKView{
        self.gVM = gvm
        self.buttonMapping = andMapping
        return self
    }
    
    override func didMoveToWindow() {
        super.didMoveToWindow()
        //ensure always first responder
        self.becomeFirstResponder()
    }
    
    //TODO add Keyboard mapper (Button -> UIKeyboardHIDUsage)
    
    private func checkKeys(_ presses: Set<UIPress>, pressed:Bool){
        for press in presses {
            if let key = press.key {
                if(key.keyCode.rawValue == self.buttonMapping.forButtonLeft)
                {
                    self.gVM.setButtonState(.LEFT, pressed)
                }
                else if(key.keyCode.rawValue == self.buttonMapping.forButtonRight)
                {
                    self.gVM.setButtonState(.RIGHT, pressed)
                }
                else if(key.keyCode.rawValue == self.buttonMapping.forButtonUp)
                {
                    self.gVM.setButtonState(.UP, pressed)
                }
                else if(key.keyCode.rawValue == self.buttonMapping.forButtonDown)
                {
                    self.gVM.setButtonState(.DOWN, pressed)
                }
                else if(key.keyCode.rawValue == self.buttonMapping.forButtonA)
                {
                    self.gVM.setButtonState(.A, pressed)
                }
                else if(key.keyCode.rawValue == self.buttonMapping.forButtonB)
                {
                    self.gVM.setButtonState(.B, pressed)
                }
                else if(key.keyCode.rawValue == self.buttonMapping.forButtonStart)
                {
                    self.gVM.setButtonState(.START, pressed)
                }
                else if(key.keyCode.rawValue == self.buttonMapping.forButtonSelect)
                {
                    self.gVM.setButtonState(.SELECT, pressed)
                }
            }
        }
    }

    override func pressesBegan(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
        checkKeys(presses, pressed: true)
    }
    
    override func pressesEnded(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
        checkKeys(presses, pressed: false)
    }
}

///switui view to to present FocusableSKView
struct FocusedSpriteKitView: UIViewRepresentable {
    
    @EnvironmentObject private var gVM:GameBoyViewModel
    @EnvironmentObject private var buttonMapping:ButtonMapping
    
    func makeUIView(context: Context) -> FocusableSKView {
        let view = FocusableSKView().with(gvm: self.gVM, andMapping: self.buttonMapping)
        
        // Delay focus slightly to ensure the view is in window
        DispatchQueue.main.async {
            view.becomeFirstResponder()
        }
        return view
    }

    func updateUIView(_ uiView: FocusableSKView, context: Context) {}
}

/// button to enter/leave fullscreen
struct FullScreenButton: View {
    @EnvironmentObject private var mVM:MainViewModel
    
    var body: some View {
        Button {
            self.mVM.isFullScreen = !self.mVM.isFullScreen
        } label: {
            if(!self.mVM.isFullScreen){
                Label("",systemImage: "arrow.down.left.and.arrow.up.right")
            }
            else {
                Label("Leave full screen",systemImage: "arrow.up.right.and.arrow.down.left")
            }
        }
    }
}

///button to insert cartridge
struct InsertButton: View {
    @EnvironmentObject private var mVM:MainViewModel
    @EnvironmentObject private var gVM:GameBoyViewModel
    
    var body: some View {
        Button {
            self.mVM.fileImporterPresented = true
        } label: {
            Label("button.insertCartridge".localized,systemImage: "square.and.arrow.down")
        }.disabled(self.gVM.isOn)
    }
}

///button to turn on / off
struct OnOffSwitch: View {
    @EnvironmentObject private var gVM:GameBoyViewModel
    
    var body: some View {
        Toggle(isOn: self.$gVM.isOn){
            Label(self.gVM.isOn ? "toggle.isOn.true".localized : "toggle.isOn.false".localized,
                  systemImage: self.gVM.isOn ? "lightswitch.off" : "lightswitch.on" ).frame(maxWidth: .infinity, alignment: .trailing)
        }.onChange(of: self.gVM.isOn) { value in
            if(value)  {
                self.gVM.turnOn()
            }
            else {
                self.gVM.turnOff()
            }
        }
    }
}

/// a tuple that wraps background of button, foreground and associated joypad
typealias ButtonNode = (bg:SKShapeNode, fg:SKSpriteNode, joypadButton:JoyPadButtons, bgColor:UIColor, fgColor:UIColor, pressedColor:UIColor)

/// check GVM for a given ButtonNode
func check(gvm:GameBoyViewModel, forButton:ButtonNode) {
    if(gvm.pressedButtons.contains(forButton.joypadButton)){
        forButton.bg.fillColor = forButton.pressedColor
    }
    else if(!gvm.pressedButtons.contains(forButton.joypadButton)){
        forButton.bg.fillColor = forButton.bgColor
    }
}

/// checks if button node is in a given set of node
/// if so corresponding button state is set with value,
/// otherwise iif debounce parameter is set opossite value is forwarded
func check(nodes:[SKNode], forButton:ButtonNode, withValue:Bool, withGMV:GameBoyViewModel, debounce:Bool = false) {
    if (nodes.contains(forButton.bg) || nodes.contains(forButton.fg)) {
        withGMV.setButtonState(forButton.joypadButton, withValue)
    }
    else if(debounce) {
        withGMV.setButtonState(forButton.joypadButton, !withValue)
    }
}

/// a group of button (like a DPAD) mean't to be extented
class ButtonGroup: SKScene {
    var gVM:GameBoyViewModel = GameBoyViewModel()
    var buttonNodes:[ButtonNode] = []
    
    /// init nodes in scene
    func initNodes () {
    }
    
    public func withGVM(gvm:GameBoyViewModel) -> ButtonGroup {
        self.gVM = gvm
        return self
    }
    
    ///button used with round corner and symbol from SFPro
    func buildSymbolButton(_ position:CGPoint,_ buttonSize:Int,_ symbol:String, _ forButton: JoyPadButtons, _ bgColor:UIColor, _ fgColor:UIColor, _ pressedColor:UIColor) -> ButtonNode {
        var backgroundNode = SKShapeNode(rect: CGRect(x: Int(position.x), y: Int(position.y), width: buttonSize, height: buttonSize), cornerRadius: 5)
        backgroundNode.fillColor = bgColor
        backgroundNode.strokeColor = .clear
        
        var symbolNode:SKSpriteNode = SKSpriteNode()
        if let image = UIImage(systemName: symbol) {
            let texture = SKTexture(image: image)
            let symbolNode = SKSpriteNode(texture: texture)
            symbolNode.size = CGSize(width: buttonSize/2, height: buttonSize/2)
            symbolNode.color = fgColor//can't be set
            symbolNode.colorBlendFactor = 1.0
            symbolNode.position = CGPoint(x: position.x + Double(buttonSize/4),y: position.y+Double(buttonSize/4))
            symbolNode.texture?.filteringMode = .nearest//no blur
            symbolNode.anchorPoint = CGPoint(x: 0, y: 0)
            backgroundNode.addChild(symbolNode)
        }
        
        return (bg:backgroundNode,
                fg:symbolNode,
                joypadButton: forButton,
                bgColor:bgColor,
                fgColor:fgColor,
                pressedColor:pressedColor)
    }
    
    /// a round button
    func buildRoundButton(_ position:CGPoint,_ buttonSize:Int,_ text:String,_ forButton: JoyPadButtons, _ bgColor:UIColor, _ fgColor:UIColor, _ pressedColor:UIColor) -> ButtonNode {
        
        var backgroundNode = SKShapeNode(circleOfRadius: CGFloat(buttonSize/2))
        backgroundNode.position = position
        backgroundNode.strokeColor = UIColor.clear
        backgroundNode.fillColor = .darkGray
        
        var textNode = SKLabelNode(text: text)
        textNode.fontColor = fgColor
        textNode.fontName = "Futura"
        textNode.fontSize = 20
        
        backgroundNode.addChild(textNode)
        
        return (bg:backgroundNode,
                fg:SKSpriteNode(),
                joypadButton: forButton,
                bgColor:bgColor,
                fgColor:fgColor,
                pressedColor:pressedColor)
    }
    
    /// a small button
    func buildSmallButton(_ position:CGPoint,_ buttonSize:Int,_ text:String,_ forButton: JoyPadButtons, _ bgColor:UIColor, _ fgColor:UIColor, _ pressedColor:UIColor) -> ButtonNode {
        
        var backgroundNode = SKShapeNode(rectOf: CGSize(width: buttonSize, height: 10), cornerRadius: 5)
        backgroundNode.position = position
        backgroundNode.strokeColor = UIColor.clear
        backgroundNode.fillColor = .darkGray
        backgroundNode.zRotation = .pi/4
        
        var textNode = SKLabelNode(text: text)
        textNode.fontColor = fgColor
        textNode.fontName = "Futura"
        textNode.position = CGPoint(x: 0, y: -20)
        textNode.fontSize = 15
        
        backgroundNode.addChild(textNode)
        
        return (bg:backgroundNode,
                fg:SKSpriteNode(),
                joypadButton: forButton,
                bgColor:bgColor,
                fgColor:fgColor,
                pressedColor:pressedColor)
    }
    
    //called once, when scene is presented
    override func didMove(to view: SKView) {
        self.initNodes()
    }
    
    /// called every frame, for framerate see SpriteView initialization
    override func update(_ currentTime: TimeInterval) {
        for var node in buttonNodes {
            check(gvm: self.gVM, forButton: node)
        }
    }
    
    /// when touch start
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            for var node in buttonNodes {
                check(nodes: nodes(at: location), forButton: node, withValue: true, withGMV:self.gVM)
            }
        }
    }
    
    ///when touch move
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            for var node in buttonNodes {
                check(nodes: nodes(at: location), forButton: node, withValue: true, withGMV:self.gVM, debounce: true)
            }
        }
    }
    
    /// when touch end
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            for var node in buttonNodes {
                check(nodes: nodes(at: location), forButton: node, withValue: false, withGMV:self.gVM)
            }
        }
    }
}

///scene to display button, swiftUI will cause slowdown on button press else
class DPadScene: ButtonGroup {
    
    private var leftButton:ButtonNode  = (SKShapeNode(), SKSpriteNode(), .LEFT,  .blue, .red, .yellow)
    private var rightButton:ButtonNode = (SKShapeNode(), SKSpriteNode(), .RIGHT, .blue, .red, .yellow)
    private var upButton:ButtonNode    = (SKShapeNode(), SKSpriteNode(), .UP,    .blue, .red, .yellow)
    private var downButton:ButtonNode  = (SKShapeNode(), SKSpriteNode(), .DOWN,  .blue, .red, .yellow)
    
    override func initNodes () {
        let buttonSize:Int = Int(self.size.width)/4
        
        self.backgroundColor = .white
        
        //round bg (for now hidden)
        var bg = SKShapeNode(circleOfRadius: 100 ) // Size of Circle
        bg.position = CGPointMake(frame.midX, frame.midY)  //Middle of Screen
        bg.strokeColor = UIColor.clear
        bg.fillColor = UIColor.clear
        self.addChild(bg)
        
        let bgColor:UIColor = .gray
        let fgColor:UIColor = .black
        let pressedColor:UIColor = .lightGray
        
        //center
        let padding = 8
        let centerX:Int = Int(1.5*Double(buttonSize))-Int(padding/2)
        let centerY:Int = Int(1.5*Double(buttonSize))-Int(padding/2)
        let center = SKShapeNode(rect: CGRect(x: centerX, y: centerY, width: buttonSize+padding, height: buttonSize+padding),cornerRadius: 4)
        center.fillColor = bgColor
        center.strokeColor = .clear
        self.addChild(center)
        
        let left  = CGPoint(x: 0.5 * Double(buttonSize), y: 1.5 * Double(buttonSize))
        let up    = CGPoint(x: 1.5 * Double(buttonSize), y: 2.5 * Double(buttonSize))
        let down  = CGPoint(x: 1.5 * Double(buttonSize), y: 0.5 * Double(buttonSize))
        let right = CGPoint(x: 2.5 * Double(buttonSize), y: 1.5 * Double(buttonSize))
        
        self.upButton   = self.buildSymbolButton(up,    buttonSize, "arrowtriangle.up",    .UP,   bgColor, fgColor, pressedColor)
        self.downButton = self.buildSymbolButton(down,  buttonSize, "arrowtriangle.down",  .DOWN, bgColor, fgColor, pressedColor)
        self.leftButton = self.buildSymbolButton(left,  buttonSize, "arrowtriangle.left",  .LEFT, bgColor, fgColor, pressedColor)
        self.rightButton = self.buildSymbolButton(right,buttonSize, "arrowtriangle.right", .RIGHT,bgColor, fgColor, pressedColor)
        
        self.addChild(self.upButton.bg)
        self.addChild(self.downButton.bg)
        self.addChild(self.leftButton.bg)
        self.addChild(self.rightButton.bg)
        
        self.buttonNodes = [self.leftButton, self.rightButton, self.upButton, self.downButton]
    }
}

///scene to display button, swiftUI will cause slowdown on button press else
class ABStartSelectScene: ButtonGroup {
    
    private var aButton:ButtonNode      = (SKShapeNode(), SKSpriteNode(), .A,      .blue, .red, .yellow)
    private var bButton:ButtonNode      = (SKShapeNode(), SKSpriteNode(), .B,      .blue, .red, .yellow)
    private var startButton:ButtonNode  = (SKShapeNode(), SKSpriteNode(), .START,  .blue, .red, .yellow)
    private var selectButton:ButtonNode = (SKShapeNode(), SKSpriteNode(), .SELECT, .blue, .red, .yellow)
    
    override func initNodes () {
        let buttonSize:Int = Int(self.size.width)/4
        
        self.backgroundColor = .white
        
        let abColor:UIColor = UIColor(red: 136/255.0,green: 31/255.0,blue: 69/255.0,alpha: 1.0)
        let abFGColor:UIColor = UIColor(red: 35/255.0,green: 37/255.0,blue: 127/255.0,alpha: 1.0)
        let abColorPressed:UIColor = UIColor(red: 166/255.0,green: 87/255.0,blue: 115/255.0,alpha: 1.0)
        let startSelectColor:UIColor = UIColor(red: 124/255.0,green: 124/255.0,blue: 124/255.0,alpha: 1.0)
        let startSelectFGColor:UIColor = UIColor(red: 35/255.0,green: 37/255.0,blue: 127/255.0,alpha: 1.0)
        let startSelectColorPressed:UIColor = UIColor(red: 206/255.0,green: 206/255.0,blue: 206/255.0,alpha: 1.0)
        
        let left  = CGPoint(x: 0.9 * Double(buttonSize), y: 2.0 * Double(buttonSize))
        let up    = CGPoint(x: 1.9 * Double(buttonSize), y: 3.0 * Double(buttonSize))
        let down  = CGPoint(x: 2.0 * Double(buttonSize), y: 1.0 * Double(buttonSize))
        let right = CGPoint(x: 3.0 * Double(buttonSize), y: 2.0 * Double(buttonSize))
        self.aButton = self.buildRoundButton(down,       buttonSize, "A", .A, abColor, abFGColor, abColorPressed)
        self.bButton = self.buildRoundButton(right,      buttonSize, "B", .B,abColor, abFGColor, abColorPressed)
        self.selectButton = self.buildSmallButton(left,  buttonSize, "select", .SELECT,startSelectColor, startSelectFGColor, startSelectColorPressed)
        self.startButton = self.buildSmallButton(up,     buttonSize, "start", .START,startSelectColor, startSelectFGColor, startSelectColorPressed)
        self.addChild(self.aButton.bg)
        self.addChild(self.bButton.bg)
        self.addChild(self.selectButton.bg)
        self.addChild(self.startButton.bg)
        self.buttonNodes = [self.aButton, self.bButton, self.startButton, self.selectButton]
    }
}

struct DPad: View {
    @EnvironmentObject private var gVM:GameBoyViewModel

    var body: some View {
        SpriteView(scene: DPadScene(size: CGSize(width: 200, height: 200)).withGVM(gvm: gVM),
                   preferredFramesPerSecond: 60).frame(width: 200, height: 200)
    }
}

struct ABStartSelect: View {
    @EnvironmentObject private var gVM:GameBoyViewModel

    var body: some View {
        SpriteView(scene: ABStartSelectScene(size: CGSize(width: 200, height: 200)).withGVM(gvm: gVM),
                   preferredFramesPerSecond: 60).frame(width: 200, height: 200)
    }
}

//style to prevent button from changing opacity on press
struct NoOpacityChangeButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label // Keep the label unchanged
    }
}
