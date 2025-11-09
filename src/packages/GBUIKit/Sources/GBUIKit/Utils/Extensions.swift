import SwiftUI
import GBKit

//view modifier to fake Pressed and Released behavior via DragGesture
public struct PressActions: ViewModifier {
    var onPress: () -> Void
    var onRelease: () -> Void
    
    public func body(content: Content) -> some View {
        content
            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .onChanged({ _ in
                        onPress()
                    })
                    .onEnded({ _ in
                        onRelease()
                    })
            )
    }
}

// Our custom view modifier to track rotation and
// call our action
struct DeviceRotationViewModifier: ViewModifier {
    let action: (UIDeviceOrientation) -> Void

    func body(content: Content) -> some View {
        content
            .onAppear()
            .onReceive(NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)) { _ in
                action(UIDevice.current.orientation)
            }
    }
}

//view extension
extension View {
    //to handle press/relase events
    public func pressAction(_ action: @escaping ((Bool) -> Void)) -> some View {
        modifier(PressActions(onPress: {
            action(true)
        }, onRelease: {
            action(false)
        }))
    }
    
    //to hide a view
    public func hidden(_ shouldHide: Bool) -> some View {
            opacity(shouldHide ? 0 : 1)
    }
    
    //to handle device rotation
    func onRotate(perform action: @escaping (UIDeviceOrientation) -> Void) -> some View {
        self.modifier(DeviceRotationViewModifier(action: action))
    }
}

extension SwiftUI.Color {
    ///allows extraction of color compoenent
    var components: (red: CGFloat, green: CGFloat, blue: CGFloat, opacity: CGFloat) {
        typealias NativeColor = UIColor
            var r: CGFloat = 0
            var g: CGFloat = 0
            var b: CGFloat = 0
            var o: CGFloat = 0

            guard NativeColor(self).getRed(&r, green: &g, blue: &b, alpha: &o) else {
                return (0, 0, 0, 0)
            }

            return (r, g, b, o)
        }
}

extension GBKit.Color {
    public func toSWiftUIColor() -> SwiftUI.Color {
        return SwiftUI.Color(red: Double(self.r)/255,
                             green: Double(self.g)/255,
                             blue: Double(self.b)/255)
    }
    
    public static func fromSWiftUIColor(_ color: SwiftUI.Color) -> GBKit.Color {
        //for some reason compoenent can be negative (so min/max)
        return GBKit.Color(Byte(max(0,min(255,color.components.red*255))),
                           Byte(max(0,min(255,color.components.green*255))),
                           Byte(max(0,min(255,color.components.blue*255))))
    }
    
}

public extension String {
    
    /// Returns the localized string from the package's bundle.
    var localized: String {
        NSLocalizedString(self, bundle: .module, comment: "")
    }
}
