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
    
    @State private var orientation = UIDevice.current.orientation
    @State private var currentTab:MainViewTabs = MainViewTabs.Game
    
    private let screen:GameScreen = GameScreen()
    
    public init(gVM:GameBoyViewModel,
                eVM:ErrorViewModel,
                lVM:LoggingViewModel) {
        self.gVM = gVM
        self.eVM = eVM
        self.lVM = lVM
        self.gVM.errorViewModel = self.eVM
    }
    
    var body: some View {
        VStack{
            if(!self.mVM.isFullScreen){
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
                    FullScreenButton(mVM: self.mVM)
                }
            }
            
            //tabs content
            ZStack{
                //game tab
                VStack {
                    VStack {
                        if(orientation.isPortrait){
                            HStack{
                                InsertButton(gVM: self.gVM, mVM: self.mVM)
                                OnOffSwitch(gVM: self.gVM)
                            }
                            .padding(10)
                        }
                        HStack{
                            if(orientation.isLandscape
                               || ProcessInfo.processInfo.isMacCatalystApp){
                                HStack{
                                    VStack{
                                        FullScreenButton(mVM: self.mVM).padding([.bottom], 20) .hidden(!self.mVM.isFullScreen)
                                        DPad(gVM: self.gVM)
                                    }
                                }.frame(alignment: .leading)
                            }
                            GameScreen().frame(maxWidth: .infinity, alignment: .center)//only one screen
                            if(orientation.isLandscape
                               || ProcessInfo.processInfo.isMacCatalystApp){
                                HStack{
                                    ABStartSelect(gVM: self.gVM)
                                }.frame(alignment: .trailing)
                            }
                        }
                        if(orientation.isPortrait){
                            Spacer()
                            HStack {
                                DPad(gVM: self.gVM)
                                Spacer()
                                ABStartSelect(gVM: self.gVM)
                            }
                        }
                    }
                }.frame(minWidth: 0,
                        maxWidth: .infinity,
                        minHeight: 0,
                        maxHeight: .infinity,
                        alignment: .topLeading
                )
                .hidden(currentTab != .Game)
                
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
        //handle orientation change
        .onRotate { newOrientation in
            orientation = newOrientation
        }
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
