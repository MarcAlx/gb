import XCTest
@testable import GBKit

final class CPUFlagsTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func test_raise() throws {
        let cpu:CPU = CPU(mmu: MMU())
        cpu.registers.F = 0
        cpu.registers.raiseFlag(.ZERO);
        XCTAssertTrue(cpu.registers.F == 0b1000_0000)
        cpu.registers.F = 0
        cpu.registers.raiseFlag(.NEGATIVE);
        XCTAssertTrue(cpu.registers.F == 0b0100_0000)
        cpu.registers.F = 0
        cpu.registers.raiseFlag(.HALF_CARRY);
        XCTAssertTrue(cpu.registers.F == 0b0010_0000)
        cpu.registers.F = 0
        cpu.registers.raiseFlag(.CARRY);
        XCTAssertTrue(cpu.registers.F == 0b0001_0000)
    }
    
    func test_clear() throws {
        let cpu:CPU = CPU(mmu: MMU())
        cpu.registers.F = 0b1111_0000
        cpu.registers.clearFlag(.ZERO);
        XCTAssertTrue(cpu.registers.F == 0b0111_0000)
        cpu.registers.clearFlag(.NEGATIVE);
        XCTAssertTrue(cpu.registers.F == 0b0011_0000)
        cpu.registers.clearFlag(.HALF_CARRY);
        XCTAssertTrue(cpu.registers.F == 0b0001_0000)
        cpu.registers.clearFlag(.CARRY);
        XCTAssertTrue(cpu.registers.F == 0b0000_0000)
    }
    
    func test_isset() throws {
        let cpu:CPU = CPU(mmu: MMU())
        cpu.registers.F = 0b1000_0000
        XCTAssertTrue(cpu.registers.isFlagSet(.ZERO))
        cpu.registers.F = 0b0100_0000
        XCTAssertTrue(cpu.registers.isFlagSet(.NEGATIVE))
        cpu.registers.F = 0b0010_0000
        XCTAssertTrue(cpu.registers.isFlagSet(.HALF_CARRY))
        cpu.registers.F = 0b0001_0000
        XCTAssertTrue(cpu.registers.isFlagSet(.CARRY))
    }
    
    func test_isclear() throws {
        let cpu:CPU = CPU(mmu: MMU())
        cpu.registers.F = 0b0000_0000
        XCTAssertTrue(cpu.registers.isFlagCleared(.ZERO))
        XCTAssertTrue(cpu.registers.isFlagCleared(.NEGATIVE))
        XCTAssertTrue(cpu.registers.isFlagCleared(.HALF_CARRY))
        XCTAssertTrue(cpu.registers.isFlagCleared(.CARRY))
    }
    
    func test_conditional_set() throws {
        let cpu:CPU = CPU(mmu: MMU())
        cpu.registers.F = 0
        for f in [CPUFlag.ZERO, CPUFlag.NEGATIVE, CPUFlag.HALF_CARRY, CPUFlag.CARRY] {
            cpu.registers.conditionalSet(cond: true, flag: f)
            XCTAssertTrue(cpu.registers.isFlagSet(f))
            cpu.registers.conditionalSet(cond: false, flag: f)
            XCTAssertTrue(cpu.registers.isFlagCleared(f))
        }
    }

}
