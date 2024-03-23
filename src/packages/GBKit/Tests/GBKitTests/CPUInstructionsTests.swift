import XCTest
@testable import GBKit

final class CPUInstructionsTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func test_nop() throws {
        //0x00
        let cpu:CPU = CPU()
        let old = cpu.registers.describe()
        cpu.nop()
        let new = cpu.registers.describe()
        XCTAssertTrue(old.elementsEqual(new))
    }
    
    func test_inc() throws {
        let cpu:CPU = CPU()
        
        cpu.registers.BC = 0
        cpu.inc_bc()
        XCTAssertTrue(cpu.registers.BC == 1)
    }
    
    func test_ld() throws {
        let cpu:CPU = CPU()
        
        //0x01
        cpu.registers.BC = 8
        cpu.ld_bc_nn(val: EnhancedShort(0x16))
        XCTAssertTrue(cpu.registers.BC == 0x16)
        
        //0x11
        cpu.registers.DE = 8
        cpu.ld_de_nn(val: EnhancedShort(0x16))
        XCTAssertTrue(cpu.registers.DE == 0x16)
        
        //0x12
        cpu.registers.HL = 8
        cpu.ld_hl_nn(val: EnhancedShort(0x16))
        XCTAssertTrue(cpu.registers.HL == 0x16)
        
        //0x13
        cpu.registers.SP = 8
        cpu.ld_sp_nn(val: EnhancedShort(0x16))
        XCTAssertTrue(cpu.registers.SP == 0x16)
        
        //0x02
        cpu.registers.A = 0x6
        cpu.registers.BC = 0x8
        cpu.ld_bcp_a()
        XCTAssertTrue(cpu.mmu[0x8] == 0x6)
        
        //0x12
        cpu.registers.A = 0x6
        cpu.registers.DE = 0x8
        cpu.ld_dep_a()
        XCTAssertTrue(cpu.mmu[0x8] == 0x6)
        
        //0x22
        cpu.registers.A = 0x6
        cpu.registers.HL = 0x8
        cpu.ld_hlpi_a()
        XCTAssertTrue(cpu.mmu[0x8] == 0x6)
        XCTAssertTrue(cpu.registers.HL == 0x9)
        
        //0x32
        cpu.registers.A = 0x6
        cpu.registers.HL = 0x8
        cpu.ld_hlpd_a()
        XCTAssertTrue(cpu.mmu[0x8] == 0x6)
        XCTAssertTrue(cpu.registers.HL == 0x7)
        
        //0x08
        cpu.registers.SP = 0x6
        cpu.ld_nnp_sp(address: EnhancedShort(0x0000))
        XCTAssertTrue(cpu.mmu[0x0000] == 0x6)
        
        //0xFA
        cpu.registers.SP = 0x6
        cpu.registers.HL = 0x8
        cpu.ld_sp_hl()
        XCTAssertTrue(cpu.registers.SP == 0x8)
        
        //0x06
        cpu.registers.B = 0x4
        cpu.ld_b_n(val:0x6)
        XCTAssertTrue(cpu.registers.B == 0x6)
        
        //0x16
        cpu.registers.D = 0x4
        cpu.ld_d_n(val:0x6)
        XCTAssertTrue(cpu.registers.D == 0x6)
        
        //0x26
        cpu.registers.H = 0x4
        cpu.ld_h_n(val:0x6)
        XCTAssertTrue(cpu.registers.H == 0x6)
        
        //0x36
        cpu.registers.HL = 0x0000
        cpu.ld_hlp_n(val:0x6)
        XCTAssertTrue(cpu.mmu[0x0000] == 0x6)
        
        //0x0A
        cpu.registers.A = 0x4
        cpu.registers.BC = 0x0000
        cpu.mmu[cpu.registers.BC] = 0x22
        cpu.ld_a_bcp()
        XCTAssertTrue(cpu.registers.A == 0x22)
        
        //0x1A
        cpu.registers.A = 0x4
        cpu.registers.DE = 0x0000
        cpu.mmu[cpu.registers.DE] = 0x22
        cpu.ld_a_dep()
        XCTAssertTrue(cpu.registers.A == 0x22)
        
        //0x2A
        cpu.registers.A = 0x4
        cpu.registers.HL = 0x0000
        cpu.mmu[cpu.registers.HL] = 0x22
        cpu.ld_a_hlpi()
        XCTAssertTrue(cpu.registers.A == 0x22)
        XCTAssertTrue(cpu.registers.HL == 0x1)
        
        //0x3A
        cpu.registers.A = 0x4
        cpu.registers.HL = 0x0001
        cpu.mmu[cpu.registers.HL] = 0x22
        cpu.ld_a_hlpd()
        XCTAssertTrue(cpu.registers.A == 0x22)
        XCTAssertTrue(cpu.registers.HL == 0x0)
        
        //0x0E
        cpu.registers.C = 0x0
        cpu.ld_c_n(val: 0x6)
        XCTAssertTrue(cpu.registers.C == 0x6)
        
        //0x1E
        cpu.registers.E = 0x0
        cpu.ld_e_n(val: 0x6)
        XCTAssertTrue(cpu.registers.E == 0x6)
        
        //0x2E
        cpu.registers.L = 0x0
        cpu.ld_l_n(val: 0x6)
        XCTAssertTrue(cpu.registers.L == 0x6)
        
        //0x3E
        cpu.registers.A = 0x0
        cpu.ld_a_n(val: 0x6)
        XCTAssertTrue(cpu.registers.A == 0x6)
        
        //0x40
        cpu.registers.B = 0x4
        cpu.ld_b_b()
        XCTAssertTrue(cpu.registers.B == 0x4)
        
        //0x41
        cpu.registers.B = 0x4
        cpu.registers.C = 0x5
        cpu.ld_b_c()
        XCTAssertTrue(cpu.registers.B == 0x5)
        
        //0x42
        cpu.registers.B = 0x4
        cpu.registers.D = 0x5
        cpu.ld_b_d()
        XCTAssertTrue(cpu.registers.B == 0x5)
        
        //0x43
        cpu.registers.B = 0x4
        cpu.registers.E = 0x5
        cpu.ld_b_e()
        XCTAssertTrue(cpu.registers.B == 0x5)
        
        //0x44
        cpu.registers.B = 0x4
        cpu.registers.H = 0x5
        cpu.ld_b_h()
        XCTAssertTrue(cpu.registers.B == 0x5)
        
        //0x45
        cpu.registers.B = 0x4
        cpu.registers.L = 0x5
        cpu.ld_b_l()
        XCTAssertTrue(cpu.registers.B == 0x5)
        
        //0x46
        cpu.registers.B = 0x4
        cpu.registers.HL = 0x0000
        cpu.mmu[0x0000] = 0x5
        cpu.ld_b_hlp()
        XCTAssertTrue(cpu.registers.B == 0x5)
        
        //0x47
        cpu.registers.B = 0x4
        cpu.registers.A = 0x5
        cpu.ld_b_a()
        XCTAssertTrue(cpu.registers.B == 0x5)
        
        //0x48
        cpu.registers.C = 0x3
        cpu.registers.B = 0x4
        cpu.ld_c_b()
        XCTAssertTrue(cpu.registers.C == 0x4)

        //0x49
        cpu.registers.C = 0x5
        cpu.ld_c_c()
        XCTAssertTrue(cpu.registers.C == 0x5)

        //0x4A
        cpu.registers.C = 0x4
        cpu.registers.D = 0x5
        cpu.ld_c_d()
        XCTAssertTrue(cpu.registers.C == 0x5)

        //0x4B
        cpu.registers.C = 0x4
        cpu.registers.E = 0x5
        cpu.ld_c_e()
        XCTAssertTrue(cpu.registers.C == 0x5)

        //0x4C
        cpu.registers.C = 0x4
        cpu.registers.H = 0x5
        cpu.ld_c_h()
        XCTAssertTrue(cpu.registers.C == 0x5)

        //0x4D
        cpu.registers.C = 0x4
        cpu.registers.L = 0x5
        cpu.ld_c_l()
        XCTAssertTrue(cpu.registers.C == 0x5)

        //0x4E
        cpu.registers.C = 0x4
        cpu.registers.HL = 0x0000
        cpu.mmu[0x0000] = 0x5
        cpu.ld_c_hlp()
        XCTAssertTrue(cpu.registers.C == 0x5)

        //0x4F
        cpu.registers.C = 0x4
        cpu.registers.A = 0x5
        cpu.ld_c_a()
        XCTAssertTrue(cpu.registers.C == 0x5)
        
        //0x50
        cpu.registers.D = 0x3
        cpu.registers.B = 0x4
        cpu.ld_d_b()
        XCTAssertTrue(cpu.registers.D == 0x4)
        
        //0x51
        cpu.registers.D = 0x4
        cpu.registers.C = 0x5
        cpu.ld_d_c()
        XCTAssertTrue(cpu.registers.D == 0x5)
        
        //0x52
        cpu.registers.D = 0x5
        cpu.ld_d_d()
        XCTAssertTrue(cpu.registers.D == 0x5)
        
        //0x53
        cpu.registers.D = 0x4
        cpu.registers.E = 0x5
        cpu.ld_d_e()
        XCTAssertTrue(cpu.registers.D == 0x5)
        
        //0x54
        cpu.registers.D = 0x4
        cpu.registers.H = 0x5
        cpu.ld_d_h()
        XCTAssertTrue(cpu.registers.D == 0x5)
        
        //0x55
        cpu.registers.D = 0x4
        cpu.registers.L = 0x5
        cpu.ld_d_l()
        XCTAssertTrue(cpu.registers.D == 0x5)
        
        //0x56
        cpu.registers.D = 0x4
        cpu.registers.HL = 0x0000
        cpu.mmu[0x0000] = 0x5
        cpu.ld_d_hlp()
        XCTAssertTrue(cpu.registers.D == 0x5)
        
        //0x57
        cpu.registers.D = 0x4
        cpu.registers.A = 0x5
        cpu.ld_d_a()
        XCTAssertTrue(cpu.registers.D == 0x5)
        
        //0x58
        cpu.registers.E = 0x3
        cpu.registers.B = 0x4
        cpu.ld_e_b()
        XCTAssertTrue(cpu.registers.E == 0x4)

        //0x59
        cpu.registers.E = 0x4
        cpu.registers.C = 0x5
        cpu.ld_e_c()
        XCTAssertTrue(cpu.registers.E == 0x5)

        //0x5A
        cpu.registers.E = 0x4
        cpu.registers.D = 0x5
        cpu.ld_e_d()
        XCTAssertTrue(cpu.registers.E == 0x5)

        //0x5B
        cpu.registers.E = 0x5
        cpu.ld_e_e()
        XCTAssertTrue(cpu.registers.E == 0x5)

        //0x5C
        cpu.registers.E = 0x4
        cpu.registers.H = 0x5
        cpu.ld_e_h()
        XCTAssertTrue(cpu.registers.E == 0x5)

        //0x5D
        cpu.registers.E = 0x4
        cpu.registers.L = 0x5
        cpu.ld_e_l()
        XCTAssertTrue(cpu.registers.E == 0x5)

        //0x5E
        cpu.registers.E = 0x4
        cpu.registers.HL = 0x0000
        cpu.mmu[0x0000] = 0x5
        cpu.ld_e_hlp()
        XCTAssertTrue(cpu.registers.E == 0x5)

        //0x5F
        cpu.registers.E = 0x4
        cpu.registers.A = 0x5
        cpu.ld_e_a()
        XCTAssertTrue(cpu.registers.E == 0x5)
        
        //0x60
        cpu.registers.H = 0x3
        cpu.registers.B = 0x4
        cpu.ld_h_b()
        XCTAssertTrue(cpu.registers.H == 0x4)
        
        //0x61
        cpu.registers.H = 0x4
        cpu.registers.C = 0x6
        cpu.ld_h_c()
        XCTAssertTrue(cpu.registers.H == 0x6)
        
        //0x62
        cpu.registers.H = 0x5
        cpu.registers.D = 0x6
        cpu.ld_h_d()
        XCTAssertTrue(cpu.registers.H == 0x6)
        
        //0x63
        cpu.registers.H = 0x4
        cpu.registers.E = 0x6
        cpu.ld_h_e()
        XCTAssertTrue(cpu.registers.H == 0x6)
        
        //0x64
        cpu.registers.H = 0x6
        cpu.ld_h_h()
        XCTAssertTrue(cpu.registers.H == 0x6)
        
        //0x65
        cpu.registers.H = 0x4
        cpu.registers.L = 0x6
        cpu.ld_h_l()
        XCTAssertTrue(cpu.registers.H == 0x6)
        
        //0x66
        cpu.registers.H = 0x4
        cpu.registers.HL = 0x0000
        cpu.mmu[0x0000] = 0x6
        cpu.ld_h_hlp()
        XCTAssertTrue(cpu.registers.H == 0x6)
        
        //0x67
        cpu.registers.H = 0x4
        cpu.registers.A = 0x6
        cpu.ld_h_a()
        XCTAssertTrue(cpu.registers.H == 0x6)
        
        //0x68
        cpu.registers.L = 0x3
        cpu.registers.B = 0x4
        cpu.ld_l_b()
        XCTAssertTrue(cpu.registers.L == 0x4)

        //0x69
        cpu.registers.L = 0x4
        cpu.registers.C = 0x6
        cpu.ld_l_c()
        XCTAssertTrue(cpu.registers.L == 0x6)

        //0x6A
        cpu.registers.L = 0x4
        cpu.registers.D = 0x6
        cpu.ld_l_d()
        XCTAssertTrue(cpu.registers.L == 0x6)

        //0x6B
        cpu.registers.L = 0x4
        cpu.registers.E = 0x6
        cpu.ld_l_e()
        XCTAssertTrue(cpu.registers.L == 0x6)

        //0x6C
        cpu.registers.L = 0x4
        cpu.registers.H = 0x6
        cpu.ld_l_h()
        XCTAssertTrue(cpu.registers.L == 0x6)

        //0x6D
        cpu.registers.L = 0x6
        cpu.ld_l_l()
        XCTAssertTrue(cpu.registers.L == 0x6)

        //0x6E
        cpu.registers.L = 0x4
        cpu.registers.HL = 0x0000
        cpu.mmu[0x0000] = 0x6
        cpu.ld_l_hlp()
        XCTAssertTrue(cpu.registers.L == 0x6)

        //0x6F
        cpu.registers.L = 0x4
        cpu.registers.A = 0x6
        cpu.ld_l_a()
        XCTAssertTrue(cpu.registers.L == 0x6)
        
        //0x70
        cpu.registers.HL = 0x0000
        cpu.mmu[0x0000] = 0x6
        cpu.registers.B = 0x7
        cpu.ld_hlp_b()
        XCTAssertTrue(cpu.mmu[0x0000] == 0x7)
        
        //0x71
        cpu.registers.HL = 0x0000
        cpu.mmu[0x0000] = 0x6
        cpu.registers.C = 0x7
        cpu.ld_hlp_c()
        XCTAssertTrue(cpu.mmu[0x0000] == 0x7)
        
        //0x72
        cpu.registers.HL = 0x0000
        cpu.mmu[0x0000] = 0x6
        cpu.registers.D = 0x7
        cpu.ld_hlp_d()
        XCTAssertTrue(cpu.mmu[0x0000] == 0x7)
        
        //0x73
        cpu.registers.HL = 0x0000
        cpu.mmu[0x0000] = 0x6
        cpu.registers.E = 0x7
        cpu.ld_hlp_e()
        XCTAssertTrue(cpu.mmu[0x0000] == 0x7)
        
        //0x74
        cpu.registers.HL = 0x0000
        cpu.mmu[0x0000] = 0x6
        cpu.registers.H = 0xFF
        cpu.ld_hlp_h()
        XCTAssertTrue(cpu.mmu[0xFF00] == 0xFF)
        
        //0x75
        cpu.registers.HL = 0x0000
        cpu.mmu[0x0000] = 0x6
        cpu.registers.L = 0xFF
        cpu.ld_hlp_l()
        XCTAssertTrue(cpu.mmu[0x00FF] == 0xFF)
        
        //0x77
        cpu.registers.HL = 0x0000
        cpu.mmu[0x0000] = 0x6
        cpu.registers.A = 0x7
        cpu.ld_hlp_a()
        XCTAssertTrue(cpu.mmu[0x0000] == 0x7)
        
        //0x78
        cpu.registers.A = 0x3
        cpu.registers.B = 0x4
        cpu.ld_a_b()
        XCTAssertTrue(cpu.registers.A == 0x4)

        //0x79
        cpu.registers.A = 0x4
        cpu.registers.C = 0x6
        cpu.ld_a_c()
        XCTAssertTrue(cpu.registers.A == 0x6)

        //0x7A
        cpu.registers.A = 0x4
        cpu.registers.D = 0x6
        cpu.ld_a_d()
        XCTAssertTrue(cpu.registers.A == 0x6)

        //0x7B
        cpu.registers.A = 0x4
        cpu.registers.E = 0x6
        cpu.ld_a_e()
        XCTAssertTrue(cpu.registers.A == 0x6)

        //0x7C
        cpu.registers.A = 0x4
        cpu.registers.H = 0x6
        cpu.ld_a_h()
        XCTAssertTrue(cpu.registers.A == 0x6)

        //0x7D
        cpu.registers.A = 0x5
        cpu.registers.L = 0x6
        cpu.ld_a_l()
        XCTAssertTrue(cpu.registers.A == 0x6)

        //0x7E
        cpu.registers.A = 0x4
        cpu.registers.HL = 0x0000
        cpu.mmu[0x0000] = 0x6
        cpu.ld_a_hlp()
        XCTAssertTrue(cpu.registers.A == 0x6)

        //0x7F
        cpu.registers.A = 0x7
        cpu.ld_a_a()
        XCTAssertTrue(cpu.registers.A == 0x7)
        
        //0xE0
        cpu.mmu[0xFF08] = 0x6
        cpu.registers.A = 0xFF
        cpu.ld_ff00pn_a(val: 0x8)
        XCTAssertTrue(cpu.mmu[0xFF08] == 0xFF)
        
        //0xF0
        cpu.mmu[0xFF08] = 0x6
        cpu.registers.A = 0xFF
        cpu.ld_a_ff00pn(val: 0x8)
        XCTAssertTrue(cpu.registers.A == 0x6)
        
        //0xE2
        cpu.registers.C = 0x8
        cpu.registers.A = 0xFF
        cpu.mmu[0xFF08] = 0x1
        cpu.ld_ff00pc_a()
        XCTAssertTrue(cpu.mmu[0xFF08] == 0xFF)
        
        //0xF8 -> positive
        cpu.registers.HL = 0x22
        cpu.registers.SP = 0x08
        cpu.ld_hl_sppn(val: 0x01)
        XCTAssertTrue(cpu.registers.HL == 0x9)
        XCTAssertTrue(cpu.registers.isFlagCleared(.ZERO))
        XCTAssertTrue(cpu.registers.isFlagCleared(.NEGATIVE))
        //todo test H && C
        
        //0xF8 -> negative
        cpu.registers.HL = 0x22
        cpu.registers.SP = 0x08
        cpu.ld_hl_sppn(val: 0b1111_1111)//-1 //Two bits complement
        XCTAssertTrue(cpu.registers.HL == 0x7)
        XCTAssertTrue(cpu.registers.isFlagCleared(.ZERO))
        XCTAssertTrue(cpu.registers.isFlagCleared(.NEGATIVE))
        //todo test H && C
        
        //0xF2
        
        cpu.registers.C = 0x8
        cpu.registers.A = 0xFF
        cpu.mmu[0xFF08] = 0x1
        cpu.ld_a_ff00pc()
        XCTAssertTrue(cpu.registers.A == 0x1)
        
        //0xF9
        cpu.registers.SP = 0xEE
        cpu.registers.HL = 0xFF
        cpu.ld_sp_hl()
        XCTAssertTrue(cpu.registers.SP == 0xFF)
        
        //0xEA
        cpu.registers.A = 0x66
        cpu.ld_nnp_a(address: EnhancedShort(0x00FF))
        XCTAssertTrue(cpu.mmu[0x00FF] == 0x66)
        
        //0xFA
        cpu.registers.A = 0xFF
        cpu.mmu[0x00FF] = 0xDD
        cpu.ld_a_nnp(address: EnhancedShort(0x00FF) )
        XCTAssertTrue(cpu.registers.A == 0xDD)
    }

}
