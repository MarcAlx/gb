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
    @EnvironmentObject private var buttonMapping:ButtonMapping
    
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
    @State private var isAudioHPFEnabled:Bool = true
    
    @State private var isPPULayerBGEnabled:Bool = true
    @State private var isPPULayerWINEnabled:Bool = true
    @State private var isPPULayerOBJEnabled:Bool = true
    
    @State private var isFPSDisplayed:Bool = true
    
    var keyValues: some View {
        ForEach(Array(keyboardKeys.keys).sorted(), id: \.self) { key in
            Text(key).tag(keyboardKeys[key]!)
        }
    }
    
    var body: some View {
        NavigationStack {
            TabView(selection: $currentTab) {
                VStack {
                    VStack {
                        Form {
                            Section(header: Text("log.section.log".localized)) {
                                ScrollView {
                                    ForEach(self.lVM.messages) { log in
                                        Text(log.message).font(.system(.body, design: .monospaced))
                                    }
                                }
                            }
                        }
                    }
                }
                .tabItem {
                    Label("tab.log".localized, systemImage: "text.page")
                }
                .tag(MainViewTabs.Log)
                VStack {
                    if(orientation.isPortrait
                       || ProcessInfo.processInfo.isMacCatalystApp
                       || UIDevice.current.userInterfaceIdiom == .pad){
                        HStack{
                            InsertButton()
                            OnOffSwitch()
                            
                        }.padding(5)
                    }
                    VStack {
                        VStack {
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
                                GameScreen(withFPS: self.$isFPSDisplayed).frame(maxWidth: .infinity, alignment: .center) //only one screen
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
                        }.frame(minWidth: 0,
                                maxWidth: .infinity,
                                minHeight: 0,
                                maxHeight: .infinity,
                                alignment: .topLeading)
                    }
                }
                .tabItem {
                    Label("tab.game".localized, systemImage: "gamecontroller")
                }
                .tag(MainViewTabs.Game)
                VStack {
                    HStack{
                        Spacer()
                        Button(action: {
                            if let url = URL(string: "https://github.com/MarcAlx/gb"){
                                EnvironmentValues().openURL(url)
                            }
                        }) {
                            Label("button.info".localized, systemImage: "info.circle")
                        }
                    }
                    
                    VStack {
                        VStack {
                            Form {
                                Section(header: Text("settings.section.activePalette".localized)) {
                                    Picker("setting.activepalette".localized, selection: $currentPaletteIndex) {
                                        Text("palette.dmg".localized).tag(PalettesIndexes.DMG)
                                        Text("palette.mgb".localized).tag(PalettesIndexes.MGB)
                                        Text("palette.custom".localized).tag(PalettesIndexes.CUSTOM)
                                    }
                                    .pickerStyle(.menu)
                                    .onChange(of: currentPaletteIndex) { newValue in
                                        VideoManager.sharedInstance.setCurrentPalette(palette: newValue, ppu: self.gVM.gb.motherboard.ppu)
                                        //adapt screen background
                                        self.mVM.screenBackground = self.gVM.gb.ppuConfiguration.palette[0].toSWiftUIColor()
                                    }
                                }
                                
                                Section(header: Text("settings.section.customPalette".localized)){
                                    ColorPicker("setting.custompalette.color1".localized, selection: self.$customPaletteColor0, supportsOpacity: false).onChange(of: customPaletteColor0) { newValue in
                                        VideoManager.sharedInstance.customPalette[0]=GBKit.Color.fromSWiftUIColor(newValue)
                                        //re-apply custom palette if active in order to see change
                                        if(VideoManager.sharedInstance.paletteIndex == .CUSTOM){
                                            VideoManager.sharedInstance.setCurrentPalette(palette: .CUSTOM, ppu: self.gVM.gb.motherboard.ppu)
                                            //adapt screen background
                                            self.mVM.screenBackground = self.gVM.gb.ppuConfiguration.palette[0].toSWiftUIColor()
                                        }
                                    }
                                    ColorPicker("setting.custompalette.color2".localized, selection: self.$customPaletteColor1, supportsOpacity: false).onChange(of: customPaletteColor1) { newValue in
                                        VideoManager.sharedInstance.customPalette[1]=GBKit.Color.fromSWiftUIColor(newValue)
                                        //re-apply custom palette if active in order to see change
                                        if(VideoManager.sharedInstance.paletteIndex == .CUSTOM){
                                            VideoManager.sharedInstance.setCurrentPalette(palette: .CUSTOM, ppu: self.gVM.gb.motherboard.ppu)
                                        }
                                    }
                                    ColorPicker("setting.custompalette.color3".localized, selection: self.$customPaletteColor2, supportsOpacity: false).onChange(of: customPaletteColor2) { newValue in
                                        VideoManager.sharedInstance.customPalette[2]=GBKit.Color.fromSWiftUIColor(newValue)
                                        //re-apply custom palette if active in order to see change
                                        if(VideoManager.sharedInstance.paletteIndex == .CUSTOM){
                                            VideoManager.sharedInstance.setCurrentPalette(palette: .CUSTOM, ppu: self.gVM.gb.motherboard.ppu)
                                        }
                                    }
                                    ColorPicker("setting.custompalette.color4".localized, selection: self.$customPaletteColor3, supportsOpacity: false).onChange(of: customPaletteColor3) { newValue in
                                        VideoManager.sharedInstance.customPalette[3]=GBKit.Color.fromSWiftUIColor(newValue)
                                        //re-apply custom palette if active in order to see change
                                        if(VideoManager.sharedInstance.paletteIndex == .CUSTOM){
                                            VideoManager.sharedInstance.setCurrentPalette(palette: .CUSTOM, ppu: self.gVM.gb.motherboard.ppu)
                                        }
                                    }
                                }
                                
                                Section(header: Text("settings.section.ppulayer".localized)){
                                    Toggle("layer.bg".localized, isOn: self.$isPPULayerBGEnabled).onChange(of: isPPULayerBGEnabled) { newValue in
                                        self.gVM.gb.ppuConfiguration.isBGEnabled = newValue
                                    }
                                    Toggle("layer.win".localized, isOn: self.$isPPULayerWINEnabled).onChange(of: isPPULayerWINEnabled) { newValue in
                                        self.gVM.gb.ppuConfiguration.isWINEnabled = newValue
                                    }
                                    Toggle("layer.obj".localized,  isOn: self.$isPPULayerOBJEnabled).onChange(of: isPPULayerOBJEnabled) { newValue in
                                        self.gVM.gb.ppuConfiguration.isOBJEnabled = newValue
                                    }
                                }
                                
                                Section(header: Text("settings.section.audio".localized)){
                                    HStack{
                                        Text("setting.mainvolume".localized)
                                        Spacer(minLength: 400)
                                        Slider(value: self.$mainVolume, in: 0...1) {
                                            
                                        } minimumValueLabel: {
                                            Text("mainVolume.min".localized).font(.title2).fontWeight(.thin)
                                        } maximumValueLabel: {
                                            Text("mainVolume.max".localized).font(.title2).fontWeight(.thin)
                                        }.onChange(of: mainVolume) { newValue in
                                            self.gVM.audioManager.volume = newValue
                                        }
                                    }
                                    Toggle("apu.channel1".localized, isOn: self.$isAudioChannel1Enabled).onChange(of: isAudioChannel1Enabled) { newValue in
                                        self.gVM.gb.apuConfiguration.isChannel1Enabled = newValue
                                    }
                                    Toggle("apu.channel2".localized, isOn: self.$isAudioChannel2Enabled).onChange(of: isAudioChannel2Enabled) { newValue in
                                        self.gVM.gb.apuConfiguration.isChannel2Enabled = newValue
                                    }
                                    Toggle("apu.channel3".localized,  isOn: self.$isAudioChannel3Enabled).onChange(of: isAudioChannel3Enabled) { newValue in
                                        self.gVM.gb.apuConfiguration.isChannel3Enabled = newValue
                                    }
                                    Toggle("apu.channel4".localized, isOn: self.$isAudioChannel4Enabled).onChange(of: isAudioChannel4Enabled) { newValue in
                                        self.gVM.gb.apuConfiguration.isChannel4Enabled = newValue
                                    }
                                    Toggle("apu.hpf".localized, isOn: self.$isAudioHPFEnabled).onChange(of: isAudioHPFEnabled) { newValue in
                                        self.gVM.gb.apuConfiguration.isHPFEnabled = newValue
                                    }
                                }
                                
                                Section(header: Text("settings.section.buttonMapping".localized)) {
                                    Picker("joypad.A".localized, selection: self.$buttonMapping.forButtonA) {
                                        keyValues
                                    }
                                    .pickerStyle(.menu)
                                    Picker("joypad.B".localized, selection: self.$buttonMapping.forButtonB) {
                                        keyValues
                                    }
                                    .pickerStyle(.menu)
                                    Picker("joypad.Start".localized, selection: self.$buttonMapping.forButtonStart) {
                                        keyValues
                                    }
                                    .pickerStyle(.menu)
                                    Picker("joypad.Select".localized, selection: self.$buttonMapping.forButtonSelect) {
                                        keyValues
                                    }
                                    .pickerStyle(.menu)
                                    Picker("joypad.Up".localized, selection: self.$buttonMapping.forButtonUp) {
                                        keyValues
                                    }
                                    .pickerStyle(.menu)
                                    Picker("joypad.Down".localized, selection: self.$buttonMapping.forButtonDown) {
                                        keyValues
                                    }
                                    .pickerStyle(.menu)
                                    Picker("joypad.Left".localized, selection: self.$buttonMapping.forButtonLeft) {
                                        keyValues
                                    }
                                    .pickerStyle(.menu)
                                    Picker("joypad.Right".localized, selection: self.$buttonMapping.forButtonRight) {
                                        keyValues
                                    }
                                    .pickerStyle(.menu)
                                }
                                
                                Section(header: Text("settings.section.debug".localized)) {
                                    Toggle("setting.displayFPS".localized, isOn: self.$isFPSDisplayed)
                                }
                            }
                            Spacer()
                        }
                    }
                }
                .tabItem {
                    Label("tab.settings".localized, systemImage: "gear")
                }
                .tag(MainViewTabs.Settings)
            }
            .tabViewStyle(.tabBarOnly)
            //toolbar
            .toolbar {
                 /*if(self.currentTab == MainViewTabs.Game
                 && (orientation.isPortrait || ProcessInfo.processInfo.isMacCatalystApp || UIDevice.current.userInterfaceIdiom == .pad)){
                     ToolbarItem(placement: .confirmationAction) {
                         InsertButton()
                     }
                     ToolbarItem(placement: .cancellationAction) {
                         OnOffSwitch()
                     }
                 }
                 if(self.currentTab == MainViewTabs.Settings) {
                     ToolbarItem(placement: .topBarTrailing) {
                         Button(action: {
                             if let url = URL(string: "https://github.com/MarcAlx/gb"){
                                 EnvironmentValues().openURL(url)
                             }
                         }) {
                             Label("button.info", systemImage: "info.circle")
                         }
                     }
                 }*/
             }//TODO use accessory on iOS 26
            //.toolbarStyle(.automatic)
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
}

#Preview {
    MainView().padding(25)
}
