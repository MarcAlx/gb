import Foundation
import Swift

enum errors: Error {
    //thrown when cartridge has an invalid size
    case invalidCartridgeSize
    //an instruction with wrong size has been found
    case wrongInstructionSize
    //unknown instruction has been encountered at PC
    case unsupportedInstruction(opCode:OperationCode,fountAt:Short)
    //access to an unsupported memory location
    case unsupportedMemoryLocation(address:Short)
    //unauthorized write
    case readOnlyMemoryLocation(address:Short)
}

extension errors: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .invalidCartridgeSize:
            return NSLocalizedString("Cartridge has an invalid size", comment: "error")
        case .wrongInstructionSize:
            return NSLocalizedString("Instruction is wrongly sized", comment: "error")
        case let .unsupportedInstruction(opCode, fountAt):
            return NSLocalizedString(String(format: "Unsupported instruction: 0x%02X (extended=%d) found at 0x%04X",opCode.code,opCode.isExtended,fountAt), comment: "error")
        case let .unsupportedMemoryLocation(address):
            return NSLocalizedString(String(format:"Unsupported memory location: 0x%04X",address), comment: "error")
        case let .readOnlyMemoryLocation(address):
            return NSLocalizedString(String(format:"Can't write to: 0x%04X",address), comment: "error")
        }
    }
}

public class ErrorReportingService {
    public var errorReporter:ErrorReporter?
    
    public func report(error:Error) {
        self.errorReporter?.submit(error: error)
    }
}

public let GBErrorService:ErrorReportingService = ErrorReportingService()
