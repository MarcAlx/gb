import XCTest
@testable import GBKit

final class MMUTests: XCTestCase {
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func test_rom() throws {
        let mmu:MMU = MMU()
        mmu.reset()
        mmu[0] = 0xFF
        XCTAssertTrue(mmu[0] == 0)
    }
    
    func test_echo() throws {
        let mmu:MMU = MMU()
        mmu.reset()
        mmu[MMUAddresses.ECHO_RAM.rawValue] = 0xFF
        XCTAssertTrue(mmu[MMUAddresses.WORK_RAM.rawValue] == 0xFF)
    }
    
    func test_prohibited() throws {
        let mmu:MMU = MMU()
        mmu.reset()
        mmu[MMUAddresses.PROHIBITED_AREA.rawValue] = 0xFF
        XCTAssertTrue(mmu[MMUAddresses.PROHIBITED_AREA.rawValue] == 0x00)
    }
    
    func test_lcdstat() throws {
        let mmu:MMU = MMU()
        mmu.reset()
        mmu.directWrite(address: IOAddresses.LCD_STATUS.rawValue, val: Byte(0xFF))
        XCTAssertTrue(mmu[IOAddresses.LCD_STATUS.rawValue] == 0b1111_1111)
    }
}
