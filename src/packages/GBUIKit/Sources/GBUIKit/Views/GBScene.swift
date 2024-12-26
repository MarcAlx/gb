import SwiftUI
import GameController
import SpriteKit
import GBKit

public struct GBScene: Scene {
      
    @ObservedObject private var lVM:LoggingViewModel = LoggingViewModel()
    @ObservedObject private var eVM:ErrorViewModel = ErrorViewModel()
    @ObservedObject private var mVM:MainViewModel = MainViewModel()
    @ObservedObject private var gVM:GameBoyViewModel = GameBoyViewModel()
    
    @FocusState private var isFocused: Bool
    
    //the scene displayed in screen
    private let scene:GameScene
    
    public init() {
        self.scene = GameScene()
        self.scene.size = CGSize(width: GBConstants.ScreenWidth, height: GBConstants.ScreenHeight)
        self.scene.isFPSDisplayEnabled = true
        self.gVM.errorViewModel = self.eVM
        GBLogService.gbLogger = self.lVM
        GBErrorService.errorReporter = self.eVM
    }
    
    public var body: some Scene {
        WindowGroup {
            VStack {
                Button {
                    self.mVM.fileImporterPresented = true
                } label: {
                    Label("insert cartridge",systemImage: "square.and.arrow.down")
                }.disabled(self.gVM.isOn)
                Toggle(isOn: self.$gVM.isOn){
                    Label(self.gVM.isOn ? "Turn off" : "Turn on",
                          systemImage: self.gVM.isOn ? "lightswitch.off" : "lightswitch.on" )
                }.onChange(of: self.gVM.isOn) { value in
                    if(value)  {
                        self.gVM.turnOn()
                    }
                    else {
                        self.gVM.turnOff()
                    }
                }
                
                // the game screen
                SpriteView(scene: self.scene,preferredFramesPerSecond: GBUIConstants.PreferredFrameRate).frame(width: GBUIConstants.SceneWidth, height: GBUIConstants.SceneHeight)
                
                HStack {
                    Button("Left", systemImage: "arrowshape.left", action: {})
                        .pressAction({
                            pressed in self.gVM.setButtonState(.LEFT, pressed)
                        })
                        .labelStyle(.iconOnly)
                    
                    Button("Up", systemImage: "arrowshape.up", action: {})
                        .pressAction({
                            pressed in self.gVM.setButtonState(.UP, pressed)
                        })
                        .labelStyle(.iconOnly)
                    
                    Button("Right", systemImage: "arrowshape.right", action: {})
                        .pressAction({
                            pressed in self.gVM.setButtonState(.RIGHT, pressed)
                        })
                        .labelStyle(.iconOnly)
                    
                    Button("Down", systemImage: "arrowshape.down", action: {})
                        .pressAction({
                            pressed in self.gVM.setButtonState(.DOWN, pressed)
                        })
                        .labelStyle(.iconOnly)
                    
                    Button("A") {}
                        .pressAction({
                            pressed in self.gVM.setButtonState(.A, pressed)
                        })
                    
                    Button("B") {}
                        .pressAction({
                            pressed in self.gVM.setButtonState(.B, pressed)
                        })
                    
                    Button("start") {}
                        .pressAction({
                            pressed in self.gVM.setButtonState(.START, pressed)
                        })
                    
                    Button("select") {}
                        .pressAction({
                            pressed in self.gVM.setButtonState(.SELECT, pressed)
                        })
                }
                
                HStack {
                    Text("Pressed buttons: ")
                    ForEach(self.gVM.pressedButtons.sorted{$0.hashValue < $1.hashValue}, id: \.hashValue){ b in
                        Text(b.rawValue)
                    }
                }
                //todo use dedicated view for logging
                List {
                    Section(header: Text("Log")) {
                        ForEach(self.lVM.messages) { log in
                            Text(log.message).font(.system(.body, design: .monospaced))
                        }
                    }
                }
            }
            .onAppear {
                checkForConnectedControllers()
                setupControllerObservers()
                isFocused = true
            }
            .onReceive(self.eVM.$hasError) {
                //on error -> turn off game boy
                (value) in self.gVM.turnOff()
            }
            .focused($isFocused)
            /*//key down
            .onKeyPress(phases: .down, action: { keyPress in
                print("Key \(keyPress.characters) released")
                return .handled
            })
            //key up
            .onKeyPress(phases: .up, action: { keyPress in
                print("Key \(keyPress.characters) released")
                return .handled
            })*/
            //file importer
            .fileImporter(isPresented: self.$mVM.fileImporterPresented, allowedContentTypes:[.data], onCompletion: { (res) in
                switch res {
                case .success(let fileUrl):
                    do {
                        GBLogService.log(LogCategory.TOP_LEVEL,"user select : "+fileUrl.path)
                        let fileUrl = try res.get()
                        guard fileUrl.startAccessingSecurityScopedResource() else { return }
                        if let data = try? Data(contentsOf: fileUrl) {
                            let cart = try Cartridge(data: data)
                            self.gVM.insert(cartridge: cart)
                            GBLogService.log(LogCategory.TOP_LEVEL, cart.describe())
                        }
                        fileUrl.stopAccessingSecurityScopedResource()
                    } catch {
                        self.eVM.submit(error: error)
                    }
                case .failure(let error):
                    self.eVM.submit(error: error)
                }
            })
            //error alert
            .alert(self.eVM.errorTitle,isPresented: self.$eVM.hasError) {
            } message: {
                Text(self.eVM.errorMessage)
            }
            .padding(15)
        }
    }
    
