import XCTest
@testable import GBKit

final class ArithmeticsTests: XCTestCase {
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func test_carry() {
        XCTAssertTrue(isAddCarry(UInt8(0),UInt8(1)) == false)
        XCTAssertTrue(isAddCarry(Byte.max, Byte.max) == true)
        XCTAssertTrue(isAddCarry(Short(0),Short(1)) == false)
        XCTAssertTrue(isAddCarry(Short.max, Short.max) == true)
    }
    
    func test_half_carry() {
        XCTAssertTrue(isAddHalfCarry(UInt8(0),UInt8(1)) == false)
        XCTAssertTrue(isAddHalfCarry(UInt8(0b0000_1111), UInt8(0b0000_0001)) == true)
        XCTAssertTrue(isAddHalfCarry(Short(0),Short(1)) == false)
        XCTAssertTrue(isAddHalfCarry(Short(0x0FFF), Short(0x0001)) == true)
    }
    
    func test_fit() {
        XCTAssertTrue(fit(600) == Byte.max)
    }
    
    func test_split() {
        XCTAssertTrue(split(0b1010_1010_0101_0101) == (0b1010_1010,0b0101_0101))
    }
    
    func test_merge() {
        XCTAssertTrue(merge(0xAB,0xCD) == 0xABCD)
    }
    
    func test_flip() {
        XCTAssertTrue(flipBits(0b1010_1010) == 0b0101_0101)
    }
    
    func test_setbit() {
        XCTAssertTrue(set(.Bit_0, 0b0000_0000) == 0b0000_0001)
        XCTAssertTrue(set(.Bit_1, 0b0000_0000) == 0b0000_0010)
        XCTAssertTrue(set(.Bit_2, 0b0000_0000) == 0b0000_0100)
        XCTAssertTrue(set(.Bit_3, 0b0000_0000) == 0b0000_1000)
        XCTAssertTrue(set(.Bit_4, 0b0000_0000) == 0b0001_0000)
        XCTAssertTrue(set(.Bit_5, 0b0000_0000) == 0b0010_0000)
        XCTAssertTrue(set(.Bit_6, 0b0000_0000) == 0b0100_0000)
        XCTAssertTrue(set(.Bit_7, 0b0000_0000) == 0b1000_0000)
    }
    
    func test_clearbit() {
        XCTAssertTrue(clear(.Bit_0, 0b1111_1111) == 0b1111_1110)
        XCTAssertTrue(clear(.Bit_1, 0b1111_1111) == 0b1111_1101)
        XCTAssertTrue(clear(.Bit_2, 0b1111_1111) == 0b1111_1011)
        XCTAssertTrue(clear(.Bit_3, 0b1111_1111) == 0b1111_0111)
        XCTAssertTrue(clear(.Bit_4, 0b1111_1111) == 0b1110_1111)
        XCTAssertTrue(clear(.Bit_5, 0b1111_1111) == 0b1101_1111)
        XCTAssertTrue(clear(.Bit_6, 0b1111_1111) == 0b1011_1111)
        XCTAssertTrue(clear(.Bit_7, 0b1111_1111) == 0b0111_1111)
    }
    
    func test_isbitset() {
        XCTAssertTrue(isBitSet(.Bit_0, 0b0000_0001))
        XCTAssertTrue(isBitSet(.Bit_1, 0b0000_0010))
        XCTAssertTrue(isBitSet(.Bit_2, 0b0000_0100))
        XCTAssertTrue(isBitSet(.Bit_3, 0b0000_1000))
        XCTAssertTrue(isBitSet(.Bit_4, 0b0001_0000))
        XCTAssertTrue(isBitSet(.Bit_5, 0b0010_0000))
        XCTAssertTrue(isBitSet(.Bit_6, 0b0100_0000))
        XCTAssertTrue(isBitSet(.Bit_7, 0b1000_0000))
    }
    
    func test_isbitcleared() {
        XCTAssertTrue(isBitCleared(.Bit_0, 0b1111_1110))
        XCTAssertTrue(isBitCleared(.Bit_1, 0b1111_1101))
        XCTAssertTrue(isBitCleared(.Bit_2, 0b1111_1011))
        XCTAssertTrue(isBitCleared(.Bit_3, 0b1111_0111))
        XCTAssertTrue(isBitCleared(.Bit_4, 0b1110_1111))
        XCTAssertTrue(isBitCleared(.Bit_5, 0b1101_1111))
        XCTAssertTrue(isBitCleared(.Bit_6, 0b1011_1111))
        XCTAssertTrue(isBitCleared(.Bit_7, 0b0111_1111))
    }
    
    func test_swap() {
        XCTAssertTrue(swap_lsb_msb(0b1111_0000) == 0b0000_1111)
    }
}
