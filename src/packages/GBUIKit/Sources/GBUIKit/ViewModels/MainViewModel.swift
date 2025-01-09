import SwiftUI

/**
 * Main view model
 */
public class MainViewModel:ObservableObject {
    @Published public var fileImporterPresented = false
    @Published public var isFullScreen = false
    @Published public var screenBackground = Color.gray
}
