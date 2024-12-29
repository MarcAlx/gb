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
}
