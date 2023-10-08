import SwiftUI

//to ease view representation
public struct UniqueMessage: Identifiable {
    public let id:UUID = UUID()
    
    //the message itself
    public var message:String
    
    public init(_ msg:String) {
        self.message = msg
    }
}

/// A VM to ease log display
public class LoggingViewModel: ObservableObject {
    @Published var messages:[UniqueMessage] = []
    
    public func log(_ msg:String) {
        if(self.messages.count > 10){
            self.messages.removeLast()
        }
        self.messages.insert(UniqueMessage(msg), at: 0)
    }
}
