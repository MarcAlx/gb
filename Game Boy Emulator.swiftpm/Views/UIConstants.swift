import Foundation

/// scale factor of framebufferwhen renderered in UI
public let ScaleFactor:CGFloat = 3
/// effective scene width, independant from framebuffer
public let SceneWidth:CGFloat = CGFloat(Double(ScreenWidth) * ScaleFactor)
/// effective scene height, independant from framebuffer
public let SceneHeight:CGFloat = CGFloat(Double(ScreenHeight) * ScaleFactor)