    /// watch for controller to connect
    private func setupControllerObservers() {
        NotificationCenter.default.addObserver(
            forName: .GCControllerDidConnect,
            object: nil,
            queue: nil
        ) { _ in
            self.lVM.log("Game Controller Connected")
            if let controller = GCController.controllers().first {
                self.setupGamepadHandlers(controller: controller)
            }
        }

        NotificationCenter.default.addObserver(
            forName: .GCControllerDidDisconnect,
            object: nil,
            queue: nil
        ) { _ in
            self.lVM.log("Game Controller Disconnected")
        }
    }
    
    //check for connect controller at launch
    private func checkForConnectedControllers() {
        // Check if any controller is already connected
        if let controller = GCController.controllers().first {
            self.lVM.log("Controller found")
            setupGamepadHandlers(controller:controller)
        } else {
            self.lVM.log("No controller found")
        }
    }

    /// setup handler for gamepad
    private func setupGamepadHandlers(controller:GCController) {
        if let extendedGamepad = controller.extendedGamepad {
            extendedGamepad.valueChangedHandler = { gamepad, element in
                self.handleExtendedGamepadInput(gamepad: gamepad, element: element)
            }
        }
        else if let microGamepad = controller.microGamepad {
            microGamepad.valueChangedHandler = { gamepad, element in
                self.handleMicroGamepadInput(gamepad: gamepad, element: element)
            }
        }
    }

    /// Handle input from micro controller
    private func handleMicroGamepadInput(gamepad: GCMicroGamepad, element: GCControllerElement) {
        self.gVM.setButtonState(.A, gamepad.buttonA.isPressed)
        self.gVM.setButtonState(.B, gamepad.buttonX.isPressed)
        self.gVM.setButtonState(.START, gamepad.buttonMenu.isPressed)
        self.gVM.setButtonState(.SELECT, gamepad.buttonMenu.isPressed && gamepad.buttonX.isPressed)//no select on micro so its X+MENU
        self.gVM.setButtonState(.UP, gamepad.dpad.up.isPressed)
        self.gVM.setButtonState(.DOWN, gamepad.dpad.down.isPressed)
        self.gVM.setButtonState(.LEFT, gamepad.dpad.left.isPressed)
        self.gVM.setButtonState(.RIGHT, gamepad.dpad.right.isPressed)
    }
    
    /// Handle input from extended controller
    private func handleExtendedGamepadInput(gamepad: GCExtendedGamepad, element: GCControllerElement) {
        self.gVM.setButtonState(.A, gamepad.buttonA.isPressed)
        self.gVM.setButtonState(.B, gamepad.buttonB.isPressed)
        self.gVM.setButtonState(.START, gamepad.buttonMenu.isPressed)
        self.gVM.setButtonState(.SELECT, gamepad.buttonOptions!.isPressed || false)
        self.gVM.setButtonState(.UP, gamepad.leftThumbstick.up.value > 0.5 || gamepad.dpad.up.isPressed)
        self.gVM.setButtonState(.DOWN, gamepad.leftThumbstick.down.value > 0.5 || gamepad.dpad.down.isPressed)
        self.gVM.setButtonState(.LEFT, gamepad.leftThumbstick.left.value > 0.5 || gamepad.dpad.left.isPressed)
        self.gVM.setButtonState(.RIGHT, gamepad.leftThumbstick.right.value > 0.5 || gamepad.dpad.right.isPressed)
    }
}

//view modifier to fake Pressed and Released behavior via DragGesture
public struct PressActions: ViewModifier {
    var onPress: () -> Void
    var onRelease: () -> Void
    
    public func body(content: Content) -> some View {
        content
            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .onChanged({ _ in
                        onPress()
                    })
                    .onEnded({ _ in
                        onRelease()
                    })
            )
    }
}

//view extension
extension View {
    public func pressAction(_ action: @escaping ((Bool) -> Void)) -> some View {
        modifier(PressActions(onPress: {
            action(true)
        }, onRelease: {
            action(false)
        }))
    }
}
