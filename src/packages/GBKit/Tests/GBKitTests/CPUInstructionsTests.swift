import XCTest
@testable import GBKit

final class CPUInstructionsTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func test_inc() throws {
        let cpu:CPU = CPU()
        
        cpu.registers.BC = 0
        cpu.inc_bc()
        XCTAssertTrue(cpu.registers.BC == 1)
    }
    
    func test_ld() throws {
        let cpu:CPU = CPU()
        
        cpu.registers.A = 8
        cpu.ld_a_a()
        XCTAssertTrue(cpu.registers.A == 8)
    }

}
