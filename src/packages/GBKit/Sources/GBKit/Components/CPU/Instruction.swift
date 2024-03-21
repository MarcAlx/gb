///an instruction that sizes one byte: no argument only instruction (1b)
typealias OneByteInstruction    = ()              -> Void
///an instruction that sizes two bytes: instruction (1b) + one argument (1b)
typealias TwoBytesInstruction   = (Byte)          -> Void
///an instruction that'sizes three bytes: instruction (1b) + first argument (1b) + second argument (1b)
typealias ThreeBytesInstruction = (EnhancedShort) -> Void
//variable length instruction: a wrapper for One Two or Three bytes instruction (sadly swift doesn't support optional arg in closure)
typealias VariableLengthInstruction = (_ byte:Byte?,_ short:EnhancedShort?) -> Void
//an instruction whose length is unknown, so two bytes are passed
typealias UnknownLengthInstruction   = (Byte,Byte)      -> Void

let emptyOneByteInstruction: OneByteInstruction       = { }
let emptyTwoBytesInstruction: TwoBytesInstruction     = { byte in }
let emptyThreeBytesInstruction: ThreeBytesInstruction = { short in }
let emptyUnkownLengthInstruction: UnknownLengthInstruction = { b1,b2 in }
let emptyVariableLengthInstruction: VariableLengthInstruction = { byte,eShort in }

/// instruction length
enum InstructionLength:UInt8, ExpressibleByIntegerLiteral {
    case OneByte    = 1
    case TwoBytes   = 2
    case ThreeBytes = 3
    
    ///to allow int affectation
    init(integerLiteral value: IntegerLiteralType) {
        if(value == 3){
            self = .ThreeBytes
        }
        else if(value == 2){
            self = .TwoBytes
        }
        else {
            self = .OneByte
        }
    }
}

struct Instruction {
    /// implementation used if instructon is a one byte one
    private let impl1:OneByteInstruction
    /// implementation used if instructon is a two bytes one
    private let impl2:TwoBytesInstruction
    /// implementation used if instructon is a three bytes one
    private let impl3:ThreeBytesInstruction
    
    /// opcode
    let opCode:UInt8?
    
    /// instruction length in byte, no parameters instruction are 1 byte long, where 1 paremeters are 2 and 2 parameters are 3.
    let length:InstructionLength
    
    /// instruction's name
    let name:String
    
    /// in M cycle
    let duration:Int
    
    public init(length: InstructionLength,
                name: String,
                duration:Int,
                _ impl:OneByteInstruction?) {
        self.init(opCode: nil, length: length, name: name, duration: duration,impl1:impl)
    }
    
    public init(opCode: Byte,
                length: InstructionLength,
                name: String,
                duration:Int,
                _ impl:OneByteInstruction? = nil) {
        self.init(opCode: opCode, length: length, name: name, duration: duration,impl1:impl)
    }
    
    public init(opCode: Byte,
                length: InstructionLength,
                name: String,
                duration:Int,
                _ impl:TwoBytesInstruction? = nil) {
        self.init(opCode: opCode, length: length, name: name, duration: duration,impl2:impl)
    }
    
    public init(opCode: Byte,
                length: InstructionLength,
                name: String,
                duration:Int,
                _ impl:ThreeBytesInstruction? = nil) {
        self.init(opCode: opCode, length: length, name: name, duration: duration,impl3:impl)
    }
    
    private init(opCode: Byte?,
                 length: InstructionLength,
                 name: String,
                 duration:Int,
                 impl1:OneByteInstruction? = nil,
                 impl2:TwoBytesInstruction? = nil,
                 impl3:ThreeBytesInstruction? = nil) {
        self.opCode = opCode
        self.length = length
        self.name = name
        self.duration = duration
        self.impl1 = impl1 ?? emptyOneByteInstruction
        self.impl2 = impl2 ?? emptyTwoBytesInstruction
        self.impl3 = impl3 ?? emptyThreeBytesInstruction
    }
    
    /// execute the instruction as a one byte instruction (does nothing if not of the correct size)
    public func execute()  {
        self.impl1()
    }
    
    /// execute the instruction as a two bytes instruction (does nothing if not of the correct size)
    public func execute(_ byteArg:UInt8)  {
        self.impl2(byteArg)
    }
    
    /// execute the instruction as a three bytes instruction (does nothing if not of the correct size)
    public func execute(_ shortArg:EnhancedShort)  {
        self.impl3(shortArg)
    }
}
