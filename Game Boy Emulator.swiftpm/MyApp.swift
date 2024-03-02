import SwiftUI
import SpriteKit

@main
struct MyApp: App {
    @ObservedObject private var lVM:LoggingViewModel = LoggingViewModel()
    @ObservedObject private var eVM:ErrorViewModel = ErrorViewModel()
    @ObservedObject private var mVM:MainViewModel = MainViewModel()
    @ObservedObject private var gVM:GameBoyViewModel = GameBoyViewModel()
    
    var gameScene: GameScene {
        let scene = GameScene()
        scene.size = CGSize(width: ScreenWidth, height: ScreenHeight)
        scene.isFPSDisplayEnabled = true
        return scene
    }
    
    public init() {
        self.gVM.errorViewModel = self.eVM
        LogService.logViewModel = self.lVM
        ErrorService.errorViewModel = self.eVM
    }
    
    var body: some Scene {
        WindowGroup {
            Form {
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
                SpriteView(scene: gameScene).frame(width: SceneWidth, height: SceneHeight)
                
                //todo use dedicated view for logging
                List {
                    Section(header: Text("Log")) {
                        ForEach(self.lVM.messages) { log in
                            Text(log.message).font(.system(.body, design: .monospaced))
                        }
                    }
                }
            }.onReceive(self.eVM.$hasError) {
                //on error -> turn off game boy
                (value) in self.gVM.turnOff()
            }
            //file importer
            .fileImporter(isPresented: self.$mVM.fileImporterPresented, allowedContentTypes:[.data], onCompletion: { (res) in
                switch res {
                case .success(let fileUrl):
                    do {
                        LogService.log(LogCategory.TOP_LEVEL,"user select : "+fileUrl.path)
                        let fileUrl = try res.get()    
                        guard fileUrl.startAccessingSecurityScopedResource() else { return }
                        if let data = try? Data(contentsOf: fileUrl) {
                            let cart = try Cartridge(data: data) 
                            self.gVM.insert(cartridge: cart)
                            LogService.log(LogCategory.TOP_LEVEL, cart.describe())
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
        }
    }
}
