import Foundation
import OSLog

protocol Describable {
    ///returns a description
    func describe() -> String
}

///log levels
public enum LogLevel:String {
    case Info  = "INFO"
    case Error = "ERROR"
    case Debug = "DEBUG"
}

///referenced log categories
public enum LogCategory:String {
    case TOP_LEVEL   = "top-level"
    case MOTHERBOARD = "motherboard"
    case CPU         = "cpu"
}

/// a service to centralize logging behaviors
public class LoggingService {
    private var subsystem = Bundle.main.bundleIdentifier!
    
    private var loggers:[LogCategory:Logger] = [:]
    
    ///optionnal to forward any log message to
    public var gbLogger:GBLogger?

    ///log message with the provided category with a given loglevel
    public func log(level:LogLevel,_ category:LogCategory, _ msg:String) {
        let logger:Logger = self.loggers[category] != nil ? self.loggers[category]! : Logger(subsystem: subsystem, category: category.rawValue)
        switch(level) {
        case LogLevel.Debug:
            logger.debug("\(msg)")
        case LogLevel.Info:
            logger.info("\(msg)")
        case LogLevel.Error:
            logger.error("\(msg)")
        }
        //log to system logger
        let fMsg:String = "[\(level.rawValue)] \(category.rawValue) - \(msg)"
        //to console
        print(fMsg)
        //log to view model if any
        self.gbLogger?.log(fMsg)
    }
    
    ///forward to LoggingService.log(Loglevel.Info,catefgory,msg)
    public func log(_ category:LogCategory, _ msg:String) {
        self.log(level:LogLevel.Info, category, msg)
    }
}

///global logging servicd
public let GBLogService:LoggingService = LoggingService()
