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
    
    func test_swap() {
        XCTAssertTrue(swap_lsb_msb(0b1111_0000) == 0b0000_1111)
    }
}
