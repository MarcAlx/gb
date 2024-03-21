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

/// true if a carry has occured between old and new val (basically checking for overflow)
func hasCarry<T>(_ old:T, _ new:T) -> Bool where T:Comparable, T:Numeric {
    return new < old //if value has overflow (produce carry) then new value is lower than old
}

/// true if a+b produce half carry
func isAddHalfCarry(_ a:Byte,_ b:Byte) -> Bool {
    return (((a & 0xF) + (b & 0xF)) & 0x10) == 0x10
}

/// true if a+b produce half carry
func isAddHalfCarry(_ a:Short,_ b:Short) -> Bool {
    return (((a & 0xFFF) + (b & 0xFFF)) & 0x1000) == 0x1000
}

/// true if a-b produce half borrow (between byte)
func isSubHalfBorrow(_ a:Byte, _ b:Byte) -> Bool {
    return (a & 0xF) < (b & 0xF)
}

/// true if a-b produce half borrow (between short)
func isSubHalfBorrow(_ a:Short, _ b:Short) -> Bool {
    return (a & 0xFFF) < (b & 0xFFF)
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

/// swap msb and lsb in input
func swap_lsb_msb(_ val:Byte) -> Byte {
    return (val << 4) | (val >> 4)
}
