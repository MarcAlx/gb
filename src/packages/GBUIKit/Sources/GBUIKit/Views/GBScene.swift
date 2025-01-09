import SwiftUI
import GameController
import SpriteKit
import GBKit

public struct GBScene: Scene {
      
    @ObservedObject private var lVM:LoggingViewModel = LoggingViewModel()
    @ObservedObject private var eVM:ErrorViewModel = ErrorViewModel()
    @ObservedObject private var gVM:GameBoyViewModel = GameBoyViewModel()
    
    @FocusState private var isFocused: Bool
    
    public init() {
        self.gVM.errorViewModel = self.eVM
        GBLogService.gbLogger = self.lVM
        GBErrorService.errorReporter = self.eVM
        self.gVM.errorViewModel = self.eVM
    }
    
    public var body: some Scene {
        WindowGroup {
            VStack {
                MainView(gVM: self.gVM,
                         eVM: self.eVM,
                         lVM: self.lVM)
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
            ///*//key down
            //.onKeyPress(phases: .down, action: { keyPress in
            //    print("Key \(keyPress.characters) released")
            //    return .handled
            //})
            ////key up
            //.onKeyPress(phases: .up, action: { keyPress in
            //    print("Key \(keyPress.characters) released")
            //    return .handled
            //})*/
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
