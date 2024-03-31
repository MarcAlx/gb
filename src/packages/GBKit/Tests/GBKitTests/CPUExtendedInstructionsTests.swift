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
        
        cpu.registers.B = 0b0000_1111
        cpu.swap_b()
        XCTAssertTrue(cpu.registers.B == 0b1111_0000)
        
        cpu.registers.C = 0b0000_1111
        cpu.swap_c()
        XCTAssertTrue(cpu.registers.C == 0b1111_0000)
        
        cpu.registers.D = 0b0000_1111
        cpu.swap_d()
        XCTAssertTrue(cpu.registers.D == 0b1111_0000)
        
        cpu.registers.E = 0b0000_1111
        cpu.swap_e()
        XCTAssertTrue(cpu.registers.E == 0b1111_0000)
        
        cpu.registers.H = 0b0000_1111
        cpu.swap_h()
        XCTAssertTrue(cpu.registers.H == 0b1111_0000)
        
        cpu.registers.L = 0b0000_1111
        cpu.swap_l()
        XCTAssertTrue(cpu.registers.L == 0b1111_0000)
        
        cpu.registers.HL = MMUAddresses.WORK_RAM.rawValue
        cpu.mmu[cpu.registers.HL] = 0b0000_1111
        cpu.swap_hlp()
        XCTAssertTrue(cpu.mmu[cpu.registers.HL] == 0b1111_0000)
        
        cpu.registers.A = 0b0000_1111
        cpu.swap_a()
        XCTAssertTrue(cpu.registers.A == 0b1111_0000)
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
