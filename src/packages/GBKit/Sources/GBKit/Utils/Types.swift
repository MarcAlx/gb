///Byte is shorthand for UInt8
public typealias Byte = UInt8

///Short is shorthand ife UInt16
public typealias Short = UInt16
///enhanced short
public typealias EnhancedShort = TwoBytesWrapper

/// two bytes wrapper
public struct TwoBytesWrapper {
    ///most significant bytes
    public var msb:Byte
    
    ///least significant bytes
    public var lsb:Byte

    ///value
    public var value:Short {
        get { 
            return merge(self.msb,self.lsb)
        }
        set { 
            (self.msb,self.lsb) = split(newValue)
        }
    }
    
    public init(_ lsb:Byte, _ msb:Byte) {
        self.lsb = lsb
        self.msb = msb
    }
    
    public init(_ short:Short) {
        let (msb,lsb) = split(short)
        self.init(lsb,msb)
    }
    
    public init() {
        self.init(0,0)
    }
}
