import SwiftUI

/// sub view for game
struct GameView: View {
    
    @State private var orientation = UIDevice.current.orientation
    
    @Binding var fullScreen:Bool;
    @Binding var fps:Bool;
    
    var body: some View {
        VStack {
            if(!fullScreen && (orientation.isPortrait
                               || ProcessInfo.processInfo.isMacCatalystApp
                               || UIDevice.current.userInterfaceIdiom == .pad)){
                HStack{
                    HStack {
                        InsertButton()
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)

                    HStack {
                        FullScreenButton()
                    }
                    .frame(maxWidth: .infinity, alignment: .center)

                    HStack {
                        OnOffSwitch()
                    }
                    .frame(maxWidth: .infinity, alignment: .trailing)
                }.padding(5)
            }
            VStack {
                VStack {
                    HStack{
                        if(orientation.isLandscape
                           || ProcessInfo.processInfo.isMacCatalystApp){
                            HStack{
                                VStack{
                                    if(fullScreen){
                                        FullScreenButton()
                                    }
                                    DPad()
                                }
                            }.frame(alignment: .leading)
                        }
                        GameScreen(withFPS: $fps).frame(maxWidth: .infinity, alignment: .center)
                        if(orientation.isLandscape
                           || ProcessInfo.processInfo.isMacCatalystApp){
                            HStack{
                                ABStartSelect()
                            }.frame(alignment: .trailing)
                        }
                    }
                }.frame(minWidth: 0,
                        maxWidth: .infinity,
                        minHeight: 0,
                        maxHeight: .infinity,
                        alignment: .topLeading)
                
                if(orientation.isPortrait){
                    Spacer()
                    HStack {
                        DPad()
                        Spacer()
                        ABStartSelect()
                    }.padding([.bottom], 20)
                }
            }
        }
        //handle orientation change
        .onRotate { newOrientation in
            orientation = newOrientation
        }
    }
}
