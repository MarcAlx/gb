import SwiftUI
import GBKit
import SpriteKit

struct GameScreen: View {
    //the scene displayed in screen
    private let scene:GameScene
    
    public init() {
        self.scene = GameScene()
        self.scene.size = CGSize(width: GBConstants.ScreenWidth, height: GBConstants.ScreenHeight)
        self.scene.isFPSDisplayEnabled = true
    }
    
    var body: some View {
        ZStack {
            //background that should match bg palette, part of GB design (screen is larger than framebuffer)
            UnevenRoundedRectangle(cornerRadii: .init(topLeading: 10.0,
                                                      bottomLeading: 10.0,
                                                      bottomTrailing: 10.0,
                                                      topTrailing: 10.0))
            .fill(.gray)
            .aspectRatio(1.0, contentMode: .fit)
            //border
            .overlay(RoundedRectangle(cornerRadius: 10).stroke(.black, lineWidth: 1))
            //game view
            SpriteView(scene: self.scene,preferredFramesPerSecond: GBUIConstants.PreferredFrameRate)
                .aspectRatio(1.0, contentMode: .fit)
                .padding(10)
        }.padding(10)
    }
}
