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
        let cpu:CPU = CPU(mmu: MMU())
        
        let inst = cpu.asExtentedInstructions()
        for i in 0...255 {
            XCTAssertTrue(Byte(i) == inst[i].opCode)
        }
    }
    
    func test_rlc() throws {
        let cpu:CPU = CPU(mmu: MMU())
        XCTAssertTrue(false)
    }
    
    func test_rrc() throws {
        let cpu:CPU = CPU(mmu: MMU())
        XCTAssertTrue(false)
    }
    
    func test_rl() throws {
        let cpu:CPU = CPU(mmu: MMU())
        XCTAssertTrue(false)
    }
    
    func test_rr() throws {
        let cpu:CPU = CPU(mmu: MMU())
        XCTAssertTrue(false)
    }
    
    func test_sla() throws {
        let cpu:CPU = CPU(mmu: MMU())
        XCTAssertTrue(false)
    }
    
    func test_sra() throws {
        let cpu:CPU = CPU(mmu: MMU())
        XCTAssertTrue(false)
    }
    
    func test_swap() throws {
        let cpu:CPU = CPU(mmu: MMU())
        
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
        let cpu:CPU = CPU(mmu: MMU())
        XCTAssertTrue(false)
    }
    
    func test_bit() throws {
        let cpu:CPU = CPU(mmu: MMU())
        
        cpu.registers.B = 0b1111_1110
        cpu.bit_0_b()
        XCTAssertTrue(cpu.registers.isFlagSet(.ZERO))
        cpu.registers.B = 0b0000_0001
        cpu.bit_0_b()
        XCTAssertTrue(cpu.registers.isFlagCleared(.ZERO))
        
        cpu.registers.C = 0b1111_1110
        cpu.bit_0_c()
        XCTAssertTrue(cpu.registers.isFlagSet(.ZERO))
        cpu.registers.C = 0b0000_0001
        cpu.bit_0_c()
        XCTAssertTrue(cpu.registers.isFlagCleared(.ZERO))
        
        cpu.registers.D = 0b1111_1110
        cpu.bit_0_d()
        XCTAssertTrue(cpu.registers.isFlagSet(.ZERO))
        cpu.registers.D = 0b0000_0001
        cpu.bit_0_d()
        XCTAssertTrue(cpu.registers.isFlagCleared(.ZERO))
        
        cpu.registers.E = 0b1111_1110
        cpu.bit_0_e()
        XCTAssertTrue(cpu.registers.isFlagSet(.ZERO))
        cpu.registers.E = 0b0000_0001
        cpu.bit_0_e()
        XCTAssertTrue(cpu.registers.isFlagCleared(.ZERO))
        
        cpu.registers.H = 0b1111_1110
        cpu.bit_0_h()
        XCTAssertTrue(cpu.registers.isFlagSet(.ZERO))
        cpu.registers.H = 0b0000_0001
        cpu.bit_0_h()
        XCTAssertTrue(cpu.registers.isFlagCleared(.ZERO))
        
        cpu.registers.L = 0b1111_1110
        cpu.bit_0_l()
        XCTAssertTrue(cpu.registers.isFlagSet(.ZERO))
        cpu.registers.L = 0b0000_0001
        cpu.bit_0_l()
        XCTAssertTrue(cpu.registers.isFlagCleared(.ZERO))
        
        cpu.registers.HL = MMUAddresses.WORK_RAM.rawValue
        cpu.mmu[cpu.registers.HL] = 0b1111_1110
        cpu.bit_0_hlp()
        XCTAssertTrue(cpu.registers.isFlagSet(.ZERO))
        cpu.mmu[cpu.registers.HL] = 0b0000_0001
        cpu.bit_0_hlp()
        XCTAssertTrue(cpu.registers.isFlagCleared(.ZERO))
        
        cpu.registers.A = 0b1111_1110
        cpu.bit_0_a()
        XCTAssertTrue(cpu.registers.isFlagSet(.ZERO))
        cpu.registers.A = 0b0000_0001
        cpu.bit_0_a()
        XCTAssertTrue(cpu.registers.isFlagCleared(.ZERO))
        
        cpu.registers.B = 0b1111_1101
        cpu.bit_1_b()
        XCTAssertTrue(cpu.registers.isFlagSet(.ZERO))
        cpu.registers.B = 0b0000_0010
        cpu.bit_1_b()
        XCTAssertTrue(cpu.registers.isFlagCleared(.ZERO))
        
        cpu.registers.C = 0b1111_1101
        cpu.bit_1_c()
        XCTAssertTrue(cpu.registers.isFlagSet(.ZERO))
        cpu.registers.C = 0b0000_0010
        cpu.bit_1_c()
        XCTAssertTrue(cpu.registers.isFlagCleared(.ZERO))
        
        cpu.registers.D = 0b1111_1101
        cpu.bit_1_d()
        XCTAssertTrue(cpu.registers.isFlagSet(.ZERO))
        cpu.registers.D = 0b0000_0010
        cpu.bit_1_d()
        XCTAssertTrue(cpu.registers.isFlagCleared(.ZERO))
        
        cpu.registers.E = 0b1111_1101
        cpu.bit_1_e()
        XCTAssertTrue(cpu.registers.isFlagSet(.ZERO))
        cpu.registers.E = 0b0000_0010
        cpu.bit_1_e()
        XCTAssertTrue(cpu.registers.isFlagCleared(.ZERO))
        
        cpu.registers.H = 0b1111_1101
        cpu.bit_1_h()
        XCTAssertTrue(cpu.registers.isFlagSet(.ZERO))
        cpu.registers.H = 0b0000_0010
        cpu.bit_1_h()
        XCTAssertTrue(cpu.registers.isFlagCleared(.ZERO))
        
        cpu.registers.L = 0b1111_1101
        cpu.bit_1_l()
        XCTAssertTrue(cpu.registers.isFlagSet(.ZERO))
        cpu.registers.L = 0b0000_0010
        cpu.bit_1_l()
        XCTAssertTrue(cpu.registers.isFlagCleared(.ZERO))
        
        cpu.registers.HL = MMUAddresses.WORK_RAM.rawValue
        cpu.mmu[cpu.registers.HL] = 0b1111_1101
        cpu.bit_1_hlp()
        XCTAssertTrue(cpu.registers.isFlagSet(.ZERO))
        cpu.mmu[cpu.registers.HL] = 0b0000_0010
        cpu.bit_1_hlp()
        XCTAssertTrue(cpu.registers.isFlagCleared(.ZERO))
        
        cpu.registers.A = 0b1111_1101
        cpu.bit_1_a()
        XCTAssertTrue(cpu.registers.isFlagSet(.ZERO))
        cpu.registers.A = 0b0000_0010
        cpu.bit_1_a()
        XCTAssertTrue(cpu.registers.isFlagCleared(.ZERO))
        
        cpu.registers.B = 0b1111_1011
        cpu.bit_2_b()
        XCTAssertTrue(cpu.registers.isFlagSet(.ZERO))
        cpu.registers.B = 0b0000_0100
        cpu.bit_2_b()
        XCTAssertTrue(cpu.registers.isFlagCleared(.ZERO))
        
        cpu.registers.C = 0b1111_1011
        cpu.bit_2_c()
        XCTAssertTrue(cpu.registers.isFlagSet(.ZERO))
        cpu.registers.C = 0b0000_0100
        cpu.bit_2_c()
        XCTAssertTrue(cpu.registers.isFlagCleared(.ZERO))
        
        cpu.registers.D = 0b1111_1011
        cpu.bit_2_d()
        XCTAssertTrue(cpu.registers.isFlagSet(.ZERO))
        cpu.registers.D = 0b0000_0100
        cpu.bit_2_d()
        XCTAssertTrue(cpu.registers.isFlagCleared(.ZERO))
        
        cpu.registers.E = 0b1111_1011
        cpu.bit_2_e()
        XCTAssertTrue(cpu.registers.isFlagSet(.ZERO))
        cpu.registers.E = 0b0000_0100
        cpu.bit_2_e()
        XCTAssertTrue(cpu.registers.isFlagCleared(.ZERO))
        
        cpu.registers.H = 0b1111_1011
        cpu.bit_2_h()
        XCTAssertTrue(cpu.registers.isFlagSet(.ZERO))
        cpu.registers.H = 0b0000_0100
        cpu.bit_2_h()
        XCTAssertTrue(cpu.registers.isFlagCleared(.ZERO))
        
        cpu.registers.L = 0b1111_1011
        cpu.bit_2_l()
        XCTAssertTrue(cpu.registers.isFlagSet(.ZERO))
        cpu.registers.L = 0b0000_0100
        cpu.bit_2_l()
        XCTAssertTrue(cpu.registers.isFlagCleared(.ZERO))
        
        cpu.registers.HL = MMUAddresses.WORK_RAM.rawValue
        cpu.mmu[cpu.registers.HL] = 0b1111_1011
        cpu.bit_2_hlp()
        XCTAssertTrue(cpu.registers.isFlagSet(.ZERO))
        cpu.mmu[cpu.registers.HL] = 0b0000_0100
        cpu.bit_2_hlp()
        XCTAssertTrue(cpu.registers.isFlagCleared(.ZERO))
        
        cpu.registers.A = 0b1111_1011
        cpu.bit_2_a()
        XCTAssertTrue(cpu.registers.isFlagSet(.ZERO))
        cpu.registers.A = 0b0000_0100
        cpu.bit_2_a()
        XCTAssertTrue(cpu.registers.isFlagCleared(.ZERO))
        
        cpu.registers.B = 0b1111_0111
        cpu.bit_3_b()
        XCTAssertTrue(cpu.registers.isFlagSet(.ZERO))
        cpu.registers.B = 0b0000_1000
        cpu.bit_3_b()
        XCTAssertTrue(cpu.registers.isFlagCleared(.ZERO))
        
        cpu.registers.C = 0b1111_0111
        cpu.bit_3_c()
        XCTAssertTrue(cpu.registers.isFlagSet(.ZERO))
        cpu.registers.C = 0b0000_1000
        cpu.bit_3_c()
        XCTAssertTrue(cpu.registers.isFlagCleared(.ZERO))
        
        cpu.registers.D = 0b1111_0111
        cpu.bit_3_d()
        XCTAssertTrue(cpu.registers.isFlagSet(.ZERO))
        cpu.registers.D = 0b0000_1000
        cpu.bit_3_d()
        XCTAssertTrue(cpu.registers.isFlagCleared(.ZERO))
        
        cpu.registers.E = 0b1111_0111
        cpu.bit_3_e()
        XCTAssertTrue(cpu.registers.isFlagSet(.ZERO))
        cpu.registers.E = 0b0000_1000
        cpu.bit_3_e()
        XCTAssertTrue(cpu.registers.isFlagCleared(.ZERO))
        
        cpu.registers.H = 0b1111_0111
        cpu.bit_3_h()
        XCTAssertTrue(cpu.registers.isFlagSet(.ZERO))
        cpu.registers.H = 0b0000_1000
        cpu.bit_3_h()
        XCTAssertTrue(cpu.registers.isFlagCleared(.ZERO))
        
        cpu.registers.L = 0b1111_0111
        cpu.bit_3_l()
        XCTAssertTrue(cpu.registers.isFlagSet(.ZERO))
        cpu.registers.L = 0b0000_1000
        cpu.bit_3_l()
        XCTAssertTrue(cpu.registers.isFlagCleared(.ZERO))
        
        cpu.registers.HL = MMUAddresses.WORK_RAM.rawValue
        cpu.mmu[cpu.registers.HL] = 0b1111_0111
        cpu.bit_3_hlp()
        XCTAssertTrue(cpu.registers.isFlagSet(.ZERO))
        cpu.mmu[cpu.registers.HL] = 0b0000_1000
        cpu.bit_3_hlp()
        XCTAssertTrue(cpu.registers.isFlagCleared(.ZERO))
        
        cpu.registers.A = 0b1111_0111
        cpu.bit_3_a()
        XCTAssertTrue(cpu.registers.isFlagSet(.ZERO))
        cpu.registers.A = 0b0000_1000
        cpu.bit_3_a()
        XCTAssertTrue(cpu.registers.isFlagCleared(.ZERO))
        
        cpu.registers.B = 0b1110_1111
        cpu.bit_4_b()
        XCTAssertTrue(cpu.registers.isFlagSet(.ZERO))
        cpu.registers.B = 0b0001_0000
        cpu.bit_4_b()
        XCTAssertTrue(cpu.registers.isFlagCleared(.ZERO))
        
        cpu.registers.C = 0b1110_1111
        cpu.bit_4_c()
        XCTAssertTrue(cpu.registers.isFlagSet(.ZERO))
        cpu.registers.C = 0b0001_0000
        cpu.bit_4_c()
        XCTAssertTrue(cpu.registers.isFlagCleared(.ZERO))
        
        cpu.registers.D = 0b1110_1111
        cpu.bit_4_d()
        XCTAssertTrue(cpu.registers.isFlagSet(.ZERO))
        cpu.registers.D = 0b0001_0000
        cpu.bit_4_d()
        XCTAssertTrue(cpu.registers.isFlagCleared(.ZERO))
        
        cpu.registers.E = 0b1110_1111
        cpu.bit_4_e()
        XCTAssertTrue(cpu.registers.isFlagSet(.ZERO))
        cpu.registers.E = 0b0001_0000
        cpu.bit_4_e()
        XCTAssertTrue(cpu.registers.isFlagCleared(.ZERO))
        
        cpu.registers.H = 0b1110_1111
        cpu.bit_4_h()
        XCTAssertTrue(cpu.registers.isFlagSet(.ZERO))
        cpu.registers.H = 0b0001_0000
        cpu.bit_4_h()
        XCTAssertTrue(cpu.registers.isFlagCleared(.ZERO))
        
        cpu.registers.L = 0b1110_1111
        cpu.bit_4_l()
        XCTAssertTrue(cpu.registers.isFlagSet(.ZERO))
        cpu.registers.L = 0b0001_0000
        cpu.bit_4_l()
        XCTAssertTrue(cpu.registers.isFlagCleared(.ZERO))
        
        cpu.registers.HL = MMUAddresses.WORK_RAM.rawValue
        cpu.mmu[cpu.registers.HL] = 0b1110_1111
        cpu.bit_4_hlp()
        XCTAssertTrue(cpu.registers.isFlagSet(.ZERO))
        cpu.mmu[cpu.registers.HL] = 0b0001_0000
        cpu.bit_4_hlp()
        XCTAssertTrue(cpu.registers.isFlagCleared(.ZERO))
        
        cpu.registers.A = 0b1110_1111
        cpu.bit_4_a()
        XCTAssertTrue(cpu.registers.isFlagSet(.ZERO))
        cpu.registers.A = 0b0001_0000
        cpu.bit_4_a()
        XCTAssertTrue(cpu.registers.isFlagCleared(.ZERO))
        
        cpu.registers.B = 0b1101_1111
        cpu.bit_5_b()
        XCTAssertTrue(cpu.registers.isFlagSet(.ZERO))
        cpu.registers.B = 0b0010_0000
        cpu.bit_5_b()
        XCTAssertTrue(cpu.registers.isFlagCleared(.ZERO))
        
        cpu.registers.C = 0b1101_1111
        cpu.bit_5_c()
        XCTAssertTrue(cpu.registers.isFlagSet(.ZERO))
        cpu.registers.C = 0b0010_0000
        cpu.bit_5_c()
        XCTAssertTrue(cpu.registers.isFlagCleared(.ZERO))
        
        cpu.registers.D = 0b1101_1111
        cpu.bit_5_d()
        XCTAssertTrue(cpu.registers.isFlagSet(.ZERO))
        cpu.registers.D = 0b0010_0000
        cpu.bit_5_d()
        XCTAssertTrue(cpu.registers.isFlagCleared(.ZERO))
        
        cpu.registers.E = 0b1101_1111
        cpu.bit_5_e()
        XCTAssertTrue(cpu.registers.isFlagSet(.ZERO))
        cpu.registers.E = 0b0010_0000
        cpu.bit_5_e()
        XCTAssertTrue(cpu.registers.isFlagCleared(.ZERO))
        
        cpu.registers.H = 0b1101_1111
        cpu.bit_5_h()
        XCTAssertTrue(cpu.registers.isFlagSet(.ZERO))
        cpu.registers.H = 0b0010_0000
        cpu.bit_5_h()
        XCTAssertTrue(cpu.registers.isFlagCleared(.ZERO))
        
        cpu.registers.L = 0b1101_1111
        cpu.bit_5_l()
        XCTAssertTrue(cpu.registers.isFlagSet(.ZERO))
        cpu.registers.L = 0b0010_0000
        cpu.bit_5_l()
        XCTAssertTrue(cpu.registers.isFlagCleared(.ZERO))
        
        cpu.registers.HL = MMUAddresses.WORK_RAM.rawValue
        cpu.mmu[cpu.registers.HL] = 0b1101_1111
        cpu.bit_5_hlp()
        XCTAssertTrue(cpu.registers.isFlagSet(.ZERO))
        cpu.mmu[cpu.registers.HL] = 0b0010_0000
        cpu.bit_5_hlp()
        XCTAssertTrue(cpu.registers.isFlagCleared(.ZERO))
        
        cpu.registers.A = 0b1101_1111
        cpu.bit_5_a()
        XCTAssertTrue(cpu.registers.isFlagSet(.ZERO))
        cpu.registers.A = 0b0010_0000
        cpu.bit_5_a()
        XCTAssertTrue(cpu.registers.isFlagCleared(.ZERO))
        
        cpu.registers.B = 0b1011_1111
        cpu.bit_6_b()
        XCTAssertTrue(cpu.registers.isFlagSet(.ZERO))
        cpu.registers.B = 0b0100_0000
        cpu.bit_6_b()
        XCTAssertTrue(cpu.registers.isFlagCleared(.ZERO))
        
        cpu.registers.C = 0b1011_1111
        cpu.bit_6_c()
        XCTAssertTrue(cpu.registers.isFlagSet(.ZERO))
        cpu.registers.C = 0b0100_0000
        cpu.bit_6_c()
        XCTAssertTrue(cpu.registers.isFlagCleared(.ZERO))
        
        cpu.registers.D = 0b1011_1111
        cpu.bit_6_d()
        XCTAssertTrue(cpu.registers.isFlagSet(.ZERO))
        cpu.registers.D = 0b0100_0000
        cpu.bit_6_d()
        XCTAssertTrue(cpu.registers.isFlagCleared(.ZERO))
        
        cpu.registers.E = 0b1011_1111
        cpu.bit_6_e()
        XCTAssertTrue(cpu.registers.isFlagSet(.ZERO))
        cpu.registers.E = 0b0100_0000
        cpu.bit_6_e()
        XCTAssertTrue(cpu.registers.isFlagCleared(.ZERO))
        
        cpu.registers.H = 0b1011_1111
        cpu.bit_6_h()
        XCTAssertTrue(cpu.registers.isFlagSet(.ZERO))
        cpu.registers.H = 0b0100_0000
        cpu.bit_6_h()
        XCTAssertTrue(cpu.registers.isFlagCleared(.ZERO))
        
        cpu.registers.L = 0b1011_1111
        cpu.bit_6_l()
        XCTAssertTrue(cpu.registers.isFlagSet(.ZERO))
        cpu.registers.L = 0b0100_0000
        cpu.bit_6_l()
        XCTAssertTrue(cpu.registers.isFlagCleared(.ZERO))
        
        cpu.registers.HL = MMUAddresses.WORK_RAM.rawValue
        cpu.mmu[cpu.registers.HL] = 0b1011_1111
        cpu.bit_6_hlp()
        XCTAssertTrue(cpu.registers.isFlagSet(.ZERO))
        cpu.mmu[cpu.registers.HL] = 0b0100_0000
        cpu.bit_6_hlp()
        XCTAssertTrue(cpu.registers.isFlagCleared(.ZERO))
        
        cpu.registers.A = 0b1011_1111
        cpu.bit_6_a()
        XCTAssertTrue(cpu.registers.isFlagSet(.ZERO))
        cpu.registers.A = 0b0100_0000
        cpu.bit_6_a()
        XCTAssertTrue(cpu.registers.isFlagCleared(.ZERO))
        
        cpu.registers.B = 0b0111_1111
        cpu.bit_7_b()
        XCTAssertTrue(cpu.registers.isFlagSet(.ZERO))
        cpu.registers.B = 0b1000_0000
        cpu.bit_7_b()
        XCTAssertTrue(cpu.registers.isFlagCleared(.ZERO))
        
        cpu.registers.C = 0b0111_1111
        cpu.bit_7_c()
        XCTAssertTrue(cpu.registers.isFlagSet(.ZERO))
        cpu.registers.C = 0b1000_0000
        cpu.bit_7_c()
        XCTAssertTrue(cpu.registers.isFlagCleared(.ZERO))
        
        cpu.registers.D = 0b0111_1111
        cpu.bit_7_d()
        XCTAssertTrue(cpu.registers.isFlagSet(.ZERO))
        cpu.registers.D = 0b1000_0000
        cpu.bit_7_d()
        XCTAssertTrue(cpu.registers.isFlagCleared(.ZERO))
        
        cpu.registers.E = 0b0111_1111
        cpu.bit_7_e()
        XCTAssertTrue(cpu.registers.isFlagSet(.ZERO))
        cpu.registers.E = 0b1000_0000
        cpu.bit_7_e()
        XCTAssertTrue(cpu.registers.isFlagCleared(.ZERO))
        
        cpu.registers.H = 0b0111_1111
        cpu.bit_7_h()
        XCTAssertTrue(cpu.registers.isFlagSet(.ZERO))
        cpu.registers.H = 0b1000_0000
        cpu.bit_7_h()
        XCTAssertTrue(cpu.registers.isFlagCleared(.ZERO))
        
        cpu.registers.L = 0b0111_1111
        cpu.bit_7_l()
        XCTAssertTrue(cpu.registers.isFlagSet(.ZERO))
        cpu.registers.L = 0b1000_0000
        cpu.bit_7_l()
        XCTAssertTrue(cpu.registers.isFlagCleared(.ZERO))
        
        cpu.registers.HL = MMUAddresses.WORK_RAM.rawValue
        cpu.mmu[cpu.registers.HL] = 0b0111_1111
        cpu.bit_7_hlp()
        XCTAssertTrue(cpu.registers.isFlagSet(.ZERO))
        cpu.mmu[cpu.registers.HL] = 0b1000_0000
        cpu.bit_7_hlp()
        XCTAssertTrue(cpu.registers.isFlagCleared(.ZERO))
        
        cpu.registers.A = 0b0111_1111
        cpu.bit_7_a()
        XCTAssertTrue(cpu.registers.isFlagSet(.ZERO))
        cpu.registers.A = 0b1000_0000
        cpu.bit_7_a()
        XCTAssertTrue(cpu.registers.isFlagCleared(.ZERO))
    }
    
    func test_res() throws {
        let cpu:CPU = CPU(mmu: MMU())
        XCTAssertTrue(false)
    }
    
    func test_set() throws {
        let cpu:CPU = CPU(mmu: MMU())
        XCTAssertTrue(false)
    }
}
