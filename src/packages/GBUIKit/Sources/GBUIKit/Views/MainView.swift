import SwiftUI
import GBKit
import SpriteKit

/// main app tap
public enum MainViewTabs {
    //for logging
    case Log
    //game view
    case Game
    //settings
    case Settings
}

struct MainView: View {
    @ObservedObject private var mVM:MainViewModel = MainViewModel()
    @ObservedObject private var lVM:LoggingViewModel
    @ObservedObject private var eVM:ErrorViewModel
    @ObservedObject private var gVM:GameBoyViewModel
    
    @State private var currentTab:MainViewTabs = MainViewTabs.Game
    
    //the scene displayed in screen
    private let scene:GameScene
    
    
    public init(gVM:GameBoyViewModel,
                eVM:ErrorViewModel,
                lVM:LoggingViewModel) {
        self.gVM = gVM
        self.eVM = eVM
        self.lVM = lVM
        self.scene = GameScene()
        self.scene.size = CGSize(width: GBConstants.ScreenWidth, height: GBConstants.ScreenHeight)
        self.scene.isFPSDisplayEnabled = true
        self.gVM.errorViewModel = self.eVM
    }
    
    var body: some View {
        VStack{
            //tab bar
            HStack{
                //todo determine if useful
                Button {
                } label: {
                    Label("",systemImage: "info.circle")
                }
                //tabs
                Picker("Selection", selection: $currentTab) {
                    Text("Log").tag(MainViewTabs.Log)
                    Text("Game").tag(MainViewTabs.Game)
                    Text("Settings").tag(MainViewTabs.Settings)
                }
                .pickerStyle(.segmented)
                .frame(minWidth: 0, maxWidth: .infinity)
                
                //fullscreen button
                Button {
                    self.mVM.fileImporterPresented = true
                } label: {
                    Label("",systemImage: "arrow.down.left.and.arrow.up.right")
                }
            }
            
            //tabs content
            ZStack{
                //game tab
                VStack {
                    HStack{
                        //insert cart
                        Button {
                            self.mVM.fileImporterPresented = true
                        } label: {
                            Label("insert cartridge",systemImage: "square.and.arrow.down")
                        }.disabled(self.gVM.isOn)
                        //on/off switch
                        Toggle(isOn: self.$gVM.isOn){
                            Label(self.gVM.isOn ? "Turn off" : "Turn on",
                                  systemImage: self.gVM.isOn ? "lightswitch.off" : "lightswitch.on" ).frame(maxWidth: .infinity, alignment: .trailing)
                        }.onChange(of: self.gVM.isOn) { value in
                            if(value)  {
                                self.gVM.turnOn()
                            }
                            else {
                                self.gVM.turnOff()
                            }
                        }
                    }.padding(10)
                    
                    // the game screen
                    ZStack {
                        //background that should match bg palette, part of GB design (screen is larger than framebuffer)
                        UnevenRoundedRectangle(cornerRadii: .init(topLeading: 10.0,
                                                                  bottomLeading: 10.0,
                                                                  bottomTrailing: 10.0,
                                                                  topTrailing: 10.0))
                        .fill(.gray)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                        .aspectRatio(1.0, contentMode: .fit)
                        //game view
                        SpriteView(scene: self.scene,preferredFramesPerSecond: GBUIConstants.PreferredFrameRate).frame(maxWidth: .infinity, alignment: .trailing)
                            .aspectRatio(1.0, contentMode: .fit)
                            .padding(10)
                    }.frame(maxWidth: .infinity, alignment: .center)
                    Spacer()
                    HStack {
                        DPad(gVM: self.gVM)
                        Spacer()
                        ABStartSelect(gVM: self.gVM)
                    }
                }.frame(minWidth: 0,
                        maxWidth: .infinity,
                        minHeight: 0,
                        maxHeight: .infinity,
                        alignment: .topLeading
                ).hidden(currentTab != .Game)
                
                //log tab
                VStack {
                    Form {
                        Section(header: Text("Pressed buttons ")) {
                            ForEach(self.gVM.pressedButtons.sorted{$0.hashValue < $1.hashValue}, id: \.hashValue){ b in
                                Text(b.rawValue)
                            }
                        }
                        Section(header: Text("Log")) {
                            ScrollView {
                                ForEach(self.lVM.messages) { log in
                                    Text(log.message).font(.system(.body, design: .monospaced))
                                }
                            }
                        }
                    }
                }.hidden(currentTab != .Log)
                
                //settings tab
                VStack {
                    Text("Settings")
                }.hidden(currentTab != .Settings)
            }
        }.frame(minWidth: 0, maxWidth: .infinity)
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
    }
}

#Preview {
    MainView(gVM: GameBoyViewModel(),
             eVM: ErrorViewModel(),
             lVM: LoggingViewModel()).padding(25)
}
