import SwiftUI
import GBKit

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
            Label("insert cartridge",systemImage: "square.and.arrow.down")
        }.disabled(self.gVM.isOn)
    }
}

///button to turn on / off
struct OnOffSwitch: View {
    @EnvironmentObject private var gVM:GameBoyViewModel
    
    var body: some View {
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
    }
}

/// DPad control, works with a GameBoyVIewModel
struct DPad: View {
    @EnvironmentObject private var gVM:GameBoyViewModel
    
    private let buttonSize:CGFloat = 50
    private let dPadBGColor = Color.gray
    private let dPadFGColor = Color.black

    var body: some View {
        Grid(horizontalSpacing: 0, verticalSpacing: 0) {
            GridRow{
                Spacer().frame(width: buttonSize, height: buttonSize)
                ZStack{
                    UnevenRoundedRectangle(cornerRadii: .init(topLeading: 10.0,
                                                              bottomLeading: 0.0,
                                                              bottomTrailing: 0.0,
                                                              topTrailing: 10.0))
                    .fill(self.gVM.pressedButtons.contains(.UP) ? self.dPadFGColor : self.dPadBGColor)
                    .frame(width: buttonSize, height: buttonSize)
                    Button("Up", systemImage: "triangle", action: {})
                        .pressAction({
                            pressed in self.gVM.setButtonState(.UP, pressed)
                        })
                        .buttonStyle(NoOpacityChangeButtonStyle())
                        .foregroundColor(self.gVM.pressedButtons.contains(.UP) ? self.dPadBGColor : self.dPadFGColor)
                        .labelStyle(.iconOnly)
                        .frame(width: buttonSize, height: buttonSize)
                }
                Spacer().frame(width: buttonSize, height: buttonSize)
            }
            GridRow{
                ZStack{
                    UnevenRoundedRectangle(cornerRadii: .init(topLeading: 10.0,
                                                              bottomLeading: 10.0,
                                                              bottomTrailing: 0.0,
                                                              topTrailing: 0.0))
                    .fill(self.gVM.pressedButtons.contains(.LEFT) ? self.dPadFGColor : self.dPadBGColor)
                    .frame(width: buttonSize, height: buttonSize)
                    Button("Left", systemImage: "triangle", action: {})
                        .pressAction({
                            pressed in self.gVM.setButtonState(.LEFT, pressed)
                        })
                        .buttonStyle(NoOpacityChangeButtonStyle())
                        .foregroundColor(self.gVM.pressedButtons.contains(.LEFT) ? self.dPadBGColor : self.dPadFGColor)
                        .labelStyle(.iconOnly)
                        .rotationEffect(.degrees(-90))
                        .frame(width: buttonSize, height: buttonSize)
                }
                Rectangle().fill(self.gVM.pressedButtons.contains(.DOWN)
                                 || self.gVM.pressedButtons.contains(.UP)
                                 || self.gVM.pressedButtons.contains(.RIGHT)
                                 || self.gVM.pressedButtons.contains(.LEFT) ? self.dPadFGColor : self.dPadBGColor)
                           .frame(width: buttonSize, height: buttonSize)
                ZStack{
                    UnevenRoundedRectangle(cornerRadii: .init(topLeading: 0.0,
                                                              bottomLeading: 0.0,
                                                              bottomTrailing: 10.0,
                                                              topTrailing: 10.0))
                    .fill(self.gVM.pressedButtons.contains(.RIGHT) ? self.dPadFGColor : self.dPadBGColor)
                    .frame(width: buttonSize, height: buttonSize)
                    Button("Right", systemImage: "triangle", action: {})
                        .pressAction({
                            pressed in self.gVM.setButtonState(.RIGHT, pressed)
                        })
                        .buttonStyle(NoOpacityChangeButtonStyle())
                        .foregroundColor(self.gVM.pressedButtons.contains(.RIGHT) ? self.dPadBGColor : self.dPadFGColor)
                        .labelStyle(.iconOnly)
                        .rotationEffect(.degrees(90)).frame(width: buttonSize, height: buttonSize)
                }
            }
            GridRow{
                Spacer().frame(width: buttonSize, height: buttonSize)
                ZStack{
                    UnevenRoundedRectangle(cornerRadii: .init(topLeading: 0.0,
                                                              bottomLeading: 10.0,
                                                              bottomTrailing: 10.0,
                                                              topTrailing: 0.0))
                    .fill(self.gVM.pressedButtons.contains(.DOWN) ? self.dPadFGColor : self.dPadBGColor)
                    .frame(width: buttonSize, height: buttonSize)
                    Button("Down", systemImage: "triangle", action: {})
                        .pressAction({
                            pressed in self.gVM.setButtonState(.DOWN, pressed)
                        })
                        .buttonStyle(NoOpacityChangeButtonStyle())
                        .labelStyle(.iconOnly)
                        .rotationEffect(.degrees(180))
                        .frame(width: buttonSize, height: buttonSize)
                        .foregroundColor(self.gVM.pressedButtons.contains(.DOWN) ? self.dPadBGColor : self.dPadFGColor)
                }
                Spacer().frame(width: buttonSize, height: buttonSize)
            }
        }
    }
}


