import Foundation
import GBKit

public struct UIConstants {
    //wish framerate for UI
    public let PreferredFrameRate:Int = 60
    /// scale factor of framebufferwhen renderered in UI
    public let ScaleFactor:CGFloat = 3
    /// effective scene width, independant from framebuffer
    public let SceneWidth:CGFloat
    /// effective scene height, independant from framebuffer
    public let SceneHeight:CGFloat

    
    public init() {
        self.SceneWidth = CGFloat(Double(GBConstants.ScreenWidth) * ScaleFactor)
        self.SceneHeight = CGFloat(Double(GBConstants.ScreenHeight) * ScaleFactor)
    }
}

public let GBUIConstants:UIConstants = UIConstants()
