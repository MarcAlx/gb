import Foundation
import os.log

protocol Describable {
    ///returns a description
    func describe() -> String
}

///log levels
enum LogLevel:String {
    case Info  = "INFO"
    case Error = "ERROR"
    case Debug = "DEBUG"
}

///referenced log categories
enum LogCategory:String {
    case TOP_LEVEL   = "top-level"
    case MOTHERBOARD = "motherboard"
    case CPU         = "cpu"
}

/// a service to centralize logging behaviors
class LoggingService {
    private var subsystem = Bundle.main.bundleIdentifier!
    ///map each log category to its logger
    private var loggers:[LogCategory:Logger] = [:]
    ///optionnal logVM to forward any log message to
    public var logViewModel:LoggingViewModel?

    ///log message with the provided category with a given loglevel
    public func log(level:LogLevel,_ category:LogCategory, _ msg:String) {
        //log to system logger
        let logger:Logger = self.loggers[category] != nil ? self.loggers[category]! : Logger(subsystem: subsystem, category: category.rawValue)
        switch(level) {
        case LogLevel.Debug:
            logger.debug("\(msg)")
        case LogLevel.Info:
            logger.info("\(msg)")
        case LogLevel.Error:
            logger.error("\(msg)")
        }
        let fMsg:String = "[\(level.rawValue)] \(category.rawValue) - \(msg)"
        //to console
        print(fMsg)
        //log to view model if any
        self.logViewModel?.log(fMsg)
    }
    
    ///forward to LoggingService.log(Loglevel.Info,catefgory,msg)
    public func log(_ category:LogCategory, _ msg:String) {
        self.log(level:LogLevel.Info, category, msg)
    }
}

///global logging servicd
let LogService:LoggingService = LoggingService()
