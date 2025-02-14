import XCTest
@testable import GBKit

final class CPUInstructionsTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func test_indexation() throws {
        let cpu:CPU = CPU(mmu: MMU())
        
        let inst = cpu.asStandardInstructions()
        for i in 0...255 {
            if(inst[i].name != "panic"){
                XCTAssertTrue(Byte(i) == inst[i].opCode)
            }
        }
    }
    
    func test_nop() throws {
        //0x00
        let cpu:CPU = CPU(mmu: MMU())
        let old = cpu.registers.describe()
        cpu.nop()
        let new = cpu.registers.describe()
        XCTAssertTrue(old.elementsEqual(new))
    }
    
    func test_halt() throws {
        let cpu:CPU = CPU(mmu: MMU())
        cpu.state = CPUState.RUNNING
        cpu.halt()
        XCTAssertTrue(cpu.state == CPUState.HALTED)
    }
    
    func test_stop() throws {
        XCTAssertTrue(false)
    }
    
    func test_dec() throws {
        let cpu:CPU = CPU(mmu: MMU())
        cpu.registers.F = 0b0000_0000
        
        //0x0B
        cpu.registers.BC = 1
        cpu.dec_bc()
        XCTAssertTrue(cpu.registers.BC == 0)
        
        //0x01B
        cpu.registers.DE = 1
        cpu.dec_de()
        XCTAssertTrue(cpu.registers.DE == 0)
        
        //0x2B
        cpu.registers.HL = 1
        cpu.dec_hl()
        XCTAssertTrue(cpu.registers.HL == 0)
        
        //0x3B
        cpu.registers.SP = 1
        cpu.dec_sp()
        XCTAssertTrue(cpu.registers.SP == 0)
        
        //0x05
        cpu.registers.B = 1
        cpu.dec_b()
        XCTAssertTrue(cpu.registers.B == 0)
        XCTAssertTrue(cpu.registers.isFlagSet(.ZERO))
        XCTAssertTrue(cpu.registers.isFlagSet(.NEGATIVE))
        
        //0x15
        cpu.registers.D = 1
        cpu.dec_d()
        XCTAssertTrue(cpu.registers.D == 0)
        XCTAssertTrue(cpu.registers.isFlagSet(.ZERO))
        XCTAssertTrue(cpu.registers.isFlagSet(.NEGATIVE))
        
        //0x25
        cpu.registers.H = 1
        cpu.dec_h()
        XCTAssertTrue(cpu.registers.H == 0)
        XCTAssertTrue(cpu.registers.isFlagSet(.ZERO))
        XCTAssertTrue(cpu.registers.isFlagSet(.NEGATIVE))
        
        //0x35
        cpu.registers.HL = MMUAddresses.WORK_RAM.rawValue
        cpu.mmu[cpu.registers.HL] = 1
        cpu.dec_hlp()
        XCTAssertTrue(cpu.mmu[cpu.registers.HL] == 0)
        XCTAssertTrue(cpu.registers.isFlagSet(.ZERO))
        XCTAssertTrue(cpu.registers.isFlagSet(.NEGATIVE))
        
        //0x0D
        cpu.registers.C = 1
        cpu.dec_c()
        XCTAssertTrue(cpu.registers.C == 0)
        XCTAssertTrue(cpu.registers.isFlagSet(.ZERO))
        XCTAssertTrue(cpu.registers.isFlagSet(.NEGATIVE))
        
        //0x1D
        cpu.registers.E = 1
        cpu.dec_e()
        XCTAssertTrue(cpu.registers.E == 0)
        XCTAssertTrue(cpu.registers.isFlagSet(.ZERO))
        XCTAssertTrue(cpu.registers.isFlagSet(.NEGATIVE))
        
        //0x2D
        cpu.registers.L = 1
        cpu.dec_l()
        XCTAssertTrue(cpu.registers.L == 0)
        XCTAssertTrue(cpu.registers.isFlagSet(.ZERO))
        XCTAssertTrue(cpu.registers.isFlagSet(.NEGATIVE))
        
        //0x3D
        cpu.registers.A = 1
        cpu.dec_a()
        XCTAssertTrue(cpu.registers.A == 0)
        XCTAssertTrue(cpu.registers.isFlagSet(.ZERO))
        XCTAssertTrue(cpu.registers.isFlagSet(.NEGATIVE))
    }
    
    func test_flags() throws {
        let cpu:CPU = CPU(mmu: MMU())
        cpu.registers.F = 0b1111_0000
        cpu.scf()
        XCTAssertTrue(cpu.registers.isFlagSet(.CARRY))
        XCTAssertTrue(cpu.registers.isFlagCleared(.NEGATIVE))
        XCTAssertTrue(cpu.registers.isFlagCleared(.HALF_CARRY))
        XCTAssertTrue(cpu.registers.isFlagSet(.ZERO))//not affected, so it should stay active
        
        cpu.registers.F = 0b1111_0000
        //True -> False
        cpu.ccf()
        XCTAssertTrue(cpu.registers.isFlagCleared(.CARRY))
        XCTAssertTrue(cpu.registers.isFlagCleared(.NEGATIVE))
        XCTAssertTrue(cpu.registers.isFlagCleared(.HALF_CARRY))
        XCTAssertTrue(cpu.registers.isFlagSet(.ZERO))//not affected, so it should stay active
        //False -> True
        cpu.ccf()
        XCTAssertTrue(cpu.registers.isFlagSet(.CARRY))
        XCTAssertTrue(cpu.registers.isFlagCleared(.NEGATIVE))
        XCTAssertTrue(cpu.registers.isFlagCleared(.HALF_CARRY))
        XCTAssertTrue(cpu.registers.isFlagSet(.ZERO))//not affected, so it should stay active
    }
    
    func test_inc() throws {
        let cpu:CPU = CPU(mmu: MMU())
        
        //0x03
        cpu.registers.BC = 0
        cpu.inc_bc()
        XCTAssertTrue(cpu.registers.BC == 1)
        
        //0x013
        cpu.registers.DE = 0
        cpu.inc_de()
        XCTAssertTrue(cpu.registers.DE == 1)
        
        //0x23
        cpu.registers.HL = 0
        cpu.inc_hl()
        XCTAssertTrue(cpu.registers.HL == 1)
        
        //0x33
        cpu.registers.SP = 0
        cpu.inc_sp()
        XCTAssertTrue(cpu.registers.SP == 1)
        
        //0x04
        cpu.registers.B = 0
        cpu.inc_b()
        XCTAssertTrue(cpu.registers.B == 1)
        
        //0x014
        cpu.registers.D = 0
        cpu.inc_d()
        XCTAssertTrue(cpu.registers.D == 1)
        
        //0x24
        cpu.registers.H = 0
        cpu.inc_h()
        XCTAssertTrue(cpu.registers.H == 1)
        
        //0x34
        cpu.registers.HL = MMUAddresses.WORK_RAM.rawValue
        cpu.mmu[cpu.registers.HL] = 0x22
        cpu.inc_hlp()
        XCTAssertTrue(cpu.mmu[cpu.registers.HL] == 0x23)
        XCTAssertTrue(cpu.registers.HL == MMUAddresses.WORK_RAM.rawValue)
        
        //0x0C
        cpu.registers.C = 0
        cpu.inc_c()
        XCTAssertTrue(cpu.registers.C == 1)
        
        //0x01C
        cpu.registers.E = 0
        cpu.inc_e()
        XCTAssertTrue(cpu.registers.E == 1)
        
        //0x2C
        cpu.registers.L = 0
        cpu.inc_l()
        XCTAssertTrue(cpu.registers.L == 1)
        
        //0x3C
        cpu.registers.A = 0
        cpu.inc_a()
        XCTAssertTrue(cpu.registers.A == 1)
        
        cpu.registers.A = Byte.max
        cpu.inc_a()
        XCTAssertTrue(cpu.registers.A == 0)
        XCTAssertTrue(cpu.registers.isFlagSet(.ZERO))
        
        cpu.registers.A = 0b0000_1111
        cpu.inc_a()
        XCTAssertTrue(cpu.registers.A == 0b0001_0000)
        XCTAssertTrue(cpu.registers.isFlagSet(.HALF_CARRY))
    }
    
    func test_ld() throws {
        let cpu:CPU = CPU(mmu: MMU())
        
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
        cpu.registers.BC = MMUAddresses.WORK_RAM.rawValue
        cpu.ld_bcp_a()
        XCTAssertTrue(cpu.mmu[MMUAddresses.WORK_RAM.rawValue] == 0x6)
        
        //0x12
        cpu.registers.A = 0x6
        cpu.registers.DE = MMUAddresses.WORK_RAM.rawValue
        cpu.ld_dep_a()
        XCTAssertTrue(cpu.mmu[MMUAddresses.WORK_RAM.rawValue] == 0x6)
        
        //0x22
        cpu.registers.A = 0x6
        cpu.registers.HL = MMUAddresses.WORK_RAM.rawValue
        cpu.ld_hlpi_a()
        XCTAssertTrue(cpu.mmu[MMUAddresses.WORK_RAM.rawValue] == 0x6)
        XCTAssertTrue(cpu.registers.HL == MMUAddresses.WORK_RAM.rawValue+1)
        
        //0x32
        cpu.registers.A = 0x6
        cpu.registers.HL = MMUAddresses.WORK_RAM.rawValue
        cpu.ld_hlpd_a()
        XCTAssertTrue(cpu.mmu[MMUAddresses.WORK_RAM.rawValue] == 0x6)
        XCTAssertTrue(cpu.registers.HL == MMUAddresses.WORK_RAM.rawValue-1)
        
        //0x08
        cpu.registers.SP = 0x6
        cpu.mmu[MMUAddresses.WORK_RAM.rawValue] = 0x01
        cpu.ld_nnp_sp(address: EnhancedShort(MMUAddresses.WORK_RAM.rawValue))
        XCTAssertTrue(cpu.mmu[MMUAddresses.WORK_RAM.rawValue] == 0x6)
        
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
        cpu.registers.HL = MMUAddresses.WORK_RAM.rawValue
        cpu.ld_hlp_n(val:0x6)
        XCTAssertTrue(cpu.mmu[MMUAddresses.WORK_RAM.rawValue] == 0x6)
        
        //0x0A
        cpu.registers.A = 0x4
        cpu.registers.BC = MMUAddresses.WORK_RAM.rawValue
        cpu.mmu[cpu.registers.BC] = 0x22
        cpu.ld_a_bcp()
        XCTAssertTrue(cpu.registers.A == 0x22)
        
        //0x1A
        cpu.registers.A = 0x4
        cpu.registers.DE = MMUAddresses.WORK_RAM.rawValue
        cpu.mmu[cpu.registers.DE] = 0x22
        cpu.ld_a_dep()
        XCTAssertTrue(cpu.registers.A == 0x22)
        
        //0x2A
        cpu.registers.A = 0x4
        cpu.registers.HL = MMUAddresses.WORK_RAM.rawValue
        cpu.mmu[cpu.registers.HL] = 0x22
        cpu.ld_a_hlpi()
        XCTAssertTrue(cpu.registers.A == 0x22)
        XCTAssertTrue(cpu.registers.HL == MMUAddresses.WORK_RAM.rawValue+1)
        
        //0x3A
        cpu.registers.A = 0x4
        cpu.registers.HL = MMUAddresses.WORK_RAM.rawValue
        cpu.mmu[cpu.registers.HL] = 0x22
        cpu.ld_a_hlpd()
        XCTAssertTrue(cpu.registers.A == 0x22)
        XCTAssertTrue(cpu.registers.HL == MMUAddresses.WORK_RAM.rawValue-1)
        
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
        cpu.registers.HL = MMUAddresses.WORK_RAM.rawValue
        cpu.mmu[MMUAddresses.WORK_RAM.rawValue] = 0x5
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
        cpu.registers.HL = MMUAddresses.WORK_RAM.rawValue
        cpu.mmu[MMUAddresses.WORK_RAM.rawValue] = 0x5
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
        cpu.registers.HL = MMUAddresses.WORK_RAM.rawValue
        cpu.mmu[MMUAddresses.WORK_RAM.rawValue] = 0x5
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
        cpu.registers.HL = MMUAddresses.WORK_RAM.rawValue
        cpu.mmu[MMUAddresses.WORK_RAM.rawValue] = 0x5
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
        cpu.registers.HL = MMUAddresses.WORK_RAM.rawValue
        cpu.mmu[MMUAddresses.WORK_RAM.rawValue] = 0x6
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
        cpu.registers.HL = MMUAddresses.WORK_RAM.rawValue
        cpu.mmu[MMUAddresses.WORK_RAM.rawValue] = 0x6
        cpu.ld_l_hlp()
        XCTAssertTrue(cpu.registers.L == 0x6)

        //0x6F
        cpu.registers.L = 0x4
        cpu.registers.A = 0x6
        cpu.ld_l_a()
        XCTAssertTrue(cpu.registers.L == 0x6)
        
        //0x70
        cpu.registers.HL = MMUAddresses.WORK_RAM.rawValue
        cpu.mmu[MMUAddresses.WORK_RAM.rawValue] = 0x6
        cpu.registers.B = 0x7
        cpu.ld_hlp_b()
        XCTAssertTrue(cpu.mmu[MMUAddresses.WORK_RAM.rawValue] == 0x7)
        
        //0x71
        cpu.registers.HL = MMUAddresses.WORK_RAM.rawValue
        cpu.mmu[MMUAddresses.WORK_RAM.rawValue] = 0x6
        cpu.registers.C = 0x7
        cpu.ld_hlp_c()
        XCTAssertTrue(cpu.mmu[MMUAddresses.WORK_RAM.rawValue] == 0x7)
        
        //0x72
        cpu.registers.HL = MMUAddresses.WORK_RAM.rawValue
        cpu.mmu[MMUAddresses.WORK_RAM.rawValue] = 0x6
        cpu.registers.D = 0x7
        cpu.ld_hlp_d()
        XCTAssertTrue(cpu.mmu[MMUAddresses.WORK_RAM.rawValue] == 0x7)
        
        //0x73
        cpu.registers.HL = MMUAddresses.WORK_RAM.rawValue
        cpu.mmu[MMUAddresses.WORK_RAM.rawValue] = 0x6
        cpu.registers.E = 0x7
        cpu.ld_hlp_e()
        XCTAssertTrue(cpu.mmu[MMUAddresses.WORK_RAM.rawValue] == 0x7)
        
        //0x74
        cpu.registers.HL = 0x0000
        cpu.mmu[0x0000] = 0x6
        cpu.registers.H = 0xC0
        cpu.registers.L = 0x00
        cpu.ld_hlp_h()
        XCTAssertTrue(cpu.mmu[0xC000] == 0xC0)
        
        //0x75
        cpu.registers.HL = MMUAddresses.WORK_RAM.rawValue
        cpu.mmu[MMUAddresses.WORK_RAM.rawValue] = 0x6
        cpu.registers.L = 0xFF
        cpu.ld_hlp_l()
        XCTAssertTrue(cpu.mmu[MMUAddresses.WORK_RAM.rawValue+0xFF] == 0xFF)
        
        //0x77
        cpu.registers.HL = MMUAddresses.WORK_RAM.rawValue
        cpu.mmu[MMUAddresses.WORK_RAM.rawValue] = 0x6
        cpu.registers.A = 0x7
        cpu.ld_hlp_a()
        XCTAssertTrue(cpu.mmu[MMUAddresses.WORK_RAM.rawValue] == 0x7)
        
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
        cpu.registers.HL = MMUAddresses.WORK_RAM.rawValue
        cpu.mmu[MMUAddresses.WORK_RAM.rawValue] = 0x6
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
        cpu.ld_hl_sppi8(val: 0x01)
        XCTAssertTrue(cpu.registers.HL == 0x9)
        XCTAssertTrue(cpu.registers.isFlagCleared(.ZERO))
        XCTAssertTrue(cpu.registers.isFlagCleared(.NEGATIVE))
        //todo test H && C
        
        //0xF8 -> negative
        cpu.registers.HL = 0x22
        cpu.registers.SP = 0x08
        cpu.ld_hl_sppi8(val: 0b1111_1111)//-1 //Two bits complement
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
        cpu.ld_nnp_a(address: EnhancedShort(MMUAddresses.WORK_RAM.rawValue))
        XCTAssertTrue(cpu.mmu[MMUAddresses.WORK_RAM.rawValue] == 0x66)
        
        //0xFA
        cpu.registers.A = 0xFF
        cpu.mmu[MMUAddresses.WORK_RAM.rawValue] = 0xDD
        cpu.ld_a_nnp(address: EnhancedShort(MMUAddresses.WORK_RAM.rawValue) )
        XCTAssertTrue(cpu.registers.A == 0xDD)
    }

    func test_add() throws {
        let cpu:CPU = CPU(mmu: MMU())
        
        //0x80
        cpu.registers.A = 0b0000_1111
        cpu.registers.B = 0b0000_0001
        cpu.add_a_b()
        XCTAssertTrue(cpu.registers.A == 0b0001_0000)
        XCTAssertTrue(cpu.registers.isFlagSet(.HALF_CARRY))
        XCTAssertTrue(cpu.registers.isFlagCleared(.NEGATIVE))
        cpu.registers.A = 0x01
        cpu.registers.B = 0xFF
        cpu.add_a_b()
        XCTAssertTrue(cpu.registers.A == 0x00)
        XCTAssertTrue(cpu.registers.isFlagSet(.CARRY))
        XCTAssertTrue(cpu.registers.isFlagSet(.ZERO))
        
        //0x81
        cpu.registers.A = 0b0000_1111
        cpu.registers.C = 0b0000_0001
        cpu.add_a_c()
        XCTAssertTrue(cpu.registers.A == 0b0001_0000)
        XCTAssertTrue(cpu.registers.isFlagSet(.HALF_CARRY))
        XCTAssertTrue(cpu.registers.isFlagCleared(.NEGATIVE))
        cpu.registers.A = 0x01
        cpu.registers.C = 0xFF
        cpu.add_a_c()
        XCTAssertTrue(cpu.registers.A == 0x00)
        XCTAssertTrue(cpu.registers.isFlagSet(.CARRY))
        XCTAssertTrue(cpu.registers.isFlagSet(.ZERO))
        
        //0x82
        cpu.registers.A = 0b0000_1111
        cpu.registers.D = 0b0000_0001
        cpu.add_a_d()
        XCTAssertTrue(cpu.registers.A == 0b0001_0000)
        XCTAssertTrue(cpu.registers.isFlagSet(.HALF_CARRY))
        XCTAssertTrue(cpu.registers.isFlagCleared(.NEGATIVE))
        cpu.registers.A = 0x01
        cpu.registers.D = 0xFF
        cpu.add_a_d()
        XCTAssertTrue(cpu.registers.A == 0x00)
        XCTAssertTrue(cpu.registers.isFlagSet(.CARRY))
        XCTAssertTrue(cpu.registers.isFlagSet(.ZERO))
        
        //0x83
        cpu.registers.A = 0b0000_1111
        cpu.registers.E = 0b0000_0001
        cpu.add_a_e()
        XCTAssertTrue(cpu.registers.A == 0b0001_0000)
        XCTAssertTrue(cpu.registers.isFlagSet(.HALF_CARRY))
        XCTAssertTrue(cpu.registers.isFlagCleared(.NEGATIVE))
        cpu.registers.A = 0x01
        cpu.registers.E = 0xFF
        cpu.add_a_e()
        XCTAssertTrue(cpu.registers.A == 0x00)
        XCTAssertTrue(cpu.registers.isFlagSet(.CARRY))
        XCTAssertTrue(cpu.registers.isFlagSet(.ZERO))
        
        //0x84
        cpu.registers.A = 0b0000_1111
        cpu.registers.H = 0b0000_0001
        cpu.add_a_h()
        XCTAssertTrue(cpu.registers.A == 0b0001_0000)
        XCTAssertTrue(cpu.registers.isFlagSet(.HALF_CARRY))
        XCTAssertTrue(cpu.registers.isFlagCleared(.NEGATIVE))
        cpu.registers.A = 0x01
        cpu.registers.H = 0xFF
        cpu.add_a_h()
        XCTAssertTrue(cpu.registers.A == 0x00)
        XCTAssertTrue(cpu.registers.isFlagSet(.CARRY))
        XCTAssertTrue(cpu.registers.isFlagSet(.ZERO))
        
        //0x85
        cpu.registers.A = 0b0000_1111
        cpu.registers.L = 0b0000_0001
        cpu.add_a_l()
        XCTAssertTrue(cpu.registers.A == 0b0001_0000)
        XCTAssertTrue(cpu.registers.isFlagSet(.HALF_CARRY))
        XCTAssertTrue(cpu.registers.isFlagCleared(.NEGATIVE))
        cpu.registers.A = 0x01
        cpu.registers.L = 0xFF
        cpu.add_a_l()
        XCTAssertTrue(cpu.registers.A == 0x00)
        XCTAssertTrue(cpu.registers.isFlagSet(.CARRY))
        XCTAssertTrue(cpu.registers.isFlagSet(.ZERO))
        
        //0x86
        cpu.registers.HL = 0xFFFF
        cpu.registers.A = 0b0000_1111
        cpu.mmu[0xFFFF] = 0b0000_0001
        cpu.add_a_hlp()
        XCTAssertTrue(cpu.registers.A == 0b0001_0000)
        XCTAssertTrue(cpu.registers.isFlagSet(.HALF_CARRY))
        XCTAssertTrue(cpu.registers.isFlagCleared(.NEGATIVE))
        cpu.registers.A = 0x01
        cpu.mmu[0xFFFF] = 0xFF
        cpu.add_a_hlp()
        XCTAssertTrue(cpu.registers.A == 0x00)
        XCTAssertTrue(cpu.registers.isFlagSet(.CARRY))
        XCTAssertTrue(cpu.registers.isFlagSet(.ZERO))
        
        //0xC6
        cpu.registers.A = 0b0000_1111
        cpu.add_a_n(val: 0b0000_0001)
        XCTAssertTrue(cpu.registers.A == 0b0001_0000)
        XCTAssertTrue(cpu.registers.isFlagSet(.HALF_CARRY))
        XCTAssertTrue(cpu.registers.isFlagCleared(.NEGATIVE))
        cpu.registers.A = 0x01
        cpu.add_a_n(val: 0xFF)
        XCTAssertTrue(cpu.registers.A == 0x00)
        XCTAssertTrue(cpu.registers.isFlagSet(.CARRY))
        XCTAssertTrue(cpu.registers.isFlagSet(.ZERO))
        
        //0xE8 -> positive
        cpu.registers.SP = 0x08
        cpu.add_sp_i8(val: 0x01)
        XCTAssertTrue(cpu.registers.SP == 0x9)
        XCTAssertTrue(cpu.registers.isFlagCleared(.ZERO))
        XCTAssertTrue(cpu.registers.isFlagCleared(.NEGATIVE))
        //todo test H && C
        
        //0xE8 -> negative
        cpu.registers.SP = 0x08
        cpu.add_sp_i8(val: 0b1111_1111)//-1 //Two bits complement
        XCTAssertTrue(cpu.registers.SP == 0x7)
        XCTAssertTrue(cpu.registers.isFlagCleared(.ZERO))
        XCTAssertTrue(cpu.registers.isFlagCleared(.NEGATIVE))
        //todo test H && C
        
        //0x09
        cpu.registers.HL = 0x0000
        cpu.registers.BC = 0x0FFF
        cpu.add_hl_bc()
        XCTAssertTrue(cpu.registers.HL == 0x0FFF)
        XCTAssertTrue(cpu.registers.isFlagCleared(.HALF_CARRY))
        XCTAssertTrue(cpu.registers.isFlagCleared(.CARRY))
        cpu.registers.HL = 0x0001
        cpu.registers.BC = 0xFFFF
        cpu.add_hl_bc()
        XCTAssertTrue(cpu.registers.HL == 0x0000)
        XCTAssertTrue(cpu.registers.isFlagSet(.HALF_CARRY))
        XCTAssertTrue(cpu.registers.isFlagSet(.CARRY))
        
        //0x19
        cpu.registers.HL = 0x0000
        cpu.registers.DE = 0x0FFF
        cpu.add_hl_de()
        XCTAssertTrue(cpu.registers.HL == 0x0FFF)
        XCTAssertTrue(cpu.registers.isFlagCleared(.HALF_CARRY))
        XCTAssertTrue(cpu.registers.isFlagCleared(.CARRY))
        cpu.registers.HL = 0x0001
        cpu.registers.DE = 0xFFFF
        cpu.add_hl_de()
        XCTAssertTrue(cpu.registers.HL == 0x0000)
        XCTAssertTrue(cpu.registers.isFlagSet(.HALF_CARRY))
        XCTAssertTrue(cpu.registers.isFlagSet(.CARRY))
        
        //0x29
        cpu.registers.HL = 0x0000
        cpu.add_hl_hl()
        XCTAssertTrue(cpu.registers.HL == 0x0000)
        XCTAssertTrue(cpu.registers.isFlagCleared(.HALF_CARRY))
        XCTAssertTrue(cpu.registers.isFlagCleared(.CARRY))
        cpu.registers.HL = 0x8000
        cpu.add_hl_hl()
        XCTAssertTrue(cpu.registers.HL == 0x0000)
        XCTAssertTrue(cpu.registers.isFlagSet(.CARRY))
        cpu.registers.HL = 0x7FFF
        cpu.add_hl_hl()
        XCTAssertTrue(cpu.registers.HL == 0xFFFE)
        XCTAssertTrue(cpu.registers.isFlagSet(.HALF_CARRY))
        
        //0x39
        cpu.registers.HL = 0x0000
        cpu.registers.SP = 0x0FFF
        cpu.add_hl_sp()
        XCTAssertTrue(cpu.registers.HL == 0x0FFF)
        XCTAssertTrue(cpu.registers.isFlagCleared(.HALF_CARRY))
        XCTAssertTrue(cpu.registers.isFlagCleared(.CARRY))
        cpu.registers.HL = 0x0001
        cpu.registers.SP = 0xFFFF
        cpu.add_hl_sp()
        XCTAssertTrue(cpu.registers.HL == 0x0000)
        XCTAssertTrue(cpu.registers.isFlagSet(.HALF_CARRY))
        XCTAssertTrue(cpu.registers.isFlagSet(.CARRY))
        
        XCTAssertTrue(cpu.registers.isFlagCleared(.NEGATIVE))
        XCTAssertTrue(cpu.registers.isFlagCleared(.ZERO))
    }
    
    func test_adc() throws {
        let cpu:CPU = CPU(mmu: MMU())
        
        //0x80
        cpu.registers.raiseFlag(.CARRY)
        cpu.registers.A = 0b0000_1111
        cpu.registers.B = 0b0000_0001
        cpu.adc_a_b()
        XCTAssertTrue(cpu.registers.A == 0b0001_0001)
        XCTAssertTrue(cpu.registers.isFlagSet(.HALF_CARRY))
        XCTAssertTrue(cpu.registers.isFlagCleared(.NEGATIVE))
        cpu.registers.raiseFlag(.CARRY)
        cpu.registers.A = 0x01
        cpu.registers.B = 0xFF
        cpu.adc_a_b()
        XCTAssertTrue(cpu.registers.A == 0x01)
        XCTAssertTrue(cpu.registers.isFlagSet(.CARRY))
        XCTAssertTrue(cpu.registers.isFlagCleared(.ZERO))
        
        //0x81
        cpu.registers.raiseFlag(.CARRY)
        cpu.registers.A = 0b0000_1111
        cpu.registers.C = 0b0000_0001
        cpu.adc_a_c()
        XCTAssertTrue(cpu.registers.A == 0b0001_0001)
        XCTAssertTrue(cpu.registers.isFlagSet(.HALF_CARRY))
        XCTAssertTrue(cpu.registers.isFlagCleared(.NEGATIVE))
        cpu.registers.raiseFlag(.CARRY)
        cpu.registers.A = 0x01
        cpu.registers.C = 0xFF
        cpu.adc_a_c()
        XCTAssertTrue(cpu.registers.A == 0x01)
        XCTAssertTrue(cpu.registers.isFlagSet(.CARRY))
        XCTAssertTrue(cpu.registers.isFlagCleared(.ZERO))
        
        //0x82
        cpu.registers.raiseFlag(.CARRY)
        cpu.registers.A = 0b0000_1111
        cpu.registers.D = 0b0000_0001
        cpu.adc_a_d()
        XCTAssertTrue(cpu.registers.A == 0b0001_0001)
        XCTAssertTrue(cpu.registers.isFlagSet(.HALF_CARRY))
        XCTAssertTrue(cpu.registers.isFlagCleared(.NEGATIVE))
        cpu.registers.raiseFlag(.CARRY)
        cpu.registers.A = 0x01
        cpu.registers.D = 0xFF
        cpu.adc_a_d()
        XCTAssertTrue(cpu.registers.A == 0x01)
        XCTAssertTrue(cpu.registers.isFlagSet(.CARRY))
        XCTAssertTrue(cpu.registers.isFlagCleared(.ZERO))
        
        //0x83
        cpu.registers.raiseFlag(.CARRY)
        cpu.registers.A = 0b0000_1111
        cpu.registers.E = 0b0000_0001
        cpu.adc_a_e()
        XCTAssertTrue(cpu.registers.A == 0b0001_0001)
        XCTAssertTrue(cpu.registers.isFlagSet(.HALF_CARRY))
        XCTAssertTrue(cpu.registers.isFlagCleared(.NEGATIVE))
        cpu.registers.raiseFlag(.CARRY)
        cpu.registers.A = 0x01
        cpu.registers.E = 0xFF
        cpu.adc_a_e()
        XCTAssertTrue(cpu.registers.A == 0x01)
        XCTAssertTrue(cpu.registers.isFlagSet(.CARRY))
        XCTAssertTrue(cpu.registers.isFlagCleared(.ZERO))
        
        //0x84
        cpu.registers.raiseFlag(.CARRY)
        cpu.registers.A = 0b0000_1111
        cpu.registers.H = 0b0000_0001
        cpu.adc_a_h()
        XCTAssertTrue(cpu.registers.A == 0b0001_0001)
        XCTAssertTrue(cpu.registers.isFlagSet(.HALF_CARRY))
        XCTAssertTrue(cpu.registers.isFlagCleared(.NEGATIVE))
        cpu.registers.raiseFlag(.CARRY)
        cpu.registers.A = 0x01
        cpu.registers.H = 0xFF
        cpu.adc_a_h()
        XCTAssertTrue(cpu.registers.A == 0x01)
        XCTAssertTrue(cpu.registers.isFlagSet(.CARRY))
        XCTAssertTrue(cpu.registers.isFlagCleared(.ZERO))
        
        //0x85
        cpu.registers.raiseFlag(.CARRY)
        cpu.registers.A = 0b0000_1111
        cpu.registers.L = 0b0000_0001
        cpu.adc_a_l()
        XCTAssertTrue(cpu.registers.A == 0b0001_0001)
        XCTAssertTrue(cpu.registers.isFlagSet(.HALF_CARRY))
        XCTAssertTrue(cpu.registers.isFlagCleared(.NEGATIVE))
        cpu.registers.raiseFlag(.CARRY)
        cpu.registers.A = 0x01
        cpu.registers.L = 0xFF
        cpu.adc_a_l()
        XCTAssertTrue(cpu.registers.A == 0x01)
        XCTAssertTrue(cpu.registers.isFlagSet(.CARRY))
        XCTAssertTrue(cpu.registers.isFlagCleared(.ZERO))
        
        //0x86
        cpu.registers.raiseFlag(.CARRY)
        cpu.registers.HL = 0xFFFF
        cpu.registers.A = 0b0000_1111
        cpu.mmu[0xFFFF] = 0b0000_0001
        cpu.adc_a_hlp()
        XCTAssertTrue(cpu.registers.A == 0b0001_0001)
        XCTAssertTrue(cpu.registers.isFlagSet(.HALF_CARRY))
        XCTAssertTrue(cpu.registers.isFlagCleared(.NEGATIVE))
        cpu.registers.raiseFlag(.CARRY)
        cpu.registers.A = 0x01
        cpu.mmu[0xFFFF] = 0xFF
        cpu.adc_a_hlp()
        XCTAssertTrue(cpu.registers.A == 0x01)
        XCTAssertTrue(cpu.registers.isFlagSet(.CARRY))
        XCTAssertTrue(cpu.registers.isFlagCleared(.ZERO))
        
        //0xC6
        cpu.registers.raiseFlag(.CARRY)
        cpu.registers.A = 0b0000_1111
        cpu.adc_a_n(val: 0b0000_0001)
        XCTAssertTrue(cpu.registers.A == 0b0001_0001)
        XCTAssertTrue(cpu.registers.isFlagSet(.HALF_CARRY))
        XCTAssertTrue(cpu.registers.isFlagCleared(.NEGATIVE))
        cpu.registers.raiseFlag(.CARRY)
        cpu.registers.A = 0x01
        cpu.adc_a_n(val: 0xFF)
        XCTAssertTrue(cpu.registers.A == 0x01)
        XCTAssertTrue(cpu.registers.isFlagSet(.CARRY))
        XCTAssertTrue(cpu.registers.isFlagCleared(.ZERO))
    }
    
    func test_sub() throws {
        let cpu:CPU = CPU(mmu: MMU())
        
        cpu.registers.A = 0b0001_0000
        cpu.registers.B = 0b0000_0001
        cpu.sub_a_b()
        XCTAssertTrue(cpu.registers.A == 0b0000_1111)
        XCTAssertTrue(cpu.registers.isFlagSet(.HALF_CARRY))
        XCTAssertTrue(cpu.registers.isFlagSet(.NEGATIVE))//raise by sub
        cpu.registers.A = 0x00
        cpu.registers.B = 0x01
        cpu.sub_a_b()
        XCTAssertTrue(cpu.registers.A == 0xFF)
        XCTAssertTrue(cpu.registers.isFlagSet(.CARRY))
        XCTAssertTrue(cpu.registers.isFlagCleared(.ZERO))
        cpu.registers.A = 0x01
        cpu.registers.B = 0x01
        cpu.sub_a_b()
        XCTAssertTrue(cpu.registers.A == 0x00)
        XCTAssertTrue(cpu.registers.isFlagSet(.ZERO))
        
        cpu.registers.A = 0b0001_0000
        cpu.registers.C = 0b0000_0001
        cpu.sub_a_c()
        XCTAssertTrue(cpu.registers.A == 0b0000_1111)
        XCTAssertTrue(cpu.registers.isFlagSet(.HALF_CARRY))
        XCTAssertTrue(cpu.registers.isFlagSet(.NEGATIVE))//raise by sub
        cpu.registers.A = 0x00
        cpu.registers.C = 0x01
        cpu.sub_a_c()
        XCTAssertTrue(cpu.registers.A == 0xFF)
        XCTAssertTrue(cpu.registers.isFlagSet(.CARRY))
        XCTAssertTrue(cpu.registers.isFlagCleared(.ZERO))
        cpu.registers.A = 0x01
        cpu.registers.C = 0x01
        cpu.sub_a_c()
        XCTAssertTrue(cpu.registers.A == 0x00)
        XCTAssertTrue(cpu.registers.isFlagSet(.ZERO))
        
        cpu.registers.A = 0b0001_0000
        cpu.registers.D = 0b0000_0001
        cpu.sub_a_d()
        XCTAssertTrue(cpu.registers.A == 0b0000_1111)
        XCTAssertTrue(cpu.registers.isFlagSet(.HALF_CARRY))
        XCTAssertTrue(cpu.registers.isFlagSet(.NEGATIVE))//raise by sub
        cpu.registers.A = 0x00
        cpu.registers.D = 0x01
        cpu.sub_a_d()
        XCTAssertTrue(cpu.registers.A == 0xFF)
        XCTAssertTrue(cpu.registers.isFlagSet(.CARRY))
        XCTAssertTrue(cpu.registers.isFlagCleared(.ZERO))
        cpu.registers.A = 0x01
        cpu.registers.D = 0x01
        cpu.sub_a_d()
        XCTAssertTrue(cpu.registers.A == 0x00)
        XCTAssertTrue(cpu.registers.isFlagSet(.ZERO))
        
        cpu.registers.A = 0b0001_0000
        cpu.registers.E = 0b0000_0001
        cpu.sub_a_e()
        XCTAssertTrue(cpu.registers.A == 0b0000_1111)
        XCTAssertTrue(cpu.registers.isFlagSet(.HALF_CARRY))
        XCTAssertTrue(cpu.registers.isFlagSet(.NEGATIVE))//raise by sub
        cpu.registers.A = 0x00
        cpu.registers.E = 0x01
        cpu.sub_a_e()
        XCTAssertTrue(cpu.registers.A == 0xFF)
        XCTAssertTrue(cpu.registers.isFlagSet(.CARRY))
        XCTAssertTrue(cpu.registers.isFlagCleared(.ZERO))
        cpu.registers.A = 0x01
        cpu.registers.E = 0x01
        cpu.sub_a_e()
        XCTAssertTrue(cpu.registers.A == 0x00)
        XCTAssertTrue(cpu.registers.isFlagSet(.ZERO))
        
        cpu.registers.A = 0b0001_0000
        cpu.registers.H = 0b0000_0001
        cpu.sub_a_h()
        XCTAssertTrue(cpu.registers.A == 0b0000_1111)
        XCTAssertTrue(cpu.registers.isFlagSet(.HALF_CARRY))
        XCTAssertTrue(cpu.registers.isFlagSet(.NEGATIVE))//raise by sub
        cpu.registers.A = 0x00
        cpu.registers.H = 0x01
        cpu.sub_a_h()
        XCTAssertTrue(cpu.registers.A == 0xFF)
        XCTAssertTrue(cpu.registers.isFlagSet(.CARRY))
        XCTAssertTrue(cpu.registers.isFlagCleared(.ZERO))
        cpu.registers.A = 0x01
        cpu.registers.H = 0x01
        cpu.sub_a_h()
        XCTAssertTrue(cpu.registers.A == 0x00)
        XCTAssertTrue(cpu.registers.isFlagSet(.ZERO))
        
        cpu.registers.A = 0b0001_0000
        cpu.registers.L = 0b0000_0001
        cpu.sub_a_l()
        XCTAssertTrue(cpu.registers.A == 0b0000_1111)
        XCTAssertTrue(cpu.registers.isFlagSet(.HALF_CARRY))
        XCTAssertTrue(cpu.registers.isFlagSet(.NEGATIVE))//raise by sub
        cpu.registers.A = 0x00
        cpu.registers.L = 0x01
        cpu.sub_a_l()
        XCTAssertTrue(cpu.registers.A == 0xFF)
        XCTAssertTrue(cpu.registers.isFlagSet(.CARRY))
        XCTAssertTrue(cpu.registers.isFlagCleared(.ZERO))
        cpu.registers.A = 0x01
        cpu.registers.L = 0x01
        cpu.sub_a_l()
        XCTAssertTrue(cpu.registers.A == 0x00)
        XCTAssertTrue(cpu.registers.isFlagSet(.ZERO))
        
        cpu.registers.A = 0b0001_0000
        cpu.sub_a_n(val: 0b0000_0001)
        XCTAssertTrue(cpu.registers.A == 0b0000_1111)
        XCTAssertTrue(cpu.registers.isFlagSet(.HALF_CARRY))
        XCTAssertTrue(cpu.registers.isFlagSet(.NEGATIVE))//raise by sub
        cpu.registers.A = 0x00
        cpu.sub_a_n(val:0x01)
        XCTAssertTrue(cpu.registers.A == 0xFF)
        XCTAssertTrue(cpu.registers.isFlagSet(.CARRY))
        XCTAssertTrue(cpu.registers.isFlagCleared(.ZERO))
        cpu.registers.A = 0x01
        cpu.sub_a_n(val:0x01)
        XCTAssertTrue(cpu.registers.A == 0x00)
        XCTAssertTrue(cpu.registers.isFlagSet(.ZERO))
        
        cpu.registers.A = 0b0001_0000
        cpu.registers.HL = MMUAddresses.WORK_RAM.rawValue
        cpu.mmu[cpu.registers.HL] = 0b0000_0001
        cpu.sub_a_hlp()
        XCTAssertTrue(cpu.registers.A == 0b0000_1111)
        XCTAssertTrue(cpu.registers.isFlagSet(.HALF_CARRY))
        XCTAssertTrue(cpu.registers.isFlagSet(.NEGATIVE))//raise by sub
        cpu.registers.A = 0x00
        cpu.mmu[cpu.registers.HL] = 0b0000_0001
        cpu.sub_a_hlp()
        XCTAssertTrue(cpu.registers.A == 0xFF)
        XCTAssertTrue(cpu.registers.isFlagSet(.CARRY))
        XCTAssertTrue(cpu.registers.isFlagCleared(.ZERO))
        cpu.registers.A = 0x01
        cpu.mmu[cpu.registers.HL] = 0b0000_0001
        cpu.sub_a_hlp()
        XCTAssertTrue(cpu.registers.A == 0x00)
        XCTAssertTrue(cpu.registers.isFlagSet(.ZERO))
    }
    
    func test_sbc() throws {
        let cpu:CPU = CPU(mmu: MMU())
        
        cpu.registers.A = 0b0001_0000
        cpu.registers.B = 0b0000_0000
        cpu.registers.raiseFlag(.CARRY)
        cpu.sbc_a_b()
        XCTAssertTrue(cpu.registers.A == 0b0000_1111)
        XCTAssertTrue(cpu.registers.isFlagSet(.HALF_CARRY))
        XCTAssertTrue(cpu.registers.isFlagSet(.NEGATIVE))//raise by sub
        cpu.registers.A = 0x00
        cpu.registers.B = 0x00
        cpu.registers.raiseFlag(.CARRY)
        cpu.sbc_a_b()
        XCTAssertTrue(cpu.registers.A == 0xFF)
        XCTAssertTrue(cpu.registers.isFlagSet(.CARRY))
        XCTAssertTrue(cpu.registers.isFlagCleared(.ZERO))
        cpu.registers.A = 0x01
        cpu.registers.B = 0x00
        cpu.registers.raiseFlag(.CARRY)
        cpu.sbc_a_b()
        XCTAssertTrue(cpu.registers.A == 0x00)
        XCTAssertTrue(cpu.registers.isFlagSet(.ZERO))
        
        cpu.registers.A = 0b0001_0000
        cpu.registers.C = 0b0000_0000
        cpu.registers.raiseFlag(.CARRY)
        cpu.sbc_a_c()
        XCTAssertTrue(cpu.registers.A == 0b0000_1111)
        XCTAssertTrue(cpu.registers.isFlagSet(.HALF_CARRY))
        XCTAssertTrue(cpu.registers.isFlagSet(.NEGATIVE))//raise by sub
        cpu.registers.A = 0x00
        cpu.registers.C = 0x00
        cpu.registers.raiseFlag(.CARRY)
        cpu.sbc_a_c()
        XCTAssertTrue(cpu.registers.A == 0xFF)
        XCTAssertTrue(cpu.registers.isFlagSet(.CARRY))
        XCTAssertTrue(cpu.registers.isFlagCleared(.ZERO))
        cpu.registers.A = 0x01
        cpu.registers.C = 0x00
        cpu.registers.raiseFlag(.CARRY)
        cpu.sbc_a_c()
        XCTAssertTrue(cpu.registers.A == 0x00)
        XCTAssertTrue(cpu.registers.isFlagSet(.ZERO))
        
        cpu.registers.A = 0b0001_0000
        cpu.registers.D = 0b0000_0000
        cpu.registers.raiseFlag(.CARRY)
        cpu.sbc_a_d()
        XCTAssertTrue(cpu.registers.A == 0b0000_1111)
        XCTAssertTrue(cpu.registers.isFlagSet(.HALF_CARRY))
        XCTAssertTrue(cpu.registers.isFlagSet(.NEGATIVE))//raise by sub
        cpu.registers.A = 0x00
        cpu.registers.D = 0x00
        cpu.registers.raiseFlag(.CARRY)
        cpu.sbc_a_d()
        XCTAssertTrue(cpu.registers.A == 0xFF)
        XCTAssertTrue(cpu.registers.isFlagSet(.CARRY))
        XCTAssertTrue(cpu.registers.isFlagCleared(.ZERO))
        cpu.registers.A = 0x01
        cpu.registers.D = 0x00
        cpu.registers.raiseFlag(.CARRY)
        cpu.sbc_a_d()
        XCTAssertTrue(cpu.registers.A == 0x00)
        XCTAssertTrue(cpu.registers.isFlagSet(.ZERO))
        
        cpu.registers.A = 0b0001_0000
        cpu.registers.E = 0b0000_0000
        cpu.registers.raiseFlag(.CARRY)
        cpu.sbc_a_e()
        XCTAssertTrue(cpu.registers.A == 0b0000_1111)
        XCTAssertTrue(cpu.registers.isFlagSet(.HALF_CARRY))
        XCTAssertTrue(cpu.registers.isFlagSet(.NEGATIVE))//raise by sub
        cpu.registers.A = 0x00
        cpu.registers.E = 0x00
        cpu.registers.raiseFlag(.CARRY)
        cpu.sbc_a_e()
        XCTAssertTrue(cpu.registers.A == 0xFF)
        XCTAssertTrue(cpu.registers.isFlagSet(.CARRY))
        XCTAssertTrue(cpu.registers.isFlagCleared(.ZERO))
        cpu.registers.A = 0x01
        cpu.registers.E = 0x00
        cpu.registers.raiseFlag(.CARRY)
        cpu.sbc_a_e()
        XCTAssertTrue(cpu.registers.A == 0x00)
        XCTAssertTrue(cpu.registers.isFlagSet(.ZERO))
        
        cpu.registers.A = 0b0001_0000
        cpu.registers.H = 0b0000_0000
        cpu.registers.raiseFlag(.CARRY)
        cpu.sbc_a_h()
        XCTAssertTrue(cpu.registers.A == 0b0000_1111)
        XCTAssertTrue(cpu.registers.isFlagSet(.HALF_CARRY))
        XCTAssertTrue(cpu.registers.isFlagSet(.NEGATIVE))//raise by sub
        cpu.registers.A = 0x00
        cpu.registers.H = 0x00
        cpu.registers.raiseFlag(.CARRY)
        cpu.sbc_a_h()
        XCTAssertTrue(cpu.registers.A == 0xFF)
        XCTAssertTrue(cpu.registers.isFlagSet(.CARRY))
        XCTAssertTrue(cpu.registers.isFlagCleared(.ZERO))
        cpu.registers.A = 0x01
        cpu.registers.H = 0x00
        cpu.registers.raiseFlag(.CARRY)
        cpu.sbc_a_h()
        XCTAssertTrue(cpu.registers.A == 0x00)
        XCTAssertTrue(cpu.registers.isFlagSet(.ZERO))
        
        cpu.registers.A = 0b0001_0000
        cpu.registers.L = 0b0000_0000
        cpu.registers.raiseFlag(.CARRY)
        cpu.sbc_a_l()
        XCTAssertTrue(cpu.registers.A == 0b0000_1111)
        XCTAssertTrue(cpu.registers.isFlagSet(.HALF_CARRY))
        XCTAssertTrue(cpu.registers.isFlagSet(.NEGATIVE))//raise by sub
        cpu.registers.A = 0x00
        cpu.registers.L = 0x00
        cpu.registers.raiseFlag(.CARRY)
        cpu.sbc_a_l()
        XCTAssertTrue(cpu.registers.A == 0xFF)
        XCTAssertTrue(cpu.registers.isFlagSet(.CARRY))
        XCTAssertTrue(cpu.registers.isFlagCleared(.ZERO))
        cpu.registers.A = 0x01
        cpu.registers.L = 0x00
        cpu.registers.raiseFlag(.CARRY)
        cpu.sbc_a_l()
        XCTAssertTrue(cpu.registers.A == 0x00)
        XCTAssertTrue(cpu.registers.isFlagSet(.ZERO))
        
        cpu.registers.A = 0b0001_0000
        cpu.registers.raiseFlag(.CARRY)
        cpu.sbc_a_n(val: 0b0000_0000)
        XCTAssertTrue(cpu.registers.A == 0b0000_1111)
        XCTAssertTrue(cpu.registers.isFlagSet(.HALF_CARRY))
        XCTAssertTrue(cpu.registers.isFlagSet(.NEGATIVE))//raise by sub
        cpu.registers.A = 0x00
        cpu.registers.raiseFlag(.CARRY)
        cpu.sbc_a_n(val:0x00)
        XCTAssertTrue(cpu.registers.A == 0xFF)
        XCTAssertTrue(cpu.registers.isFlagSet(.CARRY))
        XCTAssertTrue(cpu.registers.isFlagCleared(.ZERO))
        cpu.registers.A = 0x01
        cpu.registers.raiseFlag(.CARRY)
        cpu.sbc_a_n(val:0x00)
        XCTAssertTrue(cpu.registers.A == 0x00)
        XCTAssertTrue(cpu.registers.isFlagSet(.ZERO))
        
        cpu.registers.A = 0b0001_0000
        cpu.registers.HL = MMUAddresses.WORK_RAM.rawValue
        cpu.mmu[cpu.registers.HL] = 0b0000_0000
        cpu.registers.raiseFlag(.CARRY)
        cpu.sbc_a_hlp()
        XCTAssertTrue(cpu.registers.A == 0b0000_1111)
        XCTAssertTrue(cpu.registers.isFlagSet(.HALF_CARRY))
        XCTAssertTrue(cpu.registers.isFlagSet(.NEGATIVE))//raise by sub
        cpu.registers.A = 0x00
        cpu.mmu[cpu.registers.HL] = 0b0000_0000
        cpu.registers.raiseFlag(.CARRY)
        cpu.sbc_a_hlp()
        XCTAssertTrue(cpu.registers.A == 0xFF)
        XCTAssertTrue(cpu.registers.isFlagSet(.CARRY))
        XCTAssertTrue(cpu.registers.isFlagCleared(.ZERO))
        cpu.registers.A = 0x01
        cpu.mmu[cpu.registers.HL] = 0b0000_0000
        cpu.registers.raiseFlag(.CARRY)
        cpu.sbc_a_hlp()
        XCTAssertTrue(cpu.registers.A == 0x00)
        XCTAssertTrue(cpu.registers.isFlagSet(.ZERO))
    }
    
    func test_and() throws {
        let cpu:CPU = CPU(mmu: MMU())
        
        //0xA0
        cpu.registers.A = 0b0000_0001
        cpu.registers.B = 0b0000_0001
        cpu.and_a_b()
        XCTAssertTrue(cpu.registers.isFlagCleared(.ZERO))
        cpu.registers.A = 0b0000_0000
        cpu.registers.B = 0b0000_0001
        cpu.and_a_b()
        XCTAssertTrue(cpu.registers.isFlagSet(.ZERO))
        XCTAssertTrue(cpu.registers.isFlagCleared(.NEGATIVE))
        XCTAssertTrue(cpu.registers.isFlagSet(.HALF_CARRY))
        XCTAssertTrue(cpu.registers.isFlagCleared(.CARRY))
        
        //0xA1
        cpu.registers.A = 0b0000_0001
        cpu.registers.C = 0b0000_0001
        cpu.and_a_c()
        XCTAssertTrue(cpu.registers.isFlagCleared(.ZERO))
        cpu.registers.A = 0b0000_0000
        cpu.registers.C = 0b0000_0001
        cpu.and_a_c()
        XCTAssertTrue(cpu.registers.isFlagSet(.ZERO))
        XCTAssertTrue(cpu.registers.isFlagCleared(.NEGATIVE))
        XCTAssertTrue(cpu.registers.isFlagSet(.HALF_CARRY))
        XCTAssertTrue(cpu.registers.isFlagCleared(.CARRY))
        
        //0xA2
        cpu.registers.A = 0b0000_0001
        cpu.registers.D = 0b0000_0001
        cpu.and_a_d()
        XCTAssertTrue(cpu.registers.isFlagCleared(.ZERO))
        cpu.registers.A = 0b0000_0000
        cpu.registers.C = 0b0000_0001
        cpu.and_a_d()
        XCTAssertTrue(cpu.registers.isFlagSet(.ZERO))
        XCTAssertTrue(cpu.registers.isFlagCleared(.NEGATIVE))
        XCTAssertTrue(cpu.registers.isFlagSet(.HALF_CARRY))
        XCTAssertTrue(cpu.registers.isFlagCleared(.CARRY))
        
        //0xA3
        cpu.registers.A = 0b0000_0001
        cpu.registers.E = 0b0000_0001
        cpu.and_a_e()
        XCTAssertTrue(cpu.registers.isFlagCleared(.ZERO))
        cpu.registers.A = 0b0000_0000
        cpu.registers.E = 0b0000_0001
        cpu.and_a_e()
        XCTAssertTrue(cpu.registers.isFlagSet(.ZERO))
        XCTAssertTrue(cpu.registers.isFlagCleared(.NEGATIVE))
        XCTAssertTrue(cpu.registers.isFlagSet(.HALF_CARRY))
        XCTAssertTrue(cpu.registers.isFlagCleared(.CARRY))
        
        //0xA4
        cpu.registers.A = 0b0000_0001
        cpu.registers.H = 0b0000_0001
        cpu.and_a_h()
        XCTAssertTrue(cpu.registers.isFlagCleared(.ZERO))
        cpu.registers.A = 0b0000_0000
        cpu.registers.H = 0b0000_0001
        cpu.and_a_h()
        XCTAssertTrue(cpu.registers.isFlagSet(.ZERO))
        XCTAssertTrue(cpu.registers.isFlagCleared(.NEGATIVE))
        XCTAssertTrue(cpu.registers.isFlagSet(.HALF_CARRY))
        XCTAssertTrue(cpu.registers.isFlagCleared(.CARRY))
        
        //0xA5
        cpu.registers.A = 0b0000_0001
        cpu.registers.L = 0b0000_0001
        cpu.and_a_l()
        XCTAssertTrue(cpu.registers.isFlagCleared(.ZERO))
        cpu.registers.A = 0b0000_0000
        cpu.registers.L = 0b0000_0001
        cpu.and_a_l()
        XCTAssertTrue(cpu.registers.isFlagSet(.ZERO))
        XCTAssertTrue(cpu.registers.isFlagCleared(.NEGATIVE))
        XCTAssertTrue(cpu.registers.isFlagSet(.HALF_CARRY))
        XCTAssertTrue(cpu.registers.isFlagCleared(.CARRY))
        
        //0xA6
        cpu.registers.A = 0b0000_0001
        cpu.registers.HL = MMUAddresses.WORK_RAM.rawValue
        cpu.mmu[MMUAddresses.WORK_RAM.rawValue] = 0b0000_0001
        cpu.and_a_hlp()
        XCTAssertTrue(cpu.registers.isFlagCleared(.ZERO))
        cpu.registers.A = 0b0000_0000
        cpu.mmu[MMUAddresses.WORK_RAM.rawValue] = 0b0000_0001
        cpu.and_a_hlp()
        XCTAssertTrue(cpu.registers.isFlagSet(.ZERO))
        XCTAssertTrue(cpu.registers.isFlagCleared(.NEGATIVE))
        XCTAssertTrue(cpu.registers.isFlagSet(.HALF_CARRY))
        XCTAssertTrue(cpu.registers.isFlagCleared(.CARRY))
        
        //0xA7
        cpu.registers.A = 0b0000_0001
        cpu.and_a_a()
        XCTAssertTrue(cpu.registers.isFlagCleared(.ZERO))
        XCTAssertTrue(cpu.registers.isFlagCleared(.NEGATIVE))
        XCTAssertTrue(cpu.registers.isFlagSet(.HALF_CARRY))
        XCTAssertTrue(cpu.registers.isFlagCleared(.CARRY))
        
        //0xE6
        cpu.registers.A = 0b0000_0001
        cpu.and_a_n(val:0b0000_0001)
        XCTAssertTrue(cpu.registers.isFlagCleared(.ZERO))
        cpu.registers.A = 0b0000_0000
        cpu.and_a_n(val:0b0000_0001)
        XCTAssertTrue(cpu.registers.isFlagSet(.ZERO))
        XCTAssertTrue(cpu.registers.isFlagCleared(.NEGATIVE))
        XCTAssertTrue(cpu.registers.isFlagSet(.HALF_CARRY))
        XCTAssertTrue(cpu.registers.isFlagCleared(.CARRY))
    }
    
    func test_xor() throws {
        let cpu:CPU = CPU(mmu: MMU())
        
        //0xA8
        cpu.registers.A = 0b0000_1111
        cpu.registers.B = 0b1111_0000
        cpu.xor_a_b()
        XCTAssertTrue(cpu.registers.A == 0b1111_1111)
        XCTAssertTrue(cpu.registers.isFlagCleared(.ZERO))
        cpu.registers.A = 0b0000_0000
        cpu.registers.B = 0b0000_0000
        cpu.xor_a_b()
        XCTAssertTrue(cpu.registers.A == 0b0000_0000)
        XCTAssertTrue(cpu.registers.isFlagSet(.ZERO))
    
        //0xA9
        cpu.registers.A = 0b0000_1111
        cpu.registers.C = 0b1111_0000
        cpu.xor_a_c()
        XCTAssertTrue(cpu.registers.A == 0b1111_1111)
        XCTAssertTrue(cpu.registers.isFlagCleared(.ZERO))
        cpu.registers.A = 0b0000_0000
        cpu.registers.C = 0b0000_0000
        cpu.xor_a_c()
        XCTAssertTrue(cpu.registers.A == 0b0000_0000)
        XCTAssertTrue(cpu.registers.isFlagSet(.ZERO))
        
        //0xAA
        cpu.registers.A = 0b0000_1111
        cpu.registers.D = 0b1111_0000
        cpu.xor_a_d()
        XCTAssertTrue(cpu.registers.A == 0b1111_1111)
        XCTAssertTrue(cpu.registers.isFlagCleared(.ZERO))
        cpu.registers.A = 0b0000_0000
        cpu.registers.D = 0b0000_0000
        cpu.xor_a_d()
        XCTAssertTrue(cpu.registers.A == 0b0000_0000)
        XCTAssertTrue(cpu.registers.isFlagSet(.ZERO))
        
        //0xAB
        cpu.registers.A = 0b0000_1111
        cpu.registers.E = 0b1111_0000
        cpu.xor_a_e()
        XCTAssertTrue(cpu.registers.A == 0b1111_1111)
        XCTAssertTrue(cpu.registers.isFlagCleared(.ZERO))
        cpu.registers.A = 0b0000_0000
        cpu.registers.E = 0b0000_0000
        cpu.xor_a_e()
        XCTAssertTrue(cpu.registers.A == 0b0000_0000)
        XCTAssertTrue(cpu.registers.isFlagSet(.ZERO))
        
        //0xAC
        cpu.registers.A = 0b0000_1111
        cpu.registers.H = 0b1111_0000
        cpu.xor_a_h()
        XCTAssertTrue(cpu.registers.A == 0b1111_1111)
        XCTAssertTrue(cpu.registers.isFlagCleared(.ZERO))
        cpu.registers.A = 0b0000_0000
        cpu.registers.H = 0b0000_0000
        cpu.xor_a_h()
        XCTAssertTrue(cpu.registers.A == 0b0000_0000)
        XCTAssertTrue(cpu.registers.isFlagSet(.ZERO))
        
        //0xAD
        cpu.registers.A = 0b0000_1111
        cpu.registers.L = 0b1111_0000
        cpu.xor_a_l()
        XCTAssertTrue(cpu.registers.A == 0b1111_1111)
        XCTAssertTrue(cpu.registers.isFlagCleared(.ZERO))
        cpu.registers.A = 0b0000_0000
        cpu.registers.L = 0b0000_0000
        cpu.xor_a_l()
        XCTAssertTrue(cpu.registers.A == 0b0000_0000)
        XCTAssertTrue(cpu.registers.isFlagSet(.ZERO))
        
        //0xAE
        cpu.registers.A = 0b0000_1111
        cpu.registers.HL = MMUAddresses.WORK_RAM.rawValue
        cpu.mmu[MMUAddresses.WORK_RAM.rawValue] = 0b1111_0000
        cpu.xor_a_hlp()
        XCTAssertTrue(cpu.registers.A == 0b1111_1111)
        XCTAssertTrue(cpu.registers.isFlagCleared(.ZERO))
        cpu.registers.A = 0b0000_0000
        cpu.registers.HL = MMUAddresses.WORK_RAM.rawValue
        cpu.mmu[MMUAddresses.WORK_RAM.rawValue] = 0b0000_0000
        cpu.xor_a_hlp()
        XCTAssertTrue(cpu.registers.A == 0b0000_0000)
        XCTAssertTrue(cpu.registers.isFlagSet(.ZERO))
        
        //0xAF
        cpu.registers.A = 0b0000_1111
        cpu.xor_a_a()
        XCTAssertTrue(cpu.registers.A == 0b0000_0000)
        XCTAssertTrue(cpu.registers.isFlagSet(.ZERO))
        
        //0xEE
        cpu.registers.A = 0b0000_1111
        cpu.xor_a_n(val: 0b1111_0000)
        XCTAssertTrue(cpu.registers.A == 0b1111_1111)
        XCTAssertTrue(cpu.registers.isFlagCleared(.ZERO))
        cpu.registers.A = 0b0000_0000
        cpu.xor_a_n(val: 0b0000_0000)
        XCTAssertTrue(cpu.registers.A == 0b0000_0000)
        XCTAssertTrue(cpu.registers.isFlagSet(.ZERO))
    }
    
    func test_cp() throws {
        let cpu:CPU = CPU(mmu: MMU())
        
        cpu.registers.A = 0
        cpu.registers.B = 1
        cpu.cp_a_b()
        XCTAssertTrue(cpu.registers.isFlagCleared(.ZERO))
        XCTAssertTrue(cpu.registers.isFlagSet(.NEGATIVE))
        XCTAssertTrue(cpu.registers.isFlagSet(.CARRY))
        XCTAssertTrue(cpu.registers.isFlagSet(.HALF_CARRY))
        
        cpu.registers.A = 0
        cpu.registers.C = 1
        cpu.cp_a_c()
        XCTAssertTrue(cpu.registers.isFlagCleared(.ZERO))
        XCTAssertTrue(cpu.registers.isFlagSet(.NEGATIVE))
        XCTAssertTrue(cpu.registers.isFlagSet(.CARRY))
        XCTAssertTrue(cpu.registers.isFlagSet(.HALF_CARRY))
        
        cpu.registers.A = 0
        cpu.registers.D = 1
        cpu.cp_a_d()
        XCTAssertTrue(cpu.registers.isFlagCleared(.ZERO))
        XCTAssertTrue(cpu.registers.isFlagSet(.NEGATIVE))
        XCTAssertTrue(cpu.registers.isFlagSet(.CARRY))
        XCTAssertTrue(cpu.registers.isFlagSet(.HALF_CARRY))
        
        cpu.registers.A = 0
        cpu.registers.E = 1
        cpu.cp_a_e()
        XCTAssertTrue(cpu.registers.isFlagCleared(.ZERO))
        XCTAssertTrue(cpu.registers.isFlagSet(.NEGATIVE))
        XCTAssertTrue(cpu.registers.isFlagSet(.CARRY))
        XCTAssertTrue(cpu.registers.isFlagSet(.HALF_CARRY))
        
        cpu.registers.A = 0
        cpu.registers.H = 1
        cpu.cp_a_h()
        XCTAssertTrue(cpu.registers.isFlagCleared(.ZERO))
        XCTAssertTrue(cpu.registers.isFlagSet(.NEGATIVE))
        XCTAssertTrue(cpu.registers.isFlagSet(.CARRY))
        XCTAssertTrue(cpu.registers.isFlagSet(.HALF_CARRY))
        
        cpu.registers.A = 0
        cpu.registers.L = 1
        cpu.cp_a_l()
        XCTAssertTrue(cpu.registers.isFlagCleared(.ZERO))
        XCTAssertTrue(cpu.registers.isFlagSet(.NEGATIVE))
        XCTAssertTrue(cpu.registers.isFlagSet(.CARRY))
        XCTAssertTrue(cpu.registers.isFlagSet(.HALF_CARRY))
        
        cpu.registers.A = 0
        cpu.cp_a_n(val: 1)
        XCTAssertTrue(cpu.registers.isFlagCleared(.ZERO))
        XCTAssertTrue(cpu.registers.isFlagSet(.NEGATIVE))
        XCTAssertTrue(cpu.registers.isFlagSet(.CARRY))
        XCTAssertTrue(cpu.registers.isFlagSet(.HALF_CARRY))
        
        cpu.registers.A = 0
        cpu.registers.HL = MMUAddresses.WORK_RAM.rawValue
        cpu.mmu[cpu.registers.HL] = 1
        cpu.cp_a_hlp()
        XCTAssertTrue(cpu.registers.isFlagCleared(.ZERO))
        XCTAssertTrue(cpu.registers.isFlagSet(.NEGATIVE))
        XCTAssertTrue(cpu.registers.isFlagSet(.CARRY))
        XCTAssertTrue(cpu.registers.isFlagSet(.HALF_CARRY))
    }
    
    func test_or() throws {
        let cpu:CPU = CPU(mmu: MMU())
        
        //0xB0
        cpu.registers.A = 0b0000_1111
        cpu.registers.B = 0b1111_0000
        cpu.or_a_b()
        XCTAssertTrue(cpu.registers.A == 0b1111_1111)
        XCTAssertTrue(cpu.registers.isFlagCleared(.ZERO))
        cpu.registers.A = 0b0000_0000
        cpu.registers.B = 0b0000_0000
        cpu.or_a_b()
        XCTAssertTrue(cpu.registers.A == 0b0000_0000)
        XCTAssertTrue(cpu.registers.isFlagSet(.ZERO))
        
        //0xB1
        cpu.registers.A = 0b0000_1111
        cpu.registers.C = 0b1111_0000
        cpu.or_a_c()
        XCTAssertTrue(cpu.registers.A == 0b1111_1111)
        XCTAssertTrue(cpu.registers.isFlagCleared(.ZERO))
        cpu.registers.A = 0b0000_0000
        cpu.registers.C = 0b0000_0000
        cpu.or_a_c()
        XCTAssertTrue(cpu.registers.A == 0b0000_0000)
        XCTAssertTrue(cpu.registers.isFlagSet(.ZERO))
        
        //0xB2
        cpu.registers.A = 0b0000_1111
        cpu.registers.D = 0b1111_0000
        cpu.or_a_d()
        XCTAssertTrue(cpu.registers.A == 0b1111_1111)
        XCTAssertTrue(cpu.registers.isFlagCleared(.ZERO))
        cpu.registers.A = 0b0000_0000
        cpu.registers.D = 0b0000_0000
        cpu.or_a_d()
        XCTAssertTrue(cpu.registers.A == 0b0000_0000)
        XCTAssertTrue(cpu.registers.isFlagSet(.ZERO))
        
        //0xB3
        cpu.registers.A = 0b0000_1111
        cpu.registers.E = 0b1111_0000
        cpu.or_a_e()
        XCTAssertTrue(cpu.registers.A == 0b1111_1111)
        XCTAssertTrue(cpu.registers.isFlagCleared(.ZERO))
        cpu.registers.A = 0b0000_0000
        cpu.registers.E = 0b0000_0000
        cpu.or_a_e()
        XCTAssertTrue(cpu.registers.A == 0b0000_0000)
        XCTAssertTrue(cpu.registers.isFlagSet(.ZERO))
        
        //0xB4
        cpu.registers.A = 0b0000_1111
        cpu.registers.H = 0b1111_0000
        cpu.or_a_h()
        XCTAssertTrue(cpu.registers.A == 0b1111_1111)
        XCTAssertTrue(cpu.registers.isFlagCleared(.ZERO))
        cpu.registers.A = 0b0000_0000
        cpu.registers.H = 0b0000_0000
        cpu.or_a_h()
        XCTAssertTrue(cpu.registers.A == 0b0000_0000)
        XCTAssertTrue(cpu.registers.isFlagSet(.ZERO))
        
        //0xB5
        cpu.registers.A = 0b0000_1111
        cpu.registers.L = 0b1111_0000
        cpu.or_a_l()
        XCTAssertTrue(cpu.registers.A == 0b1111_1111)
        XCTAssertTrue(cpu.registers.isFlagCleared(.ZERO))
        cpu.registers.A = 0b0000_0000
        cpu.registers.L = 0b0000_0000
        cpu.or_a_l()
        XCTAssertTrue(cpu.registers.A == 0b0000_0000)
        XCTAssertTrue(cpu.registers.isFlagSet(.ZERO))
        
        //0xB6
        cpu.registers.A = 0b0000_1111
        cpu.registers.HL = MMUAddresses.WORK_RAM.rawValue
        cpu.mmu[MMUAddresses.WORK_RAM.rawValue] = 0b1111_0000
        cpu.or_a_hlp()
        XCTAssertTrue(cpu.registers.A == 0b1111_1111)
        XCTAssertTrue(cpu.registers.isFlagCleared(.ZERO))
        cpu.registers.A = 0b0000_0000
        cpu.registers.HL = MMUAddresses.WORK_RAM.rawValue
        cpu.mmu[MMUAddresses.WORK_RAM.rawValue] = 0b0000_0000
        cpu.or_a_hlp()
        XCTAssertTrue(cpu.registers.A == 0b0000_0000)
        XCTAssertTrue(cpu.registers.isFlagSet(.ZERO))
        
        //0xB7
        cpu.registers.A = 0b0000_1111
        cpu.or_a_a()
        XCTAssertTrue(cpu.registers.A == 0b0000_1111)
        XCTAssertTrue(cpu.registers.isFlagCleared(.ZERO))
        cpu.registers.A = 0b0000_0000
        cpu.or_a_a()
        XCTAssertTrue(cpu.registers.A == 0b0000_0000)
        XCTAssertTrue(cpu.registers.isFlagSet(.ZERO))
        
        //0xF6
        cpu.registers.A = 0b0000_1111
        cpu.or_a_n(val: 0b1111_0000)
        XCTAssertTrue(cpu.registers.A == 0b1111_1111)
        XCTAssertTrue(cpu.registers.isFlagCleared(.ZERO))
        cpu.registers.A = 0b0000_0000
        cpu.or_a_n(val: 0b0000_0000)
        XCTAssertTrue(cpu.registers.A == 0b0000_0000)
        XCTAssertTrue(cpu.registers.isFlagSet(.ZERO))
    }
    
    func test_jp() throws {
        let cpu:CPU = CPU(mmu: MMU())
        
        //0xC2
        cpu.registers.PC = 0x0000
        cpu.registers.raiseFlag(.ZERO)
        cpu.jp_nz_nn(address: EnhancedShort(0x1000))
        XCTAssertTrue(cpu.registers.PC == 0x0000)
        cpu.registers.PC = 0x0000
        cpu.registers.clearFlag(.ZERO)
        cpu.jp_nz_nn(address: EnhancedShort(0x1000))
        XCTAssertTrue(cpu.registers.PC == 0x1000)
        
        //0xD2
        cpu.registers.PC = 0x0000
        cpu.registers.raiseFlag(.CARRY)
        cpu.jp_nc_nn(address: EnhancedShort(0x1000))
        XCTAssertTrue(cpu.registers.PC == 0x0000)
        cpu.registers.PC = 0x0000
        cpu.registers.clearFlag(.CARRY)
        cpu.jp_nc_nn(address: EnhancedShort(0x1000))
        XCTAssertTrue(cpu.registers.PC == 0x1000)
        
        //0xC3
        cpu.registers.PC = 0x0000
        cpu.jp_nn(address: EnhancedShort(0x1000))
        XCTAssertTrue(cpu.registers.PC == 0x1000)
        
        //0xE9
        cpu.registers.PC = 0x0000
        cpu.registers.HL = 0x1000
        cpu.jp_hl()
        XCTAssertTrue(cpu.registers.PC == 0x1000)
        
        //0xCA
        cpu.registers.PC = 0x0000
        cpu.registers.clearFlag(.ZERO)
        cpu.jp_z_nn(address: EnhancedShort(0x1000))
        XCTAssertTrue(cpu.registers.PC == 0x0000)
        cpu.registers.PC = 0x0000
        cpu.registers.raiseFlag(.ZERO)
        cpu.jp_z_nn(address: EnhancedShort(0x1000))
        XCTAssertTrue(cpu.registers.PC == 0x1000)
        
        //0xDA
        cpu.registers.PC = 0x0000
        cpu.registers.clearFlag(.CARRY)
        cpu.jp_c_nn(address: EnhancedShort(0x1000))
        XCTAssertTrue(cpu.registers.PC == 0x0000)
        cpu.registers.PC = 0x0000
        cpu.registers.raiseFlag(.CARRY)
        cpu.jp_c_nn(address: EnhancedShort(0x1000))
        XCTAssertTrue(cpu.registers.PC == 0x1000)
    }
    
    func test_jr() throws {
        let cpu:CPU = CPU(mmu: MMU())
        
        //0x18
        //positive
        cpu.registers.PC = 0x1004
        cpu.jr_i8(val: 2)
        XCTAssertTrue(cpu.registers.PC == 0x1006)
        //negative
        cpu.registers.PC = 0x1004
        cpu.jr_i8(val: 0b1111_1100)//-4 two bit complement
        XCTAssertTrue(cpu.registers.PC == 0x1000)
        
        //0x20
        //positive
        cpu.registers.PC = 0x1004
        cpu.registers.raiseFlag(.ZERO)
        cpu.jr_nz_i8(val: 2)
        XCTAssertTrue(cpu.registers.PC == 0x1004)
        cpu.registers.PC = 0x1004
        cpu.registers.clearFlag(.ZERO)
        cpu.jr_nz_i8(val: 2)
        XCTAssertTrue(cpu.registers.PC == 0x1006)
        //negative
        cpu.registers.PC = 0x1004
        cpu.registers.raiseFlag(.ZERO)
        cpu.jr_nz_i8(val: 0b1111_1100)//-4 two bit complement
        XCTAssertTrue(cpu.registers.PC == 0x1004)
        cpu.registers.PC = 0x1004
        cpu.registers.clearFlag(.ZERO)
        cpu.jr_nz_i8(val: 0b1111_1100)//-4 two bit complement
        XCTAssertTrue(cpu.registers.PC == 0x1000)
        
        //0x30
        //positive
        cpu.registers.PC = 0x1004
        cpu.registers.raiseFlag(.CARRY)
        cpu.jr_nc_i8(val: 2)
        XCTAssertTrue(cpu.registers.PC == 0x1004)
        cpu.registers.PC = 0x1004
        cpu.registers.clearFlag(.CARRY)
        cpu.jr_nc_i8(val: 2)
        XCTAssertTrue(cpu.registers.PC == 0x1006)
        //negative
        cpu.registers.PC = 0x1004
        cpu.registers.raiseFlag(.CARRY)
        cpu.jr_nc_i8(val: 0b1111_1100)//-4 two bit complement
        XCTAssertTrue(cpu.registers.PC == 0x1004)
        cpu.registers.PC = 0x1004
        cpu.registers.clearFlag(.CARRY)
        cpu.jr_nc_i8(val: 0b1111_1100)//-4 two bit complement
        XCTAssertTrue(cpu.registers.PC == 0x1000)
        
        //0x28
        //positive
        cpu.registers.PC = 0x1004
        cpu.registers.clearFlag(.ZERO)
        cpu.jr_z_i8(val: 2)
        XCTAssertTrue(cpu.registers.PC == 0x1004)
        cpu.registers.PC = 0x1004
        cpu.registers.raiseFlag(.ZERO)
        cpu.jr_z_i8(val: 2)
        XCTAssertTrue(cpu.registers.PC == 0x1006)
        //negative
        cpu.registers.PC = 0x1004
        cpu.registers.clearFlag(.ZERO)
        cpu.jr_z_i8(val: 0b1111_1100)//-4 two bit complement
        XCTAssertTrue(cpu.registers.PC == 0x1004)
        cpu.registers.PC = 0x1004
        cpu.registers.raiseFlag(.ZERO)
        cpu.jr_z_i8(val: 0b1111_1100)//-4 two bit complement
        XCTAssertTrue(cpu.registers.PC == 0x1000)
        
        //0x38
        //positive
        cpu.registers.PC = 0x1004
        cpu.registers.clearFlag(.CARRY)
        cpu.jr_c_i8(val: 2)
        XCTAssertTrue(cpu.registers.PC == 0x1004)
        cpu.registers.PC = 0x1004
        cpu.registers.raiseFlag(.CARRY)
        cpu.jr_c_i8(val: 2)
        XCTAssertTrue(cpu.registers.PC == 0x1006)
        //negative
        cpu.registers.PC = 0x1004
        cpu.registers.clearFlag(.CARRY)
        cpu.jr_c_i8(val: 0b1111_1100)//-4 two bit complement
        XCTAssertTrue(cpu.registers.PC == 0x1004)
        cpu.registers.PC = 0x1004
        cpu.registers.raiseFlag(.CARRY)
        cpu.jr_c_i8(val: 0b1111_1100)//-4 two bit complement
        XCTAssertTrue(cpu.registers.PC == 0x1000)
        
    }
    
    func test_call() throws {
        let cpu:CPU = CPU(mmu: MMU())
        
        cpu.registers.PC = 0x0000
        cpu.registers.SP = 0x1000
        cpu.call(0x2000)
        XCTAssertTrue(cpu.registers.PC == 0x2000)
        
        cpu.registers.PC = 0x0000
        cpu.registers.SP = 0x1000
        cpu.registers.raiseFlag(.ZERO)
        cpu.call_z_nn(address: EnhancedShort(0x2000))
        XCTAssertTrue(cpu.registers.PC == 0x2000)
        cpu.registers.PC = 0x0000
        cpu.registers.SP = 0x1000
        cpu.registers.clearFlag(.ZERO)
        cpu.call_z_nn(address: EnhancedShort(0x2000))
        XCTAssertTrue(cpu.registers.PC == 0x0000)
        
        cpu.registers.PC = 0x0000
        cpu.registers.SP = 0x1000
        cpu.registers.raiseFlag(.CARRY)
        cpu.call_c_nn(address: EnhancedShort(0x2000))
        XCTAssertTrue(cpu.registers.PC == 0x2000)
        cpu.registers.PC = 0x0000
        cpu.registers.SP = 0x1000
        cpu.registers.clearFlag(.CARRY)
        cpu.call_c_nn(address: EnhancedShort(0x2000))
        XCTAssertTrue(cpu.registers.PC == 0x0000)
        
        cpu.registers.PC = 0x0000
        cpu.registers.SP = 0x1000
        cpu.registers.raiseFlag(.ZERO)
        cpu.call_nz_nn(address: EnhancedShort(0x2000))
        XCTAssertTrue(cpu.registers.PC == 0x0000)
        cpu.registers.PC = 0x0000
        cpu.registers.SP = 0x1000
        cpu.registers.clearFlag(.ZERO)
        cpu.call_nz_nn(address: EnhancedShort(0x2000))
        XCTAssertTrue(cpu.registers.PC == 0x2000)
        
        cpu.registers.PC = 0x0000
        cpu.registers.SP = 0x1000
        cpu.registers.raiseFlag(.CARRY)
        cpu.call_nc_nn(address: EnhancedShort(0x2000))
        XCTAssertTrue(cpu.registers.PC == 0x0000)
        cpu.registers.PC = 0x0000
        cpu.registers.SP = 0x1000
        cpu.registers.clearFlag(.CARRY)
        cpu.call_nc_nn(address: EnhancedShort(0x2000))
        XCTAssertTrue(cpu.registers.PC == 0x2000)
    }
    
    func test_ret() throws {
        let cpu:CPU = CPU(mmu: MMU())
        
        cpu.registers.PC = 0x0000
        cpu.registers.SP = 0x1000
        cpu.call(0x2000)
        XCTAssertTrue(cpu.registers.PC == 0x2000)
        cpu.ret()
        XCTAssertTrue(cpu.registers.PC == 0x0000)
        
        cpu.registers.PC = 0x0000
        cpu.registers.SP = 0x1000
        cpu.call(0x2000)
        XCTAssertTrue(cpu.registers.PC == 0x2000)
        cpu.mmu.IME = false
        cpu.reti()
        XCTAssertTrue(cpu.registers.PC == 0x0000)
        XCTAssertTrue(cpu.interrupts.IME == true)
        
        cpu.registers.PC = 0x0000
        cpu.registers.SP = 0x1000
        cpu.call(0x2000)
        XCTAssertTrue(cpu.registers.PC == 0x2000)
        cpu.registers.raiseFlag(.ZERO)
        cpu.ret_nz()
        XCTAssertTrue(cpu.registers.PC == 0x2000)
        cpu.registers.clearFlag(.ZERO)
        cpu.ret_nz()
        XCTAssertTrue(cpu.registers.PC == 0x0000)
        XCTAssertTrue(cpu.registers.SP == 0x1000)
        
        cpu.registers.PC = 0x0000
        cpu.registers.SP = 0x1000
        cpu.call(0x2000)
        XCTAssertTrue(cpu.registers.PC == 0x2000)
        cpu.registers.clearFlag(.ZERO)
        cpu.ret_z()
        XCTAssertTrue(cpu.registers.PC == 0x2000)
        cpu.registers.raiseFlag(.ZERO)
        cpu.ret_z()
        XCTAssertTrue(cpu.registers.PC == 0x0000)
        XCTAssertTrue(cpu.registers.SP == 0x1000)
        
        cpu.registers.PC = 0x0000
        cpu.registers.SP = 0x1000
        cpu.call(0x2000)
        XCTAssertTrue(cpu.registers.PC == 0x2000)
        cpu.registers.raiseFlag(.CARRY)
        cpu.ret_nc()
        XCTAssertTrue(cpu.registers.PC == 0x2000)
        cpu.registers.clearFlag(.CARRY)
        cpu.ret_nc()
        XCTAssertTrue(cpu.registers.PC == 0x0000)
        XCTAssertTrue(cpu.registers.SP == 0x1000)
        
        cpu.registers.PC = 0x0000
        cpu.registers.SP = 0x1000
        cpu.call(0x2000)
        XCTAssertTrue(cpu.registers.PC == 0x2000)
        cpu.registers.clearFlag(.CARRY)
        cpu.ret_c()
        XCTAssertTrue(cpu.registers.PC == 0x2000)
        cpu.registers.raiseFlag(.CARRY)
        cpu.ret_c()
        XCTAssertTrue(cpu.registers.PC == 0x0000)
        XCTAssertTrue(cpu.registers.SP == 0x1000)
    }
    
    func test_push() throws {
        let cpu:CPU = CPU(mmu: MMU())
        
        //0xC6
        cpu.registers.SP = 0xFFFF
        cpu.registers.BC = 0xBBCC
        cpu.push_bc()
        XCTAssertTrue(cpu.mmu[0xFFFE] == 0xBB && cpu.mmu[0xFFFD] == 0xCC)
        
        //0xD6
        cpu.registers.SP = 0xFFFF
        cpu.registers.DE = 0xDDEE
        cpu.push_de()
        XCTAssertTrue(cpu.mmu[0xFFFE] == 0xDD && cpu.mmu[0xFFFD] == 0xEE)
        
        //0xE6
        cpu.registers.SP = 0xFFFF
        cpu.registers.HL = 0xFFEE
        cpu.push_hl()
        XCTAssertTrue(cpu.mmu[0xFFFE] == 0xFF && cpu.mmu[0xFFFD] == 0xEE)
        
        //0xF6
        cpu.registers.SP = 0xFFFF
        cpu.registers.AF = 0xAAF0
        cpu.push_af()
        XCTAssertTrue(cpu.mmu[0xFFFE] == 0xAA && cpu.mmu[0xFFFD] == 0xF0)
    }
    
    func test_pop() throws {
        let cpu:CPU = CPU(mmu: MMU())
        
        //0xC1
        cpu.registers.SP = 0xFFFD
        cpu.registers.BC = 0x0000
        cpu.mmu[0xFFFE] = 0xBB
        cpu.mmu[0xFFFD] = 0xCC
        cpu.pop_bc()
        XCTAssertTrue(cpu.registers.BC == 0xBBCC)
        
        //0xD1
        cpu.registers.SP = 0xFFFD
        cpu.registers.DE = 0x0000
        cpu.mmu[0xFFFE] = 0xDD
        cpu.mmu[0xFFFD] = 0xEE
        cpu.pop_de()
        XCTAssertTrue(cpu.registers.DE == 0xDDEE)
        
        //0xE1
        cpu.registers.SP = 0xFFFD
        cpu.registers.HL = 0x0000
        cpu.mmu[0xFFFE] = 0xFF
        cpu.mmu[0xFFFD] = 0xEE
        cpu.pop_hl()
        XCTAssertTrue(cpu.registers.HL == 0xFFEE)
        
        //0xF1
        cpu.registers.SP = 0xFFFD
        cpu.registers.BC = 0x0000
        cpu.mmu[0xFFFE] = 0xAA
        cpu.mmu[0xFFFD] = 0xF0
        cpu.pop_af()
        XCTAssertTrue(cpu.registers.AF == 0xAAF0)
    }
    
    func test_rst() throws {
        let cpu:CPU = CPU(mmu: MMU())
        
        //0xC7
        cpu.registers.PC = 0xFFFF
        cpu.rst_00h()
        XCTAssertTrue(cpu.registers.PC == 0x0000)
        
        //0xCF
        cpu.registers.PC = 0xFFFF
        cpu.rst_08h()
        XCTAssertTrue(cpu.registers.PC == 0x0008)
        
        //0xD7
        cpu.registers.PC = 0xFFFF
        cpu.rst_10h()
        XCTAssertTrue(cpu.registers.PC == 0x0010)
        
        //0xDF
        cpu.registers.PC = 0xFFFF
        cpu.rst_18h()
        XCTAssertTrue(cpu.registers.PC == 0x0018)
        
        //0xE7
        cpu.registers.PC = 0xFFFF
        cpu.rst_20h()
        XCTAssertTrue(cpu.registers.PC == 0x0020)
        
        //0xEF
        cpu.registers.PC = 0xFFFF
        cpu.rst_28h()
        XCTAssertTrue(cpu.registers.PC == 0x0028)
        
        //0xF7
        cpu.registers.PC = 0xFFFF
        cpu.rst_30h()
        XCTAssertTrue(cpu.registers.PC == 0x0030)
        
        //0xFF
        cpu.registers.PC = 0xFFFF
        cpu.rst_38h()
        XCTAssertTrue(cpu.registers.PC == 0x0038)
    }
    
    func test_daa() throws {
        let cpu:CPU = CPU(mmu: MMU())
        cpu.registers.clearFlags(.CARRY,.HALF_CARRY,.NEGATIVE,.ZERO)
        
        cpu.registers.A = 0
        cpu.daa()
        XCTAssertTrue(cpu.registers.A == 0)
        
        //0x10 -> 0b0001_0000
        cpu.registers.A = 0x10
        cpu.daa()
        XCTAssertTrue(cpu.registers.A == 0b0001_0000)
        
        //0x20 -> 0b0010_0000
        cpu.registers.A = 0x20
        cpu.daa()
        XCTAssertTrue(cpu.registers.A == 0b0010_0000)
        
        //0x99 -> 0b1001_1001
        cpu.registers.A = 0x99
        cpu.daa()
        XCTAssertTrue(cpu.registers.A == 0b1001_1001)
        
        //9A (0x99+1) -> 0 (overflow)
        cpu.registers.A = 0x9A
        cpu.daa()
        XCTAssertTrue(cpu.registers.A == 0)
    }
    
    func test_rra() throws {
        let cpu:CPU = CPU(mmu: MMU())
        
        cpu.registers.clearFlag(.ZERO)
        cpu.registers.raiseFlag(.HALF_CARRY)
        cpu.registers.raiseFlag(.NEGATIVE)
        cpu.registers.clearFlag(.CARRY)
        cpu.registers.A = 0b0000_0001
        cpu.rra()
        XCTAssertTrue(cpu.registers.A == 0b0000_0000)
        XCTAssertTrue(cpu.registers.isFlagCleared(.ZERO))//cleared
        XCTAssertTrue(cpu.registers.isFlagSet(.CARRY))
        XCTAssertTrue(cpu.registers.isFlagCleared(.HALF_CARRY))
        XCTAssertTrue(cpu.registers.isFlagCleared(.NEGATIVE))
        
        cpu.registers.clearFlag(.ZERO)
        cpu.registers.raiseFlag(.HALF_CARRY)
        cpu.registers.raiseFlag(.NEGATIVE)
        cpu.registers.clearFlag(.CARRY)
        cpu.registers.A = 0b0000_0001
        cpu.rrca()
        XCTAssertTrue(cpu.registers.A == 0b1000_0000)
        XCTAssertTrue(cpu.registers.isFlagCleared(.ZERO))//cleared
        XCTAssertTrue(cpu.registers.isFlagSet(.CARRY))
        XCTAssertTrue(cpu.registers.isFlagCleared(.HALF_CARRY))
        XCTAssertTrue(cpu.registers.isFlagCleared(.NEGATIVE))
    }
    
    func test_rla() throws {
        let cpu:CPU = CPU(mmu: MMU())
        
        cpu.registers.clearFlag(.ZERO)
        cpu.registers.raiseFlag(.HALF_CARRY)
        cpu.registers.raiseFlag(.NEGATIVE)
        cpu.registers.clearFlag(.CARRY)
        cpu.registers.A = 0b0100_0000
        cpu.rla()
        XCTAssertTrue(cpu.registers.A == 0b1000_0000)
        XCTAssertTrue(cpu.registers.isFlagCleared(.ZERO))//cleared
        XCTAssertTrue(cpu.registers.isFlagCleared(.CARRY))
        XCTAssertTrue(cpu.registers.isFlagCleared(.HALF_CARRY))
        XCTAssertTrue(cpu.registers.isFlagCleared(.NEGATIVE))
        
        cpu.registers.clearFlag(.ZERO)
        cpu.registers.raiseFlag(.HALF_CARRY)
        cpu.registers.raiseFlag(.NEGATIVE)
        cpu.registers.clearFlag(.CARRY)
        cpu.registers.A = 0b1000_0000
        cpu.rlca()
        XCTAssertTrue(cpu.registers.A == 0b0000_0001)
        XCTAssertTrue(cpu.registers.isFlagCleared(.ZERO))//cleared
        XCTAssertTrue(cpu.registers.isFlagSet(.CARRY))
        XCTAssertTrue(cpu.registers.isFlagCleared(.HALF_CARRY))
        XCTAssertTrue(cpu.registers.isFlagCleared(.NEGATIVE))
    }
    
    func test_cpl() throws {
        let cpu:CPU = CPU(mmu: MMU())
        cpu.registers.A = 0b1010_1010
        cpu.cpl()
        XCTAssertTrue(cpu.registers.A == 0b0101_0101)
        XCTAssertTrue(cpu.registers.isFlagSet(.NEGATIVE))
        XCTAssertTrue(cpu.registers.isFlagSet(.HALF_CARRY))
    }
    
    func test_interrupt_enable() throws {
        let cpu:CPU = CPU(mmu: MMU())
        cpu.ei()
        XCTAssertTrue(cpu.interrupts.IME)
        cpu.di()
        XCTAssertFalse(cpu.interrupts.IME)
        cpu.ei()
        XCTAssertTrue(cpu.interrupts.IME)
    }
}