/// A B Start Select  control, works with a GameBoyVIewModel
struct ABStartSelect: View {
    @EnvironmentObject private var gVM:GameBoyViewModel
    
    private let buttonSize:CGFloat = 50
    private let startSelectBGColor = Color.black
    private let startSelectFGColor = Color.white
    private let ABHolderBGColor = Color.gray
    private let ABBGColor = Color.red
    private let ABFGColor = Color.black
    
    var body: some View {
        VStack {
            HStack{
                Button("select") {}
                    .pressAction({
                        pressed in self.gVM.setButtonState(.SELECT, pressed)
                    })
                    .rotationEffect(.degrees(0))
                    .buttonStyle(.borderedProminent).controlSize(.mini)
                    .tint(self.startSelectBGColor)
                    .foregroundColor(self.startSelectFGColor)
                Spacer().frame(width: buttonSize/2, height: buttonSize/2)
                Button("start") {}
                    .pressAction({
                        pressed in self.gVM.setButtonState(.START, pressed)
                    })
                    .rotationEffect(.degrees(0))
                    .buttonStyle(.borderedProminent).controlSize(.mini)
                    .tint(self.startSelectBGColor)
                    .foregroundColor(self.startSelectFGColor)
            }
            HStack(spacing:0){
                ZStack{
                    //bg
                    UnevenRoundedRectangle(cornerRadii: .init(topLeading: 10.0,
                                                              bottomLeading: 10.0,
                                                              bottomTrailing: 0.0,
                                                              topTrailing: 0.0))
                    .fill(self.ABHolderBGColor)
                    .rotationEffect(.degrees(0))
                    .frame(width: buttonSize+10, height: buttonSize+10)
                    UnevenRoundedRectangle(cornerRadii: .init(topLeading: 25.0,
                                                              bottomLeading: 25.0,
                                                              bottomTrailing: 25.0,
                                                              topTrailing: 25.0))
                    .fill(self.gVM.pressedButtons.contains(.B) ? self.ABFGColor : self.ABBGColor)
                    .frame(width: buttonSize, height: buttonSize)
                    //fg
                    Button("B") {}
                        .pressAction({
                            pressed in self.gVM.setButtonState(.B, pressed)
                        })
                        .labelStyle(.iconOnly)
                        .rotationEffect(.degrees(45))
                        .frame(width: buttonSize, height: buttonSize)
                        .buttonStyle(NoOpacityChangeButtonStyle())
                        .foregroundColor(self.gVM.pressedButtons.contains(.B) ? self.ABBGColor : self.ABFGColor)
                }
                Rectangle().fill(self.ABHolderBGColor)
                           .frame(width: buttonSize/2, height: buttonSize+10)
                ZStack{
                    //bg
                    UnevenRoundedRectangle(cornerRadii: .init(topLeading: 0.0,
                                                              bottomLeading: 0.0,
                                                              bottomTrailing: 10.0,
                                                              topTrailing: 10.0))
                    .fill(self.ABHolderBGColor)
                    .rotationEffect(.degrees(0))
                    .frame(width: buttonSize+10, height: buttonSize+10)
                    UnevenRoundedRectangle(cornerRadii: .init(topLeading: 25.0,
                                                              bottomLeading: 25.0,
                                                              bottomTrailing: 25.0,
                                                              topTrailing: 25.0))
                    .fill(self.gVM.pressedButtons.contains(.A) ? self.ABFGColor : self.ABBGColor)
                    .frame(width: buttonSize, height: buttonSize)
                    //fg
                    Button("A") {}
                        .pressAction({
                            pressed in self.gVM.setButtonState(.A, pressed)
                        })
                        .labelStyle(.iconOnly)
                        .rotationEffect(.degrees(45))
                        .frame(width: buttonSize, height: buttonSize)
                        .buttonStyle(NoOpacityChangeButtonStyle())
                        .foregroundColor(self.gVM.pressedButtons.contains(.A) ? self.ABBGColor : self.ABFGColor)
                }
            }
        }.rotationEffect(.degrees(-45))
    }
}

//style to prevent button from changing opacity on press
struct NoOpacityChangeButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label // Keep the label unchanged
    }
}
