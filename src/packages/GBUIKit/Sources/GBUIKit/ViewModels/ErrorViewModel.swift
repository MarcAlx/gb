import SwiftUI
import GBKit

/**
 * to globally handle errors
 */
public class ErrorViewModel:ObservableObject, ErrorReporter {
    @Published public var hasError:Bool = false
    var errorTitle:String = ""
    var errorMessage:String = ""
    
    ///submit a new error
    public func submit(error:Error) {
        DispatchQueue.main.async {
            self.errorTitle = "An error occured"
            self.errorMessage = error.localizedDescription
            self.hasError = true
        }
    }
}
