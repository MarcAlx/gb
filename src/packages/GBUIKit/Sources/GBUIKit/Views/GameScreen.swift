import SwiftUI
import GBKit
import SpriteKit

struct GameScreen: View {
    @EnvironmentObject private var mVM:MainViewModel
    @EnvironmentObject private var gVM:GameBoyViewModel
    
    var body: some View {
        ZStack {
            //background that should match bg palette, part of GB design (screen is larger than framebuffer)
            UnevenRoundedRectangle(cornerRadii: .init(topLeading: 10.0,
                                                      bottomLeading: 10.0,
                                                      bottomTrailing: 10.0,
                                                      topTrailing: 10.0))
            .fill(self.mVM.screenBackground)
            .aspectRatio(1.0, contentMode: .fit)
            //border
            .overlay(RoundedRectangle(cornerRadius: 10).stroke(.black, lineWidth: 1))
            //game view
            SpriteView(scene: GameScene().withSetup(gVM: self.gVM, size:  CGSize(width: GBConstants.ScreenWidth, height: GBConstants.ScreenHeight), fpsDisplayed: true),preferredFramesPerSecond: GBUIConstants.PreferredFrameRate)
                .aspectRatio(1.0, contentMode: .fit)
                .padding(10)
        }.padding(10)
    }
}
