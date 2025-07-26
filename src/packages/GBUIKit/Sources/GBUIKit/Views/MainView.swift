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
    @EnvironmentObject private var mVM:MainViewModel
    @EnvironmentObject private var lVM:LoggingViewModel
    @EnvironmentObject private var eVM:ErrorViewModel
    @EnvironmentObject private var gVM:GameBoyViewModel
    
    @State private var videoManager:VideoManager = VideoManager.sharedInstance
    
    @State private var orientation = UIDevice.current.orientation
    @State private var currentTab:MainViewTabs = MainViewTabs.Game
    @State private var currentPaletteIndex:PalettesIndexes = VideoManager.sharedInstance.paletteIndex
    
    @State private var customPaletteColor0:SwiftUI.Color = VideoManager.sharedInstance.customPalette[0].toSWiftUIColor()
    @State private var customPaletteColor1:SwiftUI.Color = VideoManager.sharedInstance.customPalette[1].toSWiftUIColor()
    @State private var customPaletteColor2:SwiftUI.Color = VideoManager.sharedInstance.customPalette[2].toSWiftUIColor()
    @State private var customPaletteColor3:SwiftUI.Color = VideoManager.sharedInstance.customPalette[3].toSWiftUIColor()
    
    @State private var mainVolume:Float = 0.5

    @State private var isAudioChannel1Enabled:Bool = true
    @State private var isAudioChannel2Enabled:Bool = true
    @State private var isAudioChannel3Enabled:Bool = true
    @State private var isAudioChannel4Enabled:Bool = true
    
    @State private var isPPULayerBGEnabled:Bool = true
    @State private var isPPULayerWINEnabled:Bool = true
    @State private var isPPULayerOBJEnabled:Bool = true
    
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
                    FullScreenButton()
                }
            }
            
            //tabs content
            ZStack{
                //game tab
                VStack {
                    VStack {
                        if(orientation.isPortrait || ProcessInfo.processInfo.isMacCatalystApp || UIDevice.current.userInterfaceIdiom == .pad){
                            HStack{
                                InsertButton()
                                OnOffSwitch()
                            }
                            .padding(10)
                        }
                        HStack{
                            if(orientation.isLandscape
                               || ProcessInfo.processInfo.isMacCatalystApp){
                                HStack{
                                    VStack{
                                        FullScreenButton().padding([.bottom], 20)                                   .hidden(!self.mVM.isFullScreen)
                                        DPad()
                                    }
                                }.frame(alignment: .leading)
                            }
                            GameScreen().frame(maxWidth: .infinity, alignment: .center) //only one screen
                            if(orientation.isLandscape
                               || ProcessInfo.processInfo.isMacCatalystApp){
                                HStack{
                                    ABStartSelect()
                                }.frame(alignment: .trailing)
                            }
                        }
                        if(orientation.isPortrait){
                            Spacer()
                            HStack {
                                DPad()
                                Spacer()
                                ABStartSelect()
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
                    Form {
                        Section(header: Text("Active palette")) {
                            Picker("Active", selection: $currentPaletteIndex) {
                                Text("DMG").tag(PalettesIndexes.DMG)
                                Text("MGB").tag(PalettesIndexes.MGB)
                                Text("Custom").tag(PalettesIndexes.CUSTOM)
                            }
                            .pickerStyle(.menu)
                            .onChange(of: currentPaletteIndex) { newValue in
                                VideoManager.sharedInstance.setCurrentPalette(palette: newValue, ppu: self.gVM.gb.motherboard.ppu)
                                //adapt screen background
                                self.mVM.screenBackground = self.gVM.gb.ppuConfiguration.palette[0].toSWiftUIColor()
                            }
                        }
                        
                        Section(header: Text("Custom palette configuration")){
                            ColorPicker("Color 1", selection: self.$customPaletteColor0, supportsOpacity: false).onChange(of: customPaletteColor0) { newValue in
                                VideoManager.sharedInstance.customPalette[0]=GBKit.Color.fromSWiftUIColor(newValue)
                                //re-apply custom palette if active in order to see change
                                if(VideoManager.sharedInstance.paletteIndex == .CUSTOM){
                                    VideoManager.sharedInstance.setCurrentPalette(palette: .CUSTOM, ppu: self.gVM.gb.motherboard.ppu)
                                    //adapt screen background
                                    self.mVM.screenBackground = self.gVM.gb.ppuConfiguration.palette[0].toSWiftUIColor()
                                }
                            }
                            ColorPicker("Color 2", selection: self.$customPaletteColor1, supportsOpacity: false).onChange(of: customPaletteColor1) { newValue in
                                VideoManager.sharedInstance.customPalette[1]=GBKit.Color.fromSWiftUIColor(newValue)
                                //re-apply custom palette if active in order to see change
                                if(VideoManager.sharedInstance.paletteIndex == .CUSTOM){
                                    VideoManager.sharedInstance.setCurrentPalette(palette: .CUSTOM, ppu: self.gVM.gb.motherboard.ppu)
                                }
                            }
                            ColorPicker("Color 3", selection: self.$customPaletteColor2, supportsOpacity: false).onChange(of: customPaletteColor2) { newValue in
                                VideoManager.sharedInstance.customPalette[2]=GBKit.Color.fromSWiftUIColor(newValue)
                                //re-apply custom palette if active in order to see change
                                if(VideoManager.sharedInstance.paletteIndex == .CUSTOM){
                                    VideoManager.sharedInstance.setCurrentPalette(palette: .CUSTOM, ppu: self.gVM.gb.motherboard.ppu)
                                }
                            }
                            ColorPicker("Color 4", selection: self.$customPaletteColor3, supportsOpacity: false).onChange(of: customPaletteColor3) { newValue in
                                VideoManager.sharedInstance.customPalette[3]=GBKit.Color.fromSWiftUIColor(newValue)
                                //re-apply custom palette if active in order to see change
                                if(VideoManager.sharedInstance.paletteIndex == .CUSTOM){
                                    VideoManager.sharedInstance.setCurrentPalette(palette: .CUSTOM, ppu: self.gVM.gb.motherboard.ppu)
                                }
                            }
                        }
                        
                        Section(header: Text("PPU layers")){
                            Toggle("BG", isOn: self.$isPPULayerBGEnabled).onChange(of: isPPULayerBGEnabled) { newValue in
                                self.gVM.gb.ppuConfiguration.isBGEnabled = newValue
                            }
                            Toggle("WIN", isOn: self.$isPPULayerWINEnabled).onChange(of: isPPULayerWINEnabled) { newValue in
                                self.gVM.gb.ppuConfiguration.isWINEnabled = newValue
                            }
                            Toggle("OBJ",  isOn: self.$isPPULayerOBJEnabled).onChange(of: isPPULayerOBJEnabled) { newValue in
                                self.gVM.gb.ppuConfiguration.isOBJEnabled = newValue
                            }
                        }
                        
                        Section(header: Text("Audio")){
                            HStack{
                                Text("Main volume")
                                Spacer(minLength: 400)
                                Slider(value: self.$mainVolume, in: 0...1) {
                                    
                                } minimumValueLabel: {
                                    Text("0").font(.title2).fontWeight(.thin)
                                } maximumValueLabel: {
                                    Text("100%").font(.title2).fontWeight(.thin)
                                }.onChange(of: mainVolume) { newValue in
                                    self.gVM.audioManager.volume = newValue
                                }
                            }
                            Toggle("Channel 1 (Sweep)", isOn: self.$isAudioChannel1Enabled).onChange(of: isAudioChannel1Enabled) { newValue in
                                self.gVM.gb.apuConfiguration.isChannel1Enabled = newValue
                            }
                            Toggle("Channel 2 (Pulse)", isOn: self.$isAudioChannel2Enabled).onChange(of: isAudioChannel2Enabled) { newValue in
                                self.gVM.gb.apuConfiguration.isChannel2Enabled = newValue
                            }
                            Toggle("Channel 3 (Wave)",  isOn: self.$isAudioChannel3Enabled).onChange(of: isAudioChannel3Enabled) { newValue in
                                self.gVM.gb.apuConfiguration.isChannel3Enabled = newValue
                            }
                            Toggle("Channel 4 (Noise)", isOn: self.$isAudioChannel4Enabled).onChange(of: isAudioChannel4Enabled) { newValue in
                                self.gVM.gb.apuConfiguration.isChannel4Enabled = newValue
                            }
                        }
                    }
                    Spacer()
                }.hidden(currentTab != .Settings)
            }
        }.frame(minWidth: 0, maxWidth: .infinity)
        //on appear init screenbg
        .onAppear {
            self.mVM.screenBackground = self.gVM.gb.ppuConfiguration.palette[0].toSWiftUIColor()
        }
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
    MainView().padding(25)
}
