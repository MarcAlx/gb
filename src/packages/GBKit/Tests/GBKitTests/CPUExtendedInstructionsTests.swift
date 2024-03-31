import XCTest
@testable import GBKit

final class CPUExtendedInstructionsTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func test_indexation() throws {
        let cpu:CPU = CPU()
        
        let inst = cpu.asExtentedInstructions()
        for i in 0...255 {
            XCTAssertTrue(Byte(i) == inst[i].opCode)
        }
    }
    
    func test_rlc() throws {
        let cpu:CPU = CPU()
        XCTAssertTrue(false)
    }
    
    func test_rrc() throws {
        let cpu:CPU = CPU()
        XCTAssertTrue(false)
    }
    
    func test_rl() throws {
        let cpu:CPU = CPU()
        XCTAssertTrue(false)
    }
    
    func test_rr() throws {
        let cpu:CPU = CPU()
        XCTAssertTrue(false)
    }
    
    func test_sla() throws {
        let cpu:CPU = CPU()
        XCTAssertTrue(false)
    }
    
    func test_sra() throws {
        let cpu:CPU = CPU()
        XCTAssertTrue(false)
    }
    
    func test_swap() throws {
        let cpu:CPU = CPU()
        XCTAssertTrue(false)
    }
    
    func test_srl() throws {
        let cpu:CPU = CPU()
        XCTAssertTrue(false)
    }
    
    func test_bit() throws {
        let cpu:CPU = CPU()
        XCTAssertTrue(false)
    }
    
    func test_res() throws {
        let cpu:CPU = CPU()
        XCTAssertTrue(false)
    }
    
    func test_set() throws {
        let cpu:CPU = CPU()
        XCTAssertTrue(false)
    }
}
