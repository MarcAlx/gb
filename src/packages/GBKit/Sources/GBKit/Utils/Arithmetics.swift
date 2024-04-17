import Foundation

/// 8bit/byte mask to extract/check bit
enum ByteMask: Byte {
    case Bit_7 = 0b1000_0000
    case Bit_6 = 0b0100_0000
    case Bit_5 = 0b0010_0000
    case Bit_4 = 0b0001_0000
    case Bit_3 = 0b0000_1000
    case Bit_2 = 0b0000_0100
    case Bit_1 = 0b0000_0010
    case Bit_0 = 0b0000_0001
}

/// to ease access of bytemask from int
let IntToByteMask:[ByteMask] = [
    ByteMask.Bit_0,
    ByteMask.Bit_1,
    ByteMask.Bit_2,
    ByteMask.Bit_3,
    ByteMask.Bit_4,
    ByteMask.Bit_5,
    ByteMask.Bit_6,
    ByteMask.Bit_7
]

/// 8bit/byte mask to extract/check bit
enum NegativeByteMask: Byte {
    case Bit_7 = 0b0111_1111
    case Bit_6 = 0b1011_1111
    case Bit_5 = 0b1101_1111
    case Bit_4 = 0b1110_1111
    case Bit_3 = 0b1111_0111
    case Bit_2 = 0b1111_1011
    case Bit_1 = 0b1111_1101
    case Bit_0 = 0b1111_1110
}

/// true if new value has overflown old
func hasOverflown<T>(_ old:T, _ new:T) -> Bool where T:Comparable, T:Numeric {
    return new < old //if value has overflow then new value is lower than old
}

/// true if a+b produce carry
func isAddCarry(_ a:Byte,_ b:Byte) -> Bool {
    return (a &+ b) < a // &+ doesn't produce overflow, so if addition is < to first operand, &+ has overflown (thus carry)
}

// true if a+b+carry produce carry (overflown Byte.max)
func isAddCarry(_ a:Byte,_ b:Byte, _ carry:Byte) -> Bool {
    return (Int(a)+Int(b)+Int(carry))>Int(Byte.max)
}

/// true if a+b produce carry
func isAddCarry(_ a:Short,_ b:Short) -> Bool {
    return (a &+ b) < a // &+ doesn't produce overflow, so if addition is < to first operand, &+ has overflown (thus carry)
}

/// true if a+b produce half carry (byte 3 to byte 4)
func isAddHalfCarry(_ a:Byte,_ b:Byte) -> Bool {
    //true if a.lsb + b.lsb produce a number with bit 4 set
    return (((a & 0xF) + (b & 0xF)) & 0x10) == 0x10
}

/// true if a+b+carry produce half carry (byte 3 to byte 4)
func isAddHalfCarry(_ a:Byte,_ b:Byte, _ carry:Byte) -> Bool {
    //true if a.lsb + b.lsb + carry produce a number with bit 4 set
    return (((a & 0xF) &+ (b & 0xF) &+ carry) & 0x10) == 0x10
}

/// true if byte + short produce half carry (byte 3 to byte 4)
func isAddHalfCarry(_ a:Short,_ b:Byte) -> Bool {
    return isAddHalfCarry(Byte(a&0xFF/*keep only msb of a*/),b)
}

/// true if a+b produce half carry (for some reason not from 7 to 8 but from 11 to 12)
func isAddHalfCarry(_ a:Short,_ b:Short) -> Bool {
    //true if a.lsb + b.lsb produce a number with bit 12 set
    return (((a & 0xFFF) + (b & 0xFFF)) & 0x1000) == 0x1000 //a+b > 0x0FFF
}

/// true if a-b produce half borrow (between byte)
func isSubHalfBorrow(_ a:Byte, _ b:Byte) -> Bool {
    return (a & 0xF) < (b & 0xF)
}

/// true if a-b-carry produce half borrow (between byte)
func isSubHalfBorrow(_ a:Byte, _ b:Byte, _ carry:Byte) -> Bool {
    return a&0xF < (b&0xF &+ carry)
}

/// true if a-b produce half borrow (between short)
func isSubHalfBorrow(_ a:Short, _ b:Short) -> Bool {
    return (a & 0xFFF) < (b & 0xFFF)
}

/// true if (b+carry)>a
func isSubBorrow(_ a:Byte, _ b:Byte, _ carry:Byte) -> Bool {
    return Int(a)<(Int(b)+Int(carry))
}

/// Merges two UInt8 into an UInt16
func merge(_ msb:Byte,_ lsb:Byte) -> Short {
    return UInt16(msb) << 8 | UInt16(lsb)
}

/// Splits an UInt16 into a tuple of two UInt8 (msb,lsb)
func split(_ i:Short) -> (Byte,Byte) {
    return (UInt8(i >> 8),UInt8((i << 8) >> 8))
}

/// fit an int to a Byte
func fit(_ i:Int) -> Byte {
    return i > UInt8.max ? UInt8.max : UInt8(i)
}

/// fit an int to a Short
func fit(_ i:Int) -> Short {
    return i > UInt16.max ? UInt16.max : UInt16(i)
}

/// true if bit identified by mask is 1 in val
func isBitSet(_ mask:ByteMask,_ val:Byte) -> Bool {
    return (val & mask.rawValue) > 0
}

/// true if bit identified by mask is 0 in val
func isBitCleared(_ mask:ByteMask,_ val:Byte) -> Bool {
    return (val & mask.rawValue) == 0
}

/// set given bit to 0 in byte
func clear(_ mask: NegativeByteMask,_ val: Byte) -> Byte {
    return (val & mask.rawValue)
}

/// set given bit to 1 in byte
func set(_ mask: ByteMask, _ val: Byte) -> Byte {
    return (val | mask.rawValue)
}

/// flip all bits in val
func flipBits(_ val: Byte) -> Byte {
    return ~val
}

/// swap msb and lsb in input
func swap_lsb_msb(_ val:Byte) -> Byte {
    return (val << 4) | (val >> 4)
}

/// Add a Byte (considered as i8) to short value, while avoiding overflow
func add_byte_i8(val:Byte, i8:Byte) -> Byte {
    let delta:Int = Int(Int8(bitPattern: i8))//delta can be negative, aka two bits complement (two's complement)
    let iVal:Int = Int(val);
    return Byte((delta+iVal)%255)//mod 255 in order to keep circularity of add
}

/// Add a Byte (considered as i8) to short value, while avoiding overflow
func add_short_i8(val:Short, i8:Byte) -> Short {
    let delta:Int8 = Int8(bitPattern: i8)//delta can be negative, aka two bits complement (two's complement)
    
    //add must be circular
    if(delta < 0){
        return val &- Short(-delta)
    }
    else {
        return val &+ Short(delta)
    }
}
