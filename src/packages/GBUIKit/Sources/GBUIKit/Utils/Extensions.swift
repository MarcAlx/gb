import SwiftUI

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
