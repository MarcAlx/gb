// a tuple that combines a byte (opcode) with a bool that indicates if opcode is extended
typealias OperationCode = (isExtended:Bool, code:UInt8)

///a function to convert any instruction to a more generic variable length wrapper
private func forward(_ one:OneByteInstruction? = nil,
             _ two:TwoBytesInstruction? = nil,
             _ three:ThreeBytesInstruction? = nil) -> VariableLengthInstruction {
    if let oneBI = one {
        return { _,_ in oneBI() }
    }
    else if let twoBI = two {
        return { byte,short in twoBI(byte!) }
    }
    else if let threeBI = three {
        return { byte,short in threeBI(short!) }
    }
    return emptyVariableLengthInstruction
}

public class CPUImplementation: CPUCore {
    func asStandardInstructions() -> [Instruction] {
        let unsupported:Instruction = Instruction(length: 1, name: "panic", duration:4, self.panic)
        return [
            Instruction(opCode: 0x00, length: 1, name: "nop", duration:4,nop),
            Instruction(opCode: 0x01, length: 3, name: "LD BC, 0x%04X", duration:12,ld_bc_nn),
            Instruction(opCode: 0x02, length: 1, name: "LD (BC), A", duration:8,ld_bcp_a),
            Instruction(opCode: 0x03, length: 1, name: "INC BC", duration:4,inc_bc),
            Instruction(opCode: 0x04, length: 1, name: "INC B", duration:4,inc_b),
            Instruction(opCode: 0x05, length: 1, name: "DEC B", duration:4,dec_b),
            Instruction(opCode: 0x06, length: 2, name: "LD B, 0x%02X", duration:8,ld_b_n),
            Instruction(opCode: 0x07, length: 1, name: "RLCA", duration:4,rlca),
            Instruction(opCode: 0x08, length: 3, name: "LD (0x%04X), SP", duration:20,ld_nnp_sp),
            Instruction(opCode: 0x09, length: 1, name: "ADD HL, BC", duration:8,add_hl_bc),
            Instruction(opCode: 0x0A, length: 1, name: "LD A, (BC)", duration:8,ld_a_bcp),
            Instruction(opCode: 0x0B, length: 1, name: "DEC BC", duration:8,dec_bc),
            Instruction(opCode: 0x0C, length: 1, name: "INC C", duration:4,inc_c),
            Instruction(opCode: 0x0D, length: 1, name: "DEC C", duration:4,dec_c),
            Instruction(opCode: 0x0E, length: 2, name: "LD C, 0x%02X", duration:8,ld_c_n),
            Instruction(opCode: 0x0F, length: 1, name: "RRCA", duration:4,rrca),
            Instruction(opCode: 0x10, length: 1, name: "STOP", duration:4,stop),
            Instruction(opCode: 0x11, length: 3, name: "LD DE, 0x%04X", duration:12,ld_de_nn),
            Instruction(opCode: 0x12, length: 1, name: "LD (DE), A", duration:8,ld_dep_a),
            Instruction(opCode: 0x13, length: 1, name: "INC DE", duration:4,inc_de),
            Instruction(opCode: 0x14, length: 1, name: "IND D", duration:4,inc_d),
            Instruction(opCode: 0x15, length: 1, name: "DEC D", duration:4,dec_d),
            Instruction(opCode: 0x16, length: 2, name: "LD D, 0x%02X", duration:8,ld_d_n),
            Instruction(opCode: 0x17, length: 1, name: "RLA", duration:4,rla),
            Instruction(opCode: 0x18, length: 2, name: "JR 0x%02X", duration:12,jr_i8),
            Instruction(opCode: 0x19, length: 1, name: "ADD HL, DE", duration:8,add_hl_de),
            Instruction(opCode: 0x1A, length: 1, name: "LD A, (DE)", duration:8,ld_a_dep),
            Instruction(opCode: 0x1B, length: 1, name: "DEC DE", duration:8,dec_de),
            Instruction(opCode: 0x1C, length: 1, name: "INC E", duration:4,inc_e),
            Instruction(opCode: 0x1D, length: 1, name: "DEC E", duration:4,dec_e),
            Instruction(opCode: 0x1E, length: 2, name: "LD E, 0x%02X", duration:8,ld_e_n),
            Instruction(opCode: 0x1F, length: 1, name: "RRA", duration:4,rra),
            Instruction(opCode: 0x20, length: 2, name: "JR NZ, 0x%02X", duration:12,jr_nz_i8),
            Instruction(opCode: 0x21, length: 3, name: "LD HL, 0x%04X", duration:12,ld_hl_nn),
            Instruction(opCode: 0x22, length: 1, name: "LD (HL+), A", duration:8,ld_hlpi_a),
            Instruction(opCode: 0x23, length: 1, name: "INC HL", duration:8,inc_hl),
            Instruction(opCode: 0x24, length: 1, name: "INC H", duration:4,inc_h),
            Instruction(opCode: 0x25, length: 1, name: "DEC H", duration:4,dec_h),
            Instruction(opCode: 0x26, length: 2, name: "LD H, 0x%02X", duration:8,ld_h_n),
            Instruction(opCode: 0x27, length: 1, name: "DAA", duration:4,daa),
            Instruction(opCode: 0x28, length: 2, name: "JR Z, 0x%02X", duration:12,jr_z_i8),
            Instruction(opCode: 0x29, length: 1, name: "ADD HL, HL", duration:8,add_hl_hl),
            Instruction(opCode: 0x2A, length: 1, name: "LD A, (HL+)", duration:8,ld_a_hlpi),
            Instruction(opCode: 0x2B, length: 1, name: "DEC HL", duration:8,dec_hl),
            Instruction(opCode: 0x2C, length: 1, name: "INC L", duration:4,inc_l),
            Instruction(opCode: 0x2D, length: 1, name: "DEC L", duration:4,dec_l),
            Instruction(opCode: 0x2E, length: 2, name: "LD L, 0x%02X", duration:8,ld_l_n),
            Instruction(opCode: 0x2F, length: 1, name: "CPL", duration:4,cpl),
            Instruction(opCode: 0x30, length: 2, name: "JR NC, 0x%02X", duration:12,jr_nc_i8),
            Instruction(opCode: 0x31, length: 3, name: "LD SP, 0x%04X", duration:12,ld_sp_nn),
            Instruction(opCode: 0x32, length: 1, name: "LD (HL-), A", duration:8,ld_hlpd_a),
            Instruction(opCode: 0x33, length: 1, name: "INC SP", duration:8,inc_sp),
            Instruction(opCode: 0x34, length: 1, name: "INC (HL)", duration:12,inc_hlp),
            Instruction(opCode: 0x35, length: 1, name: "DEC (HL)", duration:12,dec_hlp),
            Instruction(opCode: 0x36, length: 2, name: "LD (HL), 0x%02X", duration:12,ld_hlp_n),
            Instruction(opCode: 0x37, length: 1, name: "SCF", duration:4,scf),
            Instruction(opCode: 0x38, length: 2, name: "JR C, 0x%02X", duration:8,jr_c_i8),
            Instruction(opCode: 0x39, length: 1, name: "ADD HL, SP", duration:4,add_hl_sp),
            Instruction(opCode: 0x3A, length: 1, name: "LD A, (HL-)", duration:8,ld_a_hlpd),
            Instruction(opCode: 0x3B, length: 1, name: "DEC SP", duration:8,dec_sp),
            Instruction(opCode: 0x3C, length: 1, name: "INC A", duration:4,inc_a),
            Instruction(opCode: 0x3D, length: 1, name: "DEC A", duration:4,dec_a),
            Instruction(opCode: 0x3E, length: 2, name: "LD A, 0x%02X", duration:8,ld_a_n),
            Instruction(opCode: 0x3F, length: 1, name: "CCF", duration:4,ccf),
            Instruction(opCode: 0x40, length: 1, name: "LD B, B", duration:4,ld_b_b),
            Instruction(opCode: 0x41, length: 1, name: "LD B, C", duration:4,ld_b_c),
            Instruction(opCode: 0x42, length: 1, name: "LD B, D", duration:4,ld_b_d),
            Instruction(opCode: 0x43, length: 1, name: "LD B, E", duration:4,ld_b_e),
            Instruction(opCode: 0x44, length: 1, name: "LD B, H", duration:4,ld_b_h),
            Instruction(opCode: 0x45, length: 1, name: "LD B, L", duration:4,ld_b_l),
            Instruction(opCode: 0x46, length: 1, name: "LD B, (HL)", duration:8,ld_b_hlp),
            Instruction(opCode: 0x47, length: 1, name: "LD B, A", duration:4,ld_b_a),
            Instruction(opCode: 0x48, length: 1, name: "LD C, B", duration:4,ld_c_b),
            Instruction(opCode: 0x49, length: 1, name: "LD C, C", duration:4,ld_c_c),
            Instruction(opCode: 0x4A, length: 1, name: "LD C, D", duration:4,ld_c_d),
            Instruction(opCode: 0x4B, length: 1, name: "LD C, E", duration:4,ld_c_e),
            Instruction(opCode: 0x4C, length: 1, name: "LD C, H", duration:4,ld_c_h),
            Instruction(opCode: 0x4D, length: 1, name: "LD C, L", duration:4,ld_c_l),
            Instruction(opCode: 0x4E, length: 1, name: "LD C, (HL)", duration:8,ld_c_hlp),
            Instruction(opCode: 0x4F, length: 1, name: "LD C, A", duration:4,ld_c_a),
            Instruction(opCode: 0x50, length: 1, name: "LD D, B", duration:4,ld_d_b),
            Instruction(opCode: 0x51, length: 1, name: "LD D, C", duration:4,ld_d_c),
            Instruction(opCode: 0x52, length: 1, name: "LD D, D", duration:4,ld_d_d),
            Instruction(opCode: 0x53, length: 1, name: "LD D, E", duration:4,ld_d_e),
            Instruction(opCode: 0x54, length: 1, name: "LD D, H", duration:4,ld_d_h),
            Instruction(opCode: 0x55, length: 1, name: "LD D, L", duration:4,ld_d_l),
            Instruction(opCode: 0x56, length: 1, name: "LD D, (HL)", duration:8,ld_d_hlp),
            Instruction(opCode: 0x57, length: 1, name: "LD D, A", duration:4,ld_d_a),
            Instruction(opCode: 0x58, length: 1, name: "LD E, B", duration:4,ld_e_b),
            Instruction(opCode: 0x59, length: 1, name: "LD E, C", duration:4,ld_e_c),
            Instruction(opCode: 0x5A, length: 1, name: "LD E, D", duration:4,ld_e_d),
            Instruction(opCode: 0x5B, length: 1, name: "LD E, E", duration:4,ld_e_e),
            Instruction(opCode: 0x5C, length: 1, name: "LD E, H", duration:4,ld_e_h),
            Instruction(opCode: 0x5D, length: 1, name: "LD E, L", duration:4,ld_e_l),
            Instruction(opCode: 0x5E, length: 1, name: "LD E, (HL)", duration:8,ld_e_hlp),
            Instruction(opCode: 0x5F, length: 1, name: "LD E, A", duration:4,ld_e_a),
            Instruction(opCode: 0x60, length: 1, name: "LD H, B", duration:4,ld_h_b),
            Instruction(opCode: 0x61, length: 1, name: "LD H, C", duration:4,ld_h_c),
            Instruction(opCode: 0x62, length: 1, name: "LD H, D", duration:4,ld_h_d),
            Instruction(opCode: 0x63, length: 1, name: "LD H, E", duration:4,ld_h_e),
            Instruction(opCode: 0x64, length: 1, name: "LD H, H", duration:4,ld_h_h),
            Instruction(opCode: 0x65, length: 1, name: "LD H, L", duration:4,ld_h_l),
            Instruction(opCode: 0x66, length: 1, name: "LD H, (HL)", duration:8,ld_h_hlp),
            Instruction(opCode: 0x67, length: 1, name: "LD H, A", duration:4,ld_h_a),
            Instruction(opCode: 0x68, length: 1, name: "LD L, B", duration:4,ld_l_b),
            Instruction(opCode: 0x69, length: 1, name: "LD L, C", duration:4,ld_l_c),
            Instruction(opCode: 0x6A, length: 1, name: "LD L, D", duration:4,ld_l_d),
            Instruction(opCode: 0x6B, length: 1, name: "LD L, E", duration:4,ld_l_e),
            Instruction(opCode: 0x6C, length: 1, name: "LD L, H", duration:4,ld_l_h),
            Instruction(opCode: 0x6D, length: 1, name: "LD L, L", duration:4,ld_l_l),
            Instruction(opCode: 0x6E, length: 1, name: "LD L, (HL)", duration:8,ld_l_hlp),
            Instruction(opCode: 0x6F, length: 1, name: "LD L, A", duration:4,ld_l_a),
            Instruction(opCode: 0x70, length: 1, name: "LD (HL), B", duration:8,ld_hlp_b),
            Instruction(opCode: 0x71, length: 1, name: "LD (HL), C", duration:8,ld_hlp_c),
            Instruction(opCode: 0x72, length: 1, name: "LD (HL), D", duration:8,ld_hlp_d),
            Instruction(opCode: 0x73, length: 1, name: "LD (HL), E", duration:8,ld_hlp_e),
            Instruction(opCode: 0x74, length: 1, name: "LD (HL), H", duration:8,ld_hlp_h),
            Instruction(opCode: 0x75, length: 1, name: "LD (HL), L", duration:8,ld_hlp_l),
            Instruction(opCode: 0x76, length: 1, name: "HALT", duration:4,halt),
            Instruction(opCode: 0x77, length: 1, name: "LD (HL), A", duration:8,ld_hlp_a),
            Instruction(opCode: 0x78, length: 1, name: "LD A, B", duration:4,ld_a_b),
            Instruction(opCode: 0x79, length: 1, name: "LD A, C", duration:4,ld_a_c),
            Instruction(opCode: 0x7A, length: 1, name: "LD A, D", duration:4,ld_a_d),
            Instruction(opCode: 0x7B, length: 1, name: "LD A, E", duration:4,ld_a_e),
            Instruction(opCode: 0x7C, length: 1, name: "LD A, H", duration:4,ld_a_h),
            Instruction(opCode: 0x7D, length: 1, name: "LD A, L", duration:4,ld_a_l),
            Instruction(opCode: 0x7E, length: 1, name: "LD A, (HL)", duration:8,ld_a_hlp),
            Instruction(opCode: 0x7F, length: 1, name: "LD A, A", duration:4,ld_a_a),
            Instruction(opCode: 0x80, length: 1, name: "ADD A, B", duration:4,add_a_b),
            Instruction(opCode: 0x81, length: 1, name: "ADD A, C", duration:4,add_a_c),
            Instruction(opCode: 0x82, length: 1, name: "ADD A, D", duration:4,add_a_d),
            Instruction(opCode: 0x83, length: 1, name: "ADD A, E", duration:4,add_a_e),
            Instruction(opCode: 0x84, length: 1, name: "ADD A, H", duration:4,add_a_h),
            Instruction(opCode: 0x85, length: 1, name: "ADD A, L", duration:4,add_a_l),
            Instruction(opCode: 0x86, length: 1, name: "ADD A, (HL)", duration:8,add_a_hlp),
            Instruction(opCode: 0x87, length: 1, name: "ADD A, A", duration:4,add_a_a),
            Instruction(opCode: 0x88, length: 1, name: "ADC A, B", duration:4,adc_a_b),
            Instruction(opCode: 0x89, length: 1, name: "ADC A, C", duration:4,adc_a_c),
            Instruction(opCode: 0x8A, length: 1, name: "ADC A, D", duration:4,adc_a_d),
            Instruction(opCode: 0x8B, length: 1, name: "ADC A, E", duration:4,adc_a_e),
            Instruction(opCode: 0x8C, length: 1, name: "ADC A, H", duration:4,adc_a_h),
            Instruction(opCode: 0x8D, length: 1, name: "ADC A, L", duration:4,adc_a_l),
            Instruction(opCode: 0x8E, length: 1, name: "ADC A, (HL)", duration:8,adc_a_hlp),
            Instruction(opCode: 0x8F, length: 1, name: "ADC A, A", duration:4,adc_a_a),
            Instruction(opCode: 0x90, length: 1, name: "SUB A, B", duration:4,sub_a_b),
            Instruction(opCode: 0x91, length: 1, name: "SUB A, C", duration:4,sub_a_c),
            Instruction(opCode: 0x92, length: 1, name: "SUB A, D", duration:4,sub_a_d),
            Instruction(opCode: 0x93, length: 1, name: "SUB A, E", duration:4,sub_a_e),
            Instruction(opCode: 0x94, length: 1, name: "SUB A, H", duration:4,sub_a_h),
            Instruction(opCode: 0x95, length: 1, name: "SUB A, L", duration:4,sub_a_l),
            Instruction(opCode: 0x96, length: 1, name: "SUB A, (HL)", duration:8,sub_a_hlp),
            Instruction(opCode: 0x97, length: 1, name: "SUB A, A", duration:4,sub_a_a),
            Instruction(opCode: 0x98, length: 1, name: "SBC A, B", duration:4,sbc_a_b),
            Instruction(opCode: 0x99, length: 1, name: "SBC A, C", duration:4,sbc_a_c),
            Instruction(opCode: 0x9A, length: 1, name: "SBC A, D", duration:4,sbc_a_d),
            Instruction(opCode: 0x9B, length: 1, name: "SBC A, E", duration:4,sbc_a_e),
            Instruction(opCode: 0x9C, length: 1, name: "SBC A, H", duration:4,sbc_a_h),
            Instruction(opCode: 0x9D, length: 1, name: "SBC A, L", duration:4,sbc_a_l),
            Instruction(opCode: 0x9E, length: 1, name: "SBC A, (HL)", duration:8,sbc_a_hlp),
            Instruction(opCode: 0x9F, length: 1, name: "SBC A, A", duration:4,sbc_a_a),
            Instruction(opCode: 0xA0, length: 1, name: "AND A, B", duration:4,and_a_b),
            Instruction(opCode: 0xA1, length: 1, name: "AND A, C", duration:4,and_a_c),
            Instruction(opCode: 0xA2, length: 1, name: "AND A, D", duration:4,and_a_d),
            Instruction(opCode: 0xA3, length: 1, name: "AND A, E", duration:4,and_a_e),
            Instruction(opCode: 0xA4, length: 1, name: "AND A, H", duration:4,and_a_h),
            Instruction(opCode: 0xA5, length: 1, name: "AND A, L", duration:4,and_a_l),
            Instruction(opCode: 0xA6, length: 1, name: "AND A, (HL)", duration:8,and_a_hlp),
            Instruction(opCode: 0xA7, length: 1, name: "AND A, A", duration:4,and_a_a),
            Instruction(opCode: 0xA8, length: 1, name: "XOR A, B", duration:4,xor_a_b),
            Instruction(opCode: 0xA9, length: 1, name: "XOR A, C", duration:4,xor_a_c),
            Instruction(opCode: 0xAA, length: 1, name: "XOR A, D", duration:4,xor_a_d),
            Instruction(opCode: 0xAB, length: 1, name: "XOR A, E", duration:4,xor_a_e),
            Instruction(opCode: 0xAC, length: 1, name: "XOR A, H", duration:4,xor_a_h),
            Instruction(opCode: 0xAD, length: 1, name: "XOR A, L", duration:4,xor_a_l),
            Instruction(opCode: 0xAE, length: 1, name: "XOR A, (HL)", duration:8,xor_a_hlp),
            Instruction(opCode: 0xAF, length: 1, name: "XOR A, A", duration:4,xor_a_a),
            Instruction(opCode: 0xB0, length: 1, name: "OR A, B", duration:4,or_a_b),
            Instruction(opCode: 0xB1, length: 1, name: "OR A, C", duration:4,or_a_c),
            Instruction(opCode: 0xB2, length: 1, name: "OR A, D", duration:4,or_a_d),
            Instruction(opCode: 0xB3, length: 1, name: "OR A, E", duration:4,or_a_e),
            Instruction(opCode: 0xB4, length: 1, name: "OR A, H", duration:4,or_a_h),
            Instruction(opCode: 0xB5, length: 1, name: "OR A, L", duration:4,or_a_l),
            Instruction(opCode: 0xB6, length: 1, name: "OR A, (HL)", duration:8,or_a_hlp),
            Instruction(opCode: 0xB7, length: 1, name: "OR A, A", duration:4,or_a_a),
            Instruction(opCode: 0xB8, length: 1, name: "CP A, B", duration:4,cp_a_b),
            Instruction(opCode: 0xB9, length: 1, name: "CP A, C", duration:4,cp_a_c),
            Instruction(opCode: 0xBA, length: 1, name: "CP A, D", duration:4,cp_a_d),
            Instruction(opCode: 0xBB, length: 1, name: "CP A, E", duration:4,cp_a_e),
            Instruction(opCode: 0xBC, length: 1, name: "CP A, H", duration:4,cp_a_h),
            Instruction(opCode: 0xBD, length: 1, name: "CP A, L", duration:4,cp_a_l),
            Instruction(opCode: 0xBE, length: 1, name: "CP A, (HL)", duration:8,cp_a_hlp),
            Instruction(opCode: 0xBF, length: 1, name: "CP A, A", duration:4,cp_a_a),
            Instruction(opCode: 0xC0, length: 1, name: "RET NZ", duration:8,ret_nz),
            Instruction(opCode: 0xC1, length: 1, name: "POP BC", duration:12,pop_bc),
            Instruction(opCode: 0xC2, length: 3, name: "JP NZ, 0x%04X", duration:12,jp_nz_nn),
            Instruction(opCode: 0xC3, length: 3, name: "JP 0x%04X", duration:16,jp_nn),
            Instruction(opCode: 0xC4, length: 3, name: "CALL NZ, 0x%04X", duration:12,call_nz_nn),
            Instruction(opCode: 0xC5, length: 1, name: "PUSH BC", duration:16,push_bc),
            Instruction(opCode: 0xC6, length: 2, name: "ADD A, 0x%02X", duration:8,add_a_n),
            Instruction(opCode: 0xC7, length: 1, name: "RST 00h", duration:16,rst_00h),
            Instruction(opCode: 0xC8, length: 1, name: "RET Z", duration:8,ret_z),
            Instruction(opCode: 0xC9, length: 1, name: "RET", duration:16,ret),
            Instruction(opCode: 0xCA, length: 3, name: "JP Z, 0x%04X", duration:12,jp_z_nn),
            unsupported,//0xCB -> route to extended instruction set
            Instruction(opCode: 0xCC, length: 3, name: "CALL Z, 0x%04X", duration:12,call_z_nn),
            Instruction(opCode: 0xCD, length: 3, name: "CALL 0x%04X", duration:24,call_nn),
            Instruction(opCode: 0xCE, length: 2, name: "ADC A, 0x%02X", duration:8,adc_a_n),
            Instruction(opCode: 0xCF, length: 1, name: "RST 08h", duration:16,rst_08h),
            Instruction(opCode: 0xD0, length: 1, name: "RET NC", duration:8,ret_nc),
            Instruction(opCode: 0xD1, length: 1, name: "POP DE", duration:12,pop_de),
            Instruction(opCode: 0xD2, length: 3, name: "JP NC, 0x%04X", duration:12,jp_nc_nn),
            unsupported,//0xD3
            Instruction(opCode: 0xD4, length: 3, name: "CALL NC, 0x%04X", duration:12,call_nc_nn),
            Instruction(opCode: 0xD5, length: 1, name: "PUSH DE", duration:16,push_de),
            Instruction(opCode: 0xD6, length: 2, name: "SUB A, 0x%02X", duration:8,sub_a_n),
            Instruction(opCode: 0xD7, length: 1, name: "RST 10h", duration:16,rst_10h),
            Instruction(opCode: 0xD8, length: 1, name: "RET C", duration:8,ret_c),
            Instruction(opCode: 0xD9, length: 1, name: "RETI", duration:16,reti),
            Instruction(opCode: 0xDA, length: 3, name: "JP C, 0x%04X", duration:12,jp_c_nn),
            unsupported,//0xDB
            Instruction(opCode: 0xDC, length: 3, name: "CALL C, 0x%04X", duration:12,call_c_nn),
            unsupported,//0xDD
            Instruction(opCode: 0xDE, length: 2, name: "SBC A, 0x%02X", duration:8,sbc_a_n),
            Instruction(opCode: 0xDF, length: 1, name: "RST 18h", duration:16,rst_18h),
            Instruction(opCode: 0xE0, length: 2, name: "LD (FF00+0x%02X) A", duration:12,ld_ff00pn_a),
            Instruction(opCode: 0xE1, length: 1, name: "POP HL", duration:12,pop_hl),
            Instruction(opCode: 0xE2, length: 1, name: "LD (FF00+C), A", duration:8,ld_ff00pc_a),
            unsupported,//0xE3
            unsupported,//0xE4
            Instruction(opCode: 0xE5, length: 1, name: "PUSH HL", duration:16,push_hl),
            Instruction(opCode: 0xE6, length: 2, name: "AND A, 0x%02X", duration:8,and_a_n),
            Instruction(opCode: 0xE7, length: 1, name: "RST 20h", duration:16,rst_20h),
            Instruction(opCode: 0xE8, length: 2, name: "ADD SP, 0x%02X", duration:16,add_sp_i8),
            Instruction(opCode: 0xE9, length: 1, name: "JP HL", duration:4,jp_hl),
            Instruction(opCode: 0xEA, length: 3, name: "LD 0x%04X, A", duration:16,ld_nnp_a),
            unsupported,//0xEB
            unsupported,//0xEC
            unsupported,//0xED
            Instruction(opCode: 0xEE, length: 2, name: "XOR A, 0x%02X", duration:8,xor_a_n),
            Instruction(opCode: 0xEF, length: 1, name: "RST 28h", duration:16,rst_28h),
            Instruction(opCode: 0xF0, length: 2, name: "LD A, (FF00+0x%02X)", duration:12,ld_a_ff00pn),
            Instruction(opCode: 0xF1, length: 1, name: "POP AF", duration:12,pop_af),
            Instruction(opCode: 0xF2, length: 1, name: "LD A FF00+C", duration:8,ld_a_ff00pc),
            Instruction(opCode: 0xF3, length: 1, name: "DI", duration:4,di),
            unsupported,//0xF4
            Instruction(opCode: 0xF5, length: 1, name: "PUSH AF", duration:16,push_af),
            Instruction(opCode: 0xF6, length: 2, name: "OR A, 0x%02X", duration:8,or_a_n),
            Instruction(opCode: 0xF7, length: 1, name: "RST 30h", duration:16,rst_30h),
            Instruction(opCode: 0xF8, length: 2, name: "LD HL, SP+0x%02X", duration:12,ld_hl_sppi8),
            Instruction(opCode: 0xF9, length: 1, name: "LD SP, HL", duration:8,ld_sp_hl),
            Instruction(opCode: 0xFA, length: 3, name: "LD A, (0x%04X)", duration:16,ld_a_nnp),
            Instruction(opCode: 0xFB, length: 1, name: "EI", duration:4,ei),
            unsupported,//0xFC
            unsupported,//0xFD
            Instruction(opCode: 0xFE, length: 2, name: "CP A, 0x%02X", duration:8,cp_a_n),
            Instruction(opCode: 0xFF, length: 1, name: "RST 38h", duration:16,rst_38h)
        ]
    }
    
    func asExtentedInstructions() -> [Instruction] {
        return [
            Instruction(opCode: 0x00, length: 1, name: "RLC B", duration:8,rlc_b),
            Instruction(opCode: 0x01, length: 1, name: "RLC C", duration:8,rlc_c),
            Instruction(opCode: 0x02, length: 1, name: "RLC D", duration:8,rlc_d),
            Instruction(opCode: 0x03, length: 1, name: "RLC E", duration:8,rlc_e),
            Instruction(opCode: 0x04, length: 1, name: "RLC H", duration:8,rlc_h),
            Instruction(opCode: 0x05, length: 1, name: "RLC L", duration:8,rlc_l),
            Instruction(opCode: 0x06, length: 1, name: "RLC (HL)", duration:16,rlc_hlp),
            Instruction(opCode: 0x07, length: 1, name: "RLC A", duration:8,rlc_a),
            Instruction(opCode: 0x08, length: 1, name: "RRC B", duration:8,rrc_b),
            Instruction(opCode: 0x09, length: 1, name: "RRC C", duration:8,rrc_c),
            Instruction(opCode: 0x0A, length: 1, name: "RRC D", duration:8,rrc_d),
            Instruction(opCode: 0x0B, length: 1, name: "RRC E", duration:8,rrc_e),
            Instruction(opCode: 0x0C, length: 1, name: "RRC H", duration:8,rrc_h),
            Instruction(opCode: 0x0D, length: 1, name: "RRC L", duration:8,rrc_l),
            Instruction(opCode: 0x0E, length: 1, name: "RRC (HL)", duration:16,rrc_hlp),
            Instruction(opCode: 0x0F, length: 1, name: "RRC A", duration:8,rrc_a),
            Instruction(opCode: 0x10, length: 1, name: "RL B", duration:8,rl_b),
            Instruction(opCode: 0x11, length: 1, name: "RL C", duration:8,rl_c),
            Instruction(opCode: 0x12, length: 1, name: "RL D", duration:8,rl_d),
            Instruction(opCode: 0x13, length: 1, name: "RL E", duration:8,rl_e),
            Instruction(opCode: 0x14, length: 1, name: "RL H", duration:8,rl_h),
            Instruction(opCode: 0x15, length: 1, name: "RL L", duration:8,rl_l),
            Instruction(opCode: 0x16, length: 1, name: "RL (HL)", duration:16,rl_hlp),
            Instruction(opCode: 0x17, length: 1, name: "RL A", duration:8,rl_a),
            Instruction(opCode: 0x18, length: 1, name: "RR B", duration:8,rr_b),
            Instruction(opCode: 0x19, length: 1, name: "RR C", duration:8,rr_c),
            Instruction(opCode: 0x1A, length: 1, name: "RR D", duration:8,rr_d),
            Instruction(opCode: 0x1B, length: 1, name: "RR E", duration:8,rr_e),
            Instruction(opCode: 0x1C, length: 1, name: "RR H", duration:8,rr_h),
            Instruction(opCode: 0x1D, length: 1, name: "RR L", duration:8,rr_l),
            Instruction(opCode: 0x1E, length: 1, name: "RR (HL)", duration:16,rr_hlp),
            Instruction(opCode: 0x1F, length: 1, name: "RR A", duration:8,rr_a),
            Instruction(opCode: 0x20, length: 1, name: "SLA B", duration:8,sla_b),
            Instruction(opCode: 0x21, length: 1, name: "SLA C", duration:8,sla_c),
            Instruction(opCode: 0x22, length: 1, name: "SLA D", duration:8,sla_d),
            Instruction(opCode: 0x23, length: 1, name: "SLA E", duration:8,sla_e),
            Instruction(opCode: 0x24, length: 1, name: "SLA H", duration:8,sla_h),
            Instruction(opCode: 0x25, length: 1, name: "SLA L", duration:8,sla_l),
            Instruction(opCode: 0x26, length: 1, name: "SLA (HL)", duration:16,sla_hlp),
            Instruction(opCode: 0x27, length: 1, name: "SLA A", duration:8,sla_a),
            Instruction(opCode: 0x28, length: 1, name: "SRA B", duration:8,sra_b),
            Instruction(opCode: 0x29, length: 1, name: "SRA C", duration:8,sra_c),
            Instruction(opCode: 0x2A, length: 1, name: "SRA D", duration:8,sra_d),
            Instruction(opCode: 0x2B, length: 1, name: "SRA E", duration:8,sra_e),
            Instruction(opCode: 0x2C, length: 1, name: "SRA H", duration:8,sra_h),
            Instruction(opCode: 0x2D, length: 1, name: "SRA L", duration:8,sra_l),
            Instruction(opCode: 0x2E, length: 1, name: "SRA (HL)", duration:16,sra_hlp),
            Instruction(opCode: 0x2F, length: 1, name: "SRA A", duration:8,sra_a),
            Instruction(opCode: 0x30, length: 1, name: "SWAP B", duration:8,swap_b),
            Instruction(opCode: 0x31, length: 1, name: "SWAP C", duration:8,swap_c),
            Instruction(opCode: 0x32, length: 1, name: "SWAP D", duration:8,swap_d),
            Instruction(opCode: 0x33, length: 1, name: "SWAP E", duration:8,swap_e),
            Instruction(opCode: 0x34, length: 1, name: "SWAP H", duration:8,swap_h),
            Instruction(opCode: 0x35, length: 1, name: "SWAP L", duration:8,swap_l),
            Instruction(opCode: 0x36, length: 1, name: "SWAP (HL)", duration:16,swap_hlp),
            Instruction(opCode: 0x37, length: 1, name: "SWAP A", duration:8,swap_a),
            Instruction(opCode: 0x38, length: 1, name: "SRL B", duration:8,srl_b),
            Instruction(opCode: 0x39, length: 1, name: "SRL C", duration:8,srl_c),
            Instruction(opCode: 0x3A, length: 1, name: "SRL D", duration:8,srl_d),
            Instruction(opCode: 0x3B, length: 1, name: "SRL E", duration:8,srl_e),
            Instruction(opCode: 0x3C, length: 1, name: "SRL H", duration:8,srl_h),
            Instruction(opCode: 0x3D, length: 1, name: "SRL L", duration:8,srl_l),
            Instruction(opCode: 0x3E, length: 1, name: "SRL (HL)", duration:16,srl_hlp),
            Instruction(opCode: 0x3F, length: 1, name: "SRL A", duration:8,srl_a),
            Instruction(opCode: 0x40, length: 1, name: "BIT 0, B", duration:8,bit_0_b),
            Instruction(opCode: 0x41, length: 1, name: "BIT 0, C", duration:8,bit_0_c),
            Instruction(opCode: 0x42, length: 1, name: "BIT 0, D", duration:8,bit_0_d),
            Instruction(opCode: 0x43, length: 1, name: "BIT 0, E", duration:8,bit_0_e),
            Instruction(opCode: 0x44, length: 1, name: "BIT 0, H", duration:8,bit_0_h),
            Instruction(opCode: 0x45, length: 1, name: "BIT 0, L", duration:8,bit_0_l),
            Instruction(opCode: 0x46, length: 1, name: "BIT 0, (HL)", duration:12,bit_0_hlp),
            Instruction(opCode: 0x47, length: 1, name: "BIT 0, A", duration:8,bit_0_a),
            Instruction(opCode: 0x48, length: 1, name: "BIT 1, B", duration:8,bit_1_b),
            Instruction(opCode: 0x49, length: 1, name: "BIT 1, C", duration:8,bit_1_c),
            Instruction(opCode: 0x4A, length: 1, name: "BIT 1, D", duration:8,bit_1_d),
            Instruction(opCode: 0x4B, length: 1, name: "BIT 1, E", duration:8,bit_1_e),
            Instruction(opCode: 0x4C, length: 1, name: "BIT 1, H", duration:8,bit_1_h),
            Instruction(opCode: 0x4D, length: 1, name: "BIT 1, L", duration:8,bit_1_l),
            Instruction(opCode: 0x4E, length: 1, name: "BIT 1, (HL)", duration:12,bit_1_hlp),
            Instruction(opCode: 0x4F, length: 1, name: "BIT 1, A", duration:8,bit_1_a),
            Instruction(opCode: 0x50, length: 1, name: "BIT 2, B", duration:8,bit_2_b),
            Instruction(opCode: 0x51, length: 1, name: "BIT 2, C", duration:8,bit_2_c),
            Instruction(opCode: 0x52, length: 1, name: "BIT 2, D", duration:8,bit_2_d),
            Instruction(opCode: 0x53, length: 1, name: "BIT 2, E", duration:8,bit_2_e),
            Instruction(opCode: 0x54, length: 1, name: "BIT 2, H", duration:8,bit_2_h),
            Instruction(opCode: 0x55, length: 1, name: "BIT 2, L", duration:8,bit_2_l),
            Instruction(opCode: 0x56, length: 1, name: "BIT 2, (HL)", duration:12,bit_2_hlp),
            Instruction(opCode: 0x57, length: 1, name: "BIT 2, A", duration:8,bit_2_a),
            Instruction(opCode: 0x58, length: 1, name: "BIT 3, B", duration:8,bit_3_b),
            Instruction(opCode: 0x59, length: 1, name: "BIT 3, C", duration:8,bit_3_c),
            Instruction(opCode: 0x5A, length: 1, name: "BIT 3, D", duration:8,bit_3_d),
            Instruction(opCode: 0x5B, length: 1, name: "BIT 3, E", duration:8,bit_3_e),
            Instruction(opCode: 0x5C, length: 1, name: "BIT 3, H", duration:8,bit_3_h),
            Instruction(opCode: 0x5D, length: 1, name: "BIT 3, L", duration:8,bit_3_l),
            Instruction(opCode: 0x5E, length: 1, name: "BIT 3, (HL)", duration:12,bit_3_hlp),
            Instruction(opCode: 0x5F, length: 1, name: "BIT 3, A", duration:8,bit_3_a),
            Instruction(opCode: 0x60, length: 1, name: "BIT 4, B", duration:8,bit_4_b),
            Instruction(opCode: 0x61, length: 1, name: "BIT 4, C", duration:8,bit_4_c),
            Instruction(opCode: 0x62, length: 1, name: "BIT 4, D", duration:8,bit_4_d),
            Instruction(opCode: 0x63, length: 1, name: "BIT 4, E", duration:8,bit_4_e),
            Instruction(opCode: 0x64, length: 1, name: "BIT 4, H", duration:8,bit_4_h),
            Instruction(opCode: 0x65, length: 1, name: "BIT 4, L", duration:8,bit_4_l),
            Instruction(opCode: 0x66, length: 1, name: "BIT 4, (HL)", duration:12,bit_4_hlp),
            Instruction(opCode: 0x67, length: 1, name: "BIT 4, A", duration:8,bit_4_a),
            Instruction(opCode: 0x68, length: 1, name: "BIT 5, B", duration:8,bit_5_b),
            Instruction(opCode: 0x69, length: 1, name: "BIT 5, C", duration:8,bit_5_c),
            Instruction(opCode: 0x6A, length: 1, name: "BIT 5, D", duration:8,bit_5_d),
            Instruction(opCode: 0x6B, length: 1, name: "BIT 5, E", duration:8,bit_5_e),
            Instruction(opCode: 0x6C, length: 1, name: "BIT 6, H", duration:8,bit_5_h),
            Instruction(opCode: 0x6D, length: 1, name: "BIT 6, L", duration:8,bit_5_l),
            Instruction(opCode: 0x6E, length: 1, name: "BIT 5, (HL)", duration:12,bit_5_hlp),
            Instruction(opCode: 0x6F, length: 1, name: "BIT 5, A", duration:8,bit_5_a),
            Instruction(opCode: 0x70, length: 1, name: "BIT 6, B", duration:8,bit_6_b),
            Instruction(opCode: 0x71, length: 1, name: "BIT 6, C", duration:8,bit_6_c),
            Instruction(opCode: 0x72, length: 1, name: "BIT 6, D", duration:8,bit_6_d),
            Instruction(opCode: 0x73, length: 1, name: "BIT 6, E", duration:8,bit_6_e),
            Instruction(opCode: 0x74, length: 1, name: "BIT 6, H", duration:8,bit_6_h),
            Instruction(opCode: 0x75, length: 1, name: "BIT 6, L", duration:8,bit_6_l),
            Instruction(opCode: 0x76, length: 1, name: "BIT 6, (HL)", duration:12,bit_6_hlp),
            Instruction(opCode: 0x77, length: 1, name: "BIT 6, A", duration:8,bit_6_a),
            Instruction(opCode: 0x78, length: 1, name: "BIT 7, B", duration:8,bit_7_b),
            Instruction(opCode: 0x79, length: 1, name: "BIT 7, C", duration:8,bit_7_c),
            Instruction(opCode: 0x7A, length: 1, name: "BIT 7, D", duration:8,bit_7_d),
            Instruction(opCode: 0x7B, length: 1, name: "BIT 7, E", duration:8,bit_7_e),
            Instruction(opCode: 0x7C, length: 1, name: "BIT 7, H", duration:8,bit_7_h),
            Instruction(opCode: 0x7D, length: 1, name: "BIT 7, L", duration:8,bit_7_l),
            Instruction(opCode: 0x7E, length: 1, name: "BIT 7, (HL)", duration:12,bit_7_hlp),
            Instruction(opCode: 0x7F, length: 1, name: "BIT 7, A", duration:8,bit_7_a),
            Instruction(opCode: 0x80, length: 1, name: "RES 0, B", duration:8,res_0_b),
            Instruction(opCode: 0x81, length: 1, name: "RES 0, C", duration:8,res_0_c),
            Instruction(opCode: 0x82, length: 1, name: "RES 0, D", duration:8,res_0_d),
            Instruction(opCode: 0x83, length: 1, name: "RES 0, E", duration:8,res_0_e),
            Instruction(opCode: 0x84, length: 1, name: "RES 0, H", duration:8,res_0_h),
            Instruction(opCode: 0x85, length: 1, name: "RES 0, L", duration:8,res_0_l),
            Instruction(opCode: 0x86, length: 1, name: "RES 0, (HL)", duration:16,res_0_hlp),
            Instruction(opCode: 0x87, length: 1, name: "RES 0, A", duration:8,res_0_a),
            Instruction(opCode: 0x88, length: 1, name: "RES 1, B", duration:8,res_1_b),
            Instruction(opCode: 0x89, length: 1, name: "RES 1, C", duration:8,res_1_c),
            Instruction(opCode: 0x8A, length: 1, name: "RES 1, D", duration:8,res_1_d),
            Instruction(opCode: 0x8B, length: 1, name: "RES 1, E", duration:8,res_1_e),
            Instruction(opCode: 0x8C, length: 1, name: "RES 1, H", duration:8,res_1_h),
            Instruction(opCode: 0x8D, length: 1, name: "RES 1, L", duration:8,res_1_l),
            Instruction(opCode: 0x8E, length: 1, name: "RES 1, (HL)", duration:16,res_1_hlp),
            Instruction(opCode: 0x8F, length: 1, name: "RES 1, A", duration:8,res_1_a),
            Instruction(opCode: 0x90, length: 1, name: "RES 2, B", duration:8,res_2_b),
            Instruction(opCode: 0x91, length: 1, name: "RES 2, C", duration:8,res_2_c),
            Instruction(opCode: 0x92, length: 1, name: "RES 2, D", duration:8,res_2_d),
            Instruction(opCode: 0x93, length: 1, name: "RES 2, E", duration:8,res_2_e),
            Instruction(opCode: 0x94, length: 1, name: "RES 2, H", duration:8,res_2_h),
            Instruction(opCode: 0x95, length: 1, name: "RES 2, L", duration:8,res_2_l),
            Instruction(opCode: 0x96, length: 1, name: "RES 2, (HL)", duration:16,res_2_hlp),
            Instruction(opCode: 0x97, length: 1, name: "RES 2, A", duration:8,res_2_a),
            Instruction(opCode: 0x98, length: 1, name: "RES 3, B", duration:8,res_3_b),
            Instruction(opCode: 0x99, length: 1, name: "RES 3, C", duration:8,res_3_c),
            Instruction(opCode: 0x9A, length: 1, name: "RES 3, D", duration:8,res_3_d),
            Instruction(opCode: 0x9B, length: 1, name: "RES 3, E", duration:8,res_3_e),
            Instruction(opCode: 0x9C, length: 1, name: "RES 3, H", duration:8,res_3_h),
            Instruction(opCode: 0x9D, length: 1, name: "RES 3, L", duration:8,res_3_l),
            Instruction(opCode: 0x9E, length: 1, name: "RES 3, (HL)", duration:16,res_3_hlp),
            Instruction(opCode: 0x9F, length: 1, name: "RES 3, A", duration:8,res_3_a),
            Instruction(opCode: 0xA0, length: 1, name: "RES 4, B", duration:8,res_4_b),
            Instruction(opCode: 0xA1, length: 1, name: "RES 4, C", duration:8,res_4_c),
            Instruction(opCode: 0xA2, length: 1, name: "RES 4, D", duration:8,res_4_d),
            Instruction(opCode: 0xA3, length: 1, name: "RES 4, E", duration:8,res_4_e),
            Instruction(opCode: 0xA4, length: 1, name: "RES 4, H", duration:8,res_4_h),
            Instruction(opCode: 0xA5, length: 1, name: "RES 4, L", duration:8,res_4_l),
            Instruction(opCode: 0xA6, length: 1, name: "RES 4, (HL)", duration:16,res_4_hlp),
            Instruction(opCode: 0xA7, length: 1, name: "RES 4, A", duration:8,res_4_a),
            Instruction(opCode: 0xA8, length: 1, name: "RES 5, B", duration:8,res_5_b),
            Instruction(opCode: 0xA9, length: 1, name: "RES 5, C", duration:8,res_5_c),
            Instruction(opCode: 0xAA, length: 1, name: "RES 5, D", duration:8,res_5_d),
            Instruction(opCode: 0xAB, length: 1, name: "RES 5, E", duration:8,res_5_e),
            Instruction(opCode: 0xAC, length: 1, name: "RES 5, H", duration:8,res_5_h),
            Instruction(opCode: 0xAD, length: 1, name: "RES 5, L", duration:8,res_5_l),
            Instruction(opCode: 0xAE, length: 1, name: "RES 5, (HL)", duration:16,res_5_hlp),
            Instruction(opCode: 0xAF, length: 1, name: "RES 5, A", duration:8,res_5_a),
            Instruction(opCode: 0xB0, length: 1, name: "RES 6, B", duration:8,res_6_b),
            Instruction(opCode: 0xB1, length: 1, name: "RES 6, C", duration:8,res_6_c),
            Instruction(opCode: 0xB2, length: 1, name: "RES 6, D", duration:8,res_6_d),
            Instruction(opCode: 0xB3, length: 1, name: "RES 6, E", duration:8,res_6_e),
            Instruction(opCode: 0xB4, length: 1, name: "RES 6, H", duration:8,res_6_h),
            Instruction(opCode: 0xB5, length: 1, name: "RES 6, L", duration:8,res_6_l),
            Instruction(opCode: 0xB6, length: 1, name: "RES 6, (HL)", duration:16,res_6_hlp),
            Instruction(opCode: 0xB7, length: 1, name: "RES 6, A", duration:8,res_6_a),
            Instruction(opCode: 0xB8, length: 1, name: "RES 7, B", duration:8,res_7_b),
            Instruction(opCode: 0xB9, length: 1, name: "RES 7, C", duration:8,res_7_c),
            Instruction(opCode: 0xBA, length: 1, name: "RES 7, D", duration:8,res_7_d),
            Instruction(opCode: 0xBB, length: 1, name: "RES 7, E", duration:8,res_7_e),
            Instruction(opCode: 0xBC, length: 1, name: "RES 7, H", duration:8,res_7_h),
            Instruction(opCode: 0xBD, length: 1, name: "RES 7, L", duration:8,res_7_l),
            Instruction(opCode: 0xBE, length: 1, name: "RES 7, (HL)", duration:16,res_7_hlp),
            Instruction(opCode: 0xBF, length: 1, name: "RES 7, A", duration:8,res_7_a),
            Instruction(opCode: 0xC0, length: 1, name: "SET 0, B", duration:8,set_0_b),
            Instruction(opCode: 0xC1, length: 1, name: "SET 0, C", duration:8,set_0_c),
            Instruction(opCode: 0xC2, length: 1, name: "SET 0, D", duration:8,set_0_d),
            Instruction(opCode: 0xC3, length: 1, name: "SET 0, E", duration:8,set_0_e),
            Instruction(opCode: 0xC4, length: 1, name: "SET 0, H", duration:8,set_0_h),
            Instruction(opCode: 0xC5, length: 1, name: "SET 0, L", duration:8,set_0_l),
            Instruction(opCode: 0xC6, length: 1, name: "SET 0, (HL)", duration:16,set_0_hlp),
            Instruction(opCode: 0xC7, length: 1, name: "SET 0, A", duration:8,set_0_a),
            Instruction(opCode: 0xC8, length: 1, name: "SET 1, B", duration:8,set_1_b),
            Instruction(opCode: 0xC9, length: 1, name: "SET 1, C", duration:8,set_1_c),
            Instruction(opCode: 0xCA, length: 1, name: "SET 1, D", duration:8,set_1_d),
            Instruction(opCode: 0xCB, length: 1, name: "SET 1, E", duration:8,set_1_e),
            Instruction(opCode: 0xCC, length: 1, name: "SET 1, H", duration:8,set_1_h),
            Instruction(opCode: 0xCD, length: 1, name: "SET 1, L", duration:8,set_1_l),
            Instruction(opCode: 0xCE, length: 1, name: "SET 1, (HL)", duration:16,set_1_hlp),
            Instruction(opCode: 0xCF, length: 1, name: "SET 1, A", duration:8,set_1_a),
            Instruction(opCode: 0xD0, length: 1, name: "SET 2, B", duration:8,set_2_b),
            Instruction(opCode: 0xD1, length: 1, name: "SET 2, C", duration:8,set_2_c),
            Instruction(opCode: 0xD2, length: 1, name: "SET 2, D", duration:8,set_2_d),
            Instruction(opCode: 0xD3, length: 1, name: "SET 2, E", duration:8,set_2_e),
            Instruction(opCode: 0xD4, length: 1, name: "SET 2, H", duration:8,set_2_h),
            Instruction(opCode: 0xD5, length: 1, name: "SET 2, L", duration:8,set_2_l),
            Instruction(opCode: 0xD6, length: 1, name: "SET 2, (HL)", duration:16,set_2_hlp),
            Instruction(opCode: 0xD7, length: 1, name: "SET 2, A", duration:8,set_2_a),
            Instruction(opCode: 0xD8, length: 1, name: "SET 3, B", duration:8,set_3_b),
            Instruction(opCode: 0xD9, length: 1, name: "SET 3, C", duration:8,set_3_c),
            Instruction(opCode: 0xDA, length: 1, name: "SET 3, D", duration:8,set_3_d),
            Instruction(opCode: 0xDB, length: 1, name: "SET 3, E", duration:8,set_3_e),
            Instruction(opCode: 0xDC, length: 1, name: "SET 3, H", duration:8,set_3_h),
            Instruction(opCode: 0xDD, length: 1, name: "SET 3, L", duration:8,set_3_l),
            Instruction(opCode: 0xDE, length: 1, name: "SET 3, (HL)", duration:16,set_3_hlp),
            Instruction(opCode: 0xDF, length: 1, name: "SET 3, A", duration:8,set_3_a),
            Instruction(opCode: 0xE0, length: 1, name: "SET 4, B", duration:8,set_4_b),
            Instruction(opCode: 0xE1, length: 1, name: "SET 4, C", duration:8,set_4_c),
            Instruction(opCode: 0xE2, length: 1, name: "SET 4, D", duration:8,set_4_d),
            Instruction(opCode: 0xE3, length: 1, name: "SET 4, E", duration:8,set_4_e),
            Instruction(opCode: 0xE4, length: 1, name: "SET 4, H", duration:8,set_4_h),
            Instruction(opCode: 0xE5, length: 1, name: "SET 4, L", duration:8,set_4_l),
            Instruction(opCode: 0xE6, length: 1, name: "SET 4, (HL)", duration:16,set_4_hlp),
            Instruction(opCode: 0xE7, length: 1, name: "SET 4, A", duration:8,set_4_a),
            Instruction(opCode: 0xE8, length: 1, name: "SET 5, B", duration:8,set_5_b),
            Instruction(opCode: 0xE9, length: 1, name: "SET 5, C", duration:8,set_5_c),
            Instruction(opCode: 0xEA, length: 1, name: "SET 5, D", duration:8,set_5_d),
            Instruction(opCode: 0xEB, length: 1, name: "SET 5, E", duration:8,set_5_e),
            Instruction(opCode: 0xEC, length: 1, name: "SET 5, H", duration:8,set_5_h),
            Instruction(opCode: 0xED, length: 1, name: "SET 5, L", duration:8,set_5_l),
            Instruction(opCode: 0xEE, length: 1, name: "SET 5, (HL)", duration:16,set_5_hlp),
            Instruction(opCode: 0xEF, length: 1, name: "SET 5, A", duration:8,set_5_a),
            Instruction(opCode: 0xF0, length: 1, name: "SET 6, B", duration:8,set_6_b),
            Instruction(opCode: 0xF1, length: 1, name: "SET 6, C", duration:8,set_6_c),
            Instruction(opCode: 0xF2, length: 1, name: "SET 6, D", duration:8,set_6_d),
            Instruction(opCode: 0xF3, length: 1, name: "SET 6, E", duration:8,set_6_e),
            Instruction(opCode: 0xF4, length: 1, name: "SET 6, H", duration:8,set_6_h),
            Instruction(opCode: 0xF5, length: 1, name: "SET 6, L", duration:8,set_6_l),
            Instruction(opCode: 0xF6, length: 1, name: "SET 6, (HL)", duration:16,set_6_hlp),
            Instruction(opCode: 0xF7, length: 1, name: "SET 6, A", duration:8,set_6_a),
            Instruction(opCode: 0xF8, length: 1, name: "SET 7, B", duration:8,set_7_b),
            Instruction(opCode: 0xF9, length: 1, name: "SET 7, C", duration:8,set_7_c),
            Instruction(opCode: 0xFA, length: 1, name: "SET 7, D", duration:8,set_7_d),
            Instruction(opCode: 0xFB, length: 1, name: "SET 7, E", duration:8,set_7_e),
            Instruction(opCode: 0xFC, length: 1, name: "SET 7, H", duration:8,set_7_h),
            Instruction(opCode: 0xFD, length: 1, name: "SET 7, L", duration:8,set_7_l),
            Instruction(opCode: 0xFE, length: 1, name: "SET 7, (HL)", duration:16,set_7_hlp),
            Instruction(opCode: 0xFF, length: 1, name: "SET 7, A", duration:8,set_7_a)
        ]
    }
    
    
    // mark: standard instructions set
    
    // n.b if behavior differs from doc, read CPU manual to understand expected behavior
    
    func nop() -> Void {/*do nothing*/}
    func ld_bc_nn(val:EnhancedShort) -> Void { self.registers.BC = val.value }
    func ld_bcp_a() -> Void { mmu.write( address: self.registers.BC, val: self.registers.A) }
    func inc_bc() -> Void { self.registers.BC = self.inc(self.registers.BC) }
    func inc_b() -> Void { self.registers.B = self.inc(self.registers.B) }
    func dec_b() -> Void { self.registers.B = self.dec(self.registers.B) }
    func ld_b_n(val:Byte) -> Void { self.registers.B = val }
    func rlca() -> Void {
        self.registers.A = rl(self.registers.A, circular: true)
        self.registers.clearFlag(.ZERO)//this rl clears Zero flag
    }
    func ld_nnp_sp(address:EnhancedShort) -> Void { mmu.write(address: address.value, val: self.registers.SP) }
    func add_hl_bc() -> Void { self.add_hl(self.registers.BC) }
    func ld_a_bcp() -> Void { self.registers.A = mmu.read(address: self.registers.BC) }
    func dec_bc() -> Void { self.registers.BC = self.dec(self.registers.BC) }
    func inc_c() -> Void { self.registers.C = self.inc(self.registers.C) }
    func dec_c() -> Void { self.registers.C = self.dec(self.registers.C) }
    func ld_c_n(val:Byte) -> Void { self.registers.C = val }
    func rrca() -> Void {
        self.registers.A = rr(self.registers.A, circular: true)
        self.registers.clearFlag(.ZERO)//this rr clears Zero flag
    }
    func stop() -> Void { self.state = CPUState.STOPPED }
    func ld_de_nn(val:EnhancedShort) -> Void { self.registers.DE = val.value }
    func ld_dep_a() -> Void { mmu.write(address: self.registers.DE, val: self.registers.A) }
    func inc_de() -> Void { self.registers.DE = self.inc(self.registers.DE) }
    func inc_d() -> Void { self.registers.D = self.inc(self.registers.D) }
    func dec_d() -> Void { self.registers.D = self.dec(self.registers.D) }
    func ld_d_n(val:Byte) -> Void { self.registers.D = val }
    func rla() -> Void {
        self.registers.A = self.rl(self.registers.A)
        self.registers.clearFlag(.ZERO)//this rl clears Zero flag
    }
    func jr_i8(val:Byte) -> Void { jumpRelative(val) }
    func add_hl_de() -> Void { self.add_hl(self.registers.DE) }
    func ld_a_dep() -> Void { self.registers.A = mmu.read(address: self.registers.DE) }
    func dec_de() -> Void { self.registers.DE = self.dec(self.registers.DE) }
    func inc_e() -> Void { self.registers.E = self.inc(self.registers.E) }
    func dec_e() -> Void { self.registers.E = self.dec(self.registers.E) }
    func ld_e_n(val:Byte) -> Void { self.registers.E = val }
    func rra() -> Void {
        self.registers.A = rr(self.registers.A)
        self.registers.clearFlag(.ZERO)//this rr clears Zero flag
    }
    func jr_nz_i8(val:Byte) -> Void { jumpRelative(val, .ZERO, inverseFlag: true) }
    func ld_hl_nn(val:EnhancedShort) -> Void { self.registers.HL = val.value }
    func ld_hlpi_a() -> Void { mmu.write(address: self.registers.HL, val: self.registers.A); self.registers.HL = self.registers.HL&+1 }
    func inc_hl() -> Void { self.registers.HL = self.inc(self.registers.HL) }
    func inc_h() -> Void { self.registers.H = self.inc(self.registers.H) }
    func dec_h() -> Void { self.registers.H = self.dec(self.registers.H) }
    func ld_h_n(val:Byte) -> Void { self.registers.H = val }
    func daa() -> Void { self._daa() }
    func jr_z_i8(val:Byte) -> Void { jumpRelative(val, .ZERO) }
    func add_hl_hl() -> Void { self.add_hl(self.registers.HL) }
    func ld_a_hlpi() -> Void { self.registers.A = mmu.read(address: self.registers.HL); self.registers.HL = self.registers.HL&+1 }
    func dec_hl() -> Void { self.registers.HL = self.dec(self.registers.HL) }
    func inc_l() -> Void { self.registers.L = self.inc(self.registers.L) }
    func dec_l() -> Void { self.registers.L = self.dec(self.registers.L) }
    func ld_l_n(val:Byte) -> Void { self.registers.L = val }
    func cpl() -> Void {
        self.registers.A = flipBits(self.registers.A)
        self.registers.raiseFlag(.NEGATIVE)
        self.registers.raiseFlag(.HALF_CARRY)
    }
    func jr_nc_i8(val:Byte) -> Void { jumpRelative(val, .CARRY, inverseFlag: true) }
    func ld_sp_nn(val:EnhancedShort) -> Void { self.registers.SP = val.value }
    func ld_hlpd_a() -> Void { mmu.write(address: self.registers.HL, val: self.registers.A); self.registers.HL = self.registers.HL&-1 }
    func inc_sp() -> Void { self.registers.SP = self.inc(self.registers.SP) }
    func inc_hlp() -> Void { mmu.write(address: self.registers.HL, val: self.inc(mmu.read(address: self.registers.HL) as Byte)) }
    func dec_hlp() -> Void { mmu.write(address: self.registers.HL, val: self.dec(mmu.read(address: self.registers.HL) as Byte)) }
    func ld_hlp_n(val:Byte) -> Void { mmu.write(address: self.registers.HL, val: val) }
    func scf() -> Void { self.registers.clearFlags(.NEGATIVE,.HALF_CARRY); self.registers.raiseFlag(.CARRY) }
    func jr_c_i8(val:Byte) -> Void { jumpRelative(val, .CARRY) }
    func add_hl_sp() -> Void { self.add_hl(self.registers.SP) }
    func ld_a_hlpd() -> Void { self.registers.A = mmu.read(address: self.registers.HL); self.registers.HL = self.registers.HL&-1 }
    func dec_sp() -> Void { self.registers.SP = self.dec(self.registers.SP) }
    func inc_a() -> Void { self.registers.A = self.inc(self.registers.A) }
    func dec_a() -> Void { self.registers.A = self.dec(self.registers.A) }
    func ld_a_n(val:Byte) -> Void { self.registers.A = val }
    func ccf() -> Void {
        self.registers.clearFlags(.NEGATIVE,.HALF_CARRY);
        self.registers.isFlagSet(.CARRY) ? self.registers.clearFlag(.CARRY) : self.registers.raiseFlag(.CARRY)
    }
    func ld_b_b() -> Void { self.registers.B = self.registers.B }
    func ld_b_c() -> Void { self.registers.B = self.registers.C }
    func ld_b_d() -> Void { self.registers.B = self.registers.D }
    func ld_b_e() -> Void { self.registers.B = self.registers.E }
    func ld_b_h() -> Void { self.registers.B = self.registers.H }
    func ld_b_l() -> Void { self.registers.B = self.registers.L }
    func ld_b_hlp() -> Void { self.registers.B = mmu.read(address: self.registers.HL) }
    func ld_b_a() -> Void { self.registers.B = self.registers.A }
    func ld_c_b() -> Void { self.registers.C = self.registers.B }
    func ld_c_c() -> Void { self.registers.C = self.registers.C }
    func ld_c_d() -> Void { self.registers.C = self.registers.D }
    func ld_c_e() -> Void { self.registers.C = self.registers.E }
    func ld_c_h() -> Void { self.registers.C = self.registers.H }
    func ld_c_l() -> Void { self.registers.C = self.registers.L }
    func ld_c_hlp() -> Void { self.registers.C = mmu.read(address: self.registers.HL) }
    func ld_c_a() -> Void { self.registers.C = self.registers.A }
    func ld_d_b() -> Void { self.registers.D = self.registers.B }
    func ld_d_c() -> Void { self.registers.D = self.registers.C }
    func ld_d_d() -> Void { self.registers.D = self.registers.D }
    func ld_d_e() -> Void { self.registers.D = self.registers.E }
    func ld_d_h() -> Void { self.registers.D = self.registers.H }
    func ld_d_l() -> Void { self.registers.D = self.registers.L }
    func ld_d_hlp() -> Void { self.registers.D = mmu.read(address: self.registers.HL) }
    func ld_d_a() -> Void { self.registers.D = self.registers.A }
    func ld_e_b() -> Void { self.registers.E = self.registers.B }
    func ld_e_c() -> Void { self.registers.E = self.registers.C }
    func ld_e_d() -> Void { self.registers.E = self.registers.D }
    func ld_e_e() -> Void { self.registers.E = self.registers.E }
    func ld_e_h() -> Void { self.registers.E = self.registers.H }
    func ld_e_l() -> Void { self.registers.E = self.registers.L }
    func ld_e_hlp() -> Void { self.registers.E = mmu.read(address: self.registers.HL) }
    func ld_e_a() -> Void { self.registers.E = self.registers.A }
    func ld_h_b() -> Void { self.registers.H = self.registers.B }
    func ld_h_c() -> Void { self.registers.H = self.registers.C }
    func ld_h_d() -> Void { self.registers.H = self.registers.D }
    func ld_h_e() -> Void { self.registers.H = self.registers.E }
    func ld_h_h() -> Void { self.registers.H = self.registers.H }
    func ld_h_l() -> Void { self.registers.H = self.registers.L }
    func ld_h_hlp() -> Void { self.registers.H = mmu.read(address: self.registers.HL) }
    func ld_h_a() -> Void { self.registers.H = self.registers.A }
    func ld_l_b() -> Void { self.registers.L = self.registers.B }
    func ld_l_c() -> Void { self.registers.L = self.registers.C }
    func ld_l_d() -> Void { self.registers.L = self.registers.D }
    func ld_l_e() -> Void { self.registers.L = self.registers.E }
    func ld_l_h() -> Void { self.registers.L = self.registers.H }
    func ld_l_l() -> Void { self.registers.L = self.registers.L }
    func ld_l_hlp() -> Void { self.registers.L = mmu.read(address: self.registers.HL) }
    func ld_l_a() -> Void { self.registers.L = self.registers.A }
    func ld_hlp_b() -> Void { mmu.write(address: self.registers.HL, val: self.registers.B) }
    func ld_hlp_c() -> Void { mmu.write(address: self.registers.HL, val: self.registers.C) }
    func ld_hlp_d() -> Void { mmu.write(address: self.registers.HL, val: self.registers.D) }
    func ld_hlp_e() -> Void { mmu.write(address: self.registers.HL, val: self.registers.E) }
    func ld_hlp_h() -> Void { mmu.write(address: self.registers.HL, val: self.registers.H) }
    func ld_hlp_l() -> Void { mmu.write(address: self.registers.HL, val: self.registers.L) }
    func halt() -> Void { self.state = CPUState.HALTED }
    func ld_hlp_a() -> Void { mmu.write(address: self.registers.HL, val: self.registers.A) }
    func ld_a_b() -> Void { self.registers.A = self.registers.B }
    func ld_a_c() -> Void { self.registers.A = self.registers.C }
    func ld_a_d() -> Void { self.registers.A = self.registers.D }
    func ld_a_e() -> Void { self.registers.A = self.registers.E }
    func ld_a_h() -> Void { self.registers.A = self.registers.H }
    func ld_a_l() -> Void { self.registers.A = self.registers.L }
    func ld_a_hlp() -> Void { self.registers.A = mmu.read(address: self.registers.HL)  }
    func ld_a_a() -> Void { self.registers.A = self.registers.A  }
    func add_a_b() -> Void { self.add_a(self.registers.B) }
    func add_a_c() -> Void { self.add_a(self.registers.C) }
    func add_a_d() -> Void { self.add_a(self.registers.D) }
    func add_a_e() -> Void { self.add_a(self.registers.E) }
    func add_a_h() -> Void { self.add_a(self.registers.H) }
    func add_a_l() -> Void { self.add_a(self.registers.L) }
    func add_a_hlp() -> Void { self.add_a(mmu.read(address: self.registers.HL)) }
    func add_a_a() -> Void { self.add_a(self.registers.A) }
    func adc_a_b() -> Void { self.adc_a(self.registers.B) }
    func adc_a_c() -> Void { self.adc_a(self.registers.C) }
    func adc_a_d() -> Void { self.adc_a(self.registers.D) }
    func adc_a_e() -> Void { self.adc_a(self.registers.E) }
    func adc_a_h() -> Void { self.adc_a(self.registers.H) }
    func adc_a_l() -> Void { self.adc_a(self.registers.L) }
    func adc_a_hlp() -> Void { self.adc_a(mmu.read(address: self.registers.HL)) }
    func adc_a_a() -> Void { self.adc_a(self.registers.A) }
    func sub_a_b() -> Void { self.sub_a(self.registers.B) }
    func sub_a_c() -> Void { self.sub_a(self.registers.C) }
    func sub_a_d() -> Void { self.sub_a(self.registers.D) }
    func sub_a_e() -> Void { self.sub_a(self.registers.E) }
    func sub_a_h() -> Void { self.sub_a(self.registers.H) }
    func sub_a_l() -> Void { self.sub_a(self.registers.L) }
    func sub_a_hlp() -> Void { self.sub_a(mmu.read(address: self.registers.HL)) }
    func sub_a_a() -> Void { self.sub_a(self.registers.A) }
    func sbc_a_b() -> Void { self.sbc_a(self.registers.B) }
    func sbc_a_c() -> Void { self.sbc_a(self.registers.C) }
    func sbc_a_d() -> Void { self.sbc_a(self.registers.D) }
    func sbc_a_e() -> Void { self.sbc_a(self.registers.E) }
    func sbc_a_h() -> Void { self.sbc_a(self.registers.H) }
    func sbc_a_l() -> Void { self.sbc_a(self.registers.L) }
    func sbc_a_hlp() -> Void { self.sbc_a(mmu.read(address: self.registers.HL)) }
    func sbc_a_a() -> Void { self.sbc_a(self.registers.A) }
    func and_a_b() -> Void { self.and_a(self.registers.B) }
    func and_a_c() -> Void { self.and_a(self.registers.C) }
    func and_a_d() -> Void { self.and_a(self.registers.D) }
    func and_a_e() -> Void { self.and_a(self.registers.E) }
    func and_a_h() -> Void { self.and_a(self.registers.H) }
    func and_a_l() -> Void { self.and_a(self.registers.L) }
    func and_a_hlp() -> Void { self.and_a(mmu.read(address: self.registers.HL)) }
    func and_a_a() -> Void { self.and_a(self.registers.A) }
    func xor_a_b() -> Void { self.xor_a(self.registers.B) }
    func xor_a_c() -> Void { self.xor_a(self.registers.C) }
    func xor_a_d() -> Void { self.xor_a(self.registers.D) }
    func xor_a_e() -> Void { self.xor_a(self.registers.E) }
    func xor_a_h() -> Void { self.xor_a(self.registers.H) }
    func xor_a_l() -> Void { self.xor_a(self.registers.L) }
    func xor_a_hlp() -> Void { self.xor_a(mmu.read(address: self.registers.HL)) }
    func xor_a_a() -> Void { self.xor_a(self.registers.A) }
    func or_a_b() -> Void { self.or_a(self.registers.B) }
    func or_a_c() -> Void { self.or_a(self.registers.C) }
    func or_a_d() -> Void { self.or_a(self.registers.D) }
    func or_a_e() -> Void { self.or_a(self.registers.E) }
    func or_a_h() -> Void { self.or_a(self.registers.H) }
    func or_a_l() -> Void { self.or_a(self.registers.L) }
    func or_a_hlp() -> Void { self.or_a(mmu.read(address: self.registers.HL)) }
    func or_a_a() -> Void { self.or_a(self.registers.A) }
    func cp_a_b() -> Void { self.cp_a(self.registers.B) }
    func cp_a_c() -> Void { self.cp_a(self.registers.C) }
    func cp_a_d() -> Void { self.cp_a(self.registers.D) }
    func cp_a_e() -> Void { self.cp_a(self.registers.E) }
    func cp_a_h() -> Void { self.cp_a(self.registers.H) }
    func cp_a_l() -> Void { self.cp_a(self.registers.L) }
    func cp_a_hlp() -> Void { self.cp_a(mmu.read(address: self.registers.HL)) }
    func cp_a_a() -> Void { self.cp_a(self.registers.A) }
    func ret_nz() -> Void { self.retrn(.ZERO, inverseFlag: true) }
    func pop_bc() -> Void { self.registers.BC = self.popFromStack() }
    func jp_nz_nn(address:EnhancedShort) -> Void { jumpTo(address,.ZERO,inverseFlag: true) }
    func jp_nn(address:EnhancedShort) -> Void { jumpTo(address) }
    func call_nz_nn(address:EnhancedShort) -> Void { self.call(address, .ZERO, inverseFlag: true, branchingCycleOverhead: 12) }
    func push_bc() -> Void { self.pushToStack(self.registers.BC) }
    func add_a_n(val:Byte) -> Void { self.add_a(val) }
    func rst_00h() -> Void { self.call(ReservedMemoryLocationAddresses.RESTART_00.rawValue) }
    func ret_z() -> Void { self.retrn(.ZERO) }
    func ret() -> Void { self.retrn() }
    func jp_z_nn(address:EnhancedShort) -> Void { jumpTo(address,.ZERO) }
    func call_z_nn(address:EnhancedShort) -> Void { self.call(address, .ZERO, inverseFlag: false, branchingCycleOverhead: 12) }
    func call_nn(address:EnhancedShort) -> Void { self.call(address) }
    func adc_a_n(val:Byte) -> Void { self.adc_a(val) }
    func rst_08h() -> Void { self.call(ReservedMemoryLocationAddresses.RESTART_08.rawValue) }
    func ret_nc() -> Void { self.retrn(.CARRY, inverseFlag: true) }
    func pop_de() -> Void { self.registers.DE = self.popFromStack() }
    func jp_nc_nn(address:EnhancedShort) -> Void { jumpTo(address,.CARRY,inverseFlag: true) }
    func call_nc_nn(address:EnhancedShort) -> Void { self.call(address, .CARRY, inverseFlag: true, branchingCycleOverhead: 12) }
    func push_de() -> Void { self.pushToStack(self.registers.DE) }
    func sub_a_n(val:Byte) -> Void { self.sub_a(val) }
    func rst_10h() -> Void { self.call(ReservedMemoryLocationAddresses.RESTART_10.rawValue) }
    func ret_c() -> Void { self.retrn(.CARRY) }
    func reti() -> Void {
        self.ret();
        self.e_i(false); /*reti enable directly*/
    }
    func jp_c_nn(address:EnhancedShort) -> Void { jumpTo(address,.CARRY) }
    func call_c_nn(address:EnhancedShort) -> Void { self.call(address, .CARRY, inverseFlag: false, branchingCycleOverhead: 12) }
    func sbc_a_n(val:Byte) -> Void { self.sbc_a(val) }
    func rst_18h() -> Void { self.call(ReservedMemoryLocationAddresses.RESTART_18.rawValue) }
    func ld_ff00pn_a(val:Byte) -> Void { mmu.write(address: 0xFF00+UInt16(val), val: self.registers.A) }
    func pop_hl() -> Void { self.registers.HL = self.popFromStack() }
    func ld_ff00pc_a() -> Void { mmu.write(address: 0xFF00+UInt16(self.registers.C), val: self.registers.A) }
    func push_hl() -> Void { self.pushToStack(self.registers.HL) }
    func and_a_n(val:Byte) -> Void { self.and_a(val) }
    func rst_20h() -> Void { self.call(ReservedMemoryLocationAddresses.RESTART_20.rawValue) }
    func add_sp_i8(val:Byte) -> Void { self.registers.SP = self._add_sp_i8(val: val) }
    func jp_hl() -> Void { self.jumpTo(EnhancedShort(self.registers.HL)) }
    func ld_nnp_a(address:EnhancedShort) -> Void { mmu.write(address: address.value, val: self.registers.A) }
    func xor_a_n(val:Byte) -> Void { self.xor_a(val) }
    func rst_28h() -> Void { self.call(ReservedMemoryLocationAddresses.RESTART_28.rawValue) }
    func ld_a_ff00pn(val:Byte) -> Void { self.registers.A = mmu.read(address: 0xFF00 &+ UInt16(val)) }
    func pop_af() -> Void { self.registers.AF = self.popFromStack() }
    func ld_a_ff00pc() -> Void { self.registers.A = mmu.read(address: 0xFF00 &+ UInt16(self.registers.C)) }
    func di() -> Void { mmu.IME = false }
    func push_af() -> Void { self.pushToStack(self.registers.AF) }
    func or_a_n(val:Byte) -> Void { self.or_a(val) }
    func rst_30h() -> Void { self.call(ReservedMemoryLocationAddresses.RESTART_30.rawValue) }
    func ld_hl_sppi8(val:Byte) -> Void { self.registers.HL = self._add_sp_i8(val: val) /*flags are set according to sp+n so it's ok*/ }
    func ld_sp_hl() -> Void { self.registers.SP = self.registers.HL }
    func ld_a_nnp(address:EnhancedShort) -> Void { self.registers.A = mmu.read(address: address.value) }
    func ei() -> Void { self.e_i(true) }
    func cp_a_n(val:Byte) -> Void { self.cp_a(val) }
    func rst_38h() -> Void { self.call(ReservedMemoryLocationAddresses.RESTART_38.rawValue) }
    
    // mark: extended instruction set
    func rlc_b() -> Void { self.registers.B = self.rl(self.registers.B, circular: true) }
    func rlc_c() -> Void { self.registers.C = self.rl(self.registers.C, circular: true) }
    func rlc_d() -> Void { self.registers.D = self.rl(self.registers.D, circular: true) }
    func rlc_e() -> Void { self.registers.E = self.rl(self.registers.E, circular: true) }
    func rlc_h() -> Void { self.registers.H = self.rl(self.registers.H, circular: true) }
    func rlc_l() -> Void { self.registers.L = self.rl(self.registers.L, circular: true) }
    func rlc_hlp() -> Void { mmu.write(address: self.registers.HL, val: self.rl(mmu.read(address: self.registers.HL),circular: true)) }
    func rlc_a() -> Void { self.registers.A = self.rl(self.registers.A, circular: true) }
    func rrc_b() -> Void { self.registers.B = self.rr(self.registers.B, circular: true) }
    func rrc_c() -> Void { self.registers.C = self.rr(self.registers.C, circular: true) }
    func rrc_d() -> Void { self.registers.D = self.rr(self.registers.D, circular: true) }
    func rrc_e() -> Void { self.registers.E = self.rr(self.registers.E, circular: true) }
    func rrc_h() -> Void { self.registers.H = self.rr(self.registers.H, circular: true) }
    func rrc_l() -> Void { self.registers.L = self.rr(self.registers.L, circular: true) }
    func rrc_hlp() -> Void { mmu.write(address: self.registers.HL, val: self.rr(mmu.read(address: self.registers.HL),circular: true)) }
    func rrc_a() -> Void { self.registers.A = self.rr(self.registers.A, circular: true) }
    func rl_b() -> Void { self.registers.B = self.rl(self.registers.B) }
    func rl_c() -> Void { self.registers.C = self.rl(self.registers.C) }
    func rl_d() -> Void { self.registers.D = self.rl(self.registers.D) }
    func rl_e() -> Void { self.registers.E = self.rl(self.registers.E) }
    func rl_h() -> Void { self.registers.H = self.rl(self.registers.H) }
    func rl_l() -> Void { self.registers.L = self.rl(self.registers.L) }
    func rl_hlp() -> Void { mmu.write(address: self.registers.HL, val: self.rl(mmu.read(address: self.registers.HL))) }
    func rl_a() -> Void { self.registers.A = self.rl(self.registers.A) }
    func rr_b() -> Void { self.registers.B = self.rr(self.registers.B) }
    func rr_c() -> Void { self.registers.C = self.rr(self.registers.C) }
    func rr_d() -> Void { self.registers.D = self.rr(self.registers.D) }
    func rr_e() -> Void { self.registers.E = self.rr(self.registers.E) }
    func rr_h() -> Void { self.registers.H = self.rr(self.registers.H) }
    func rr_l() -> Void { self.registers.L = self.rr(self.registers.L) }
    func rr_hlp() -> Void { mmu.write(address: self.registers.HL, val: self.rr(mmu.read(address: self.registers.HL))) }
    func rr_a() -> Void { self.registers.A = self.rr(self.registers.A) }
    func sla_b() -> Void { self.registers.B = self.sla(self.registers.B) }
    func sla_c() -> Void { self.registers.C = self.sla(self.registers.C) }
    func sla_d() -> Void { self.registers.D = self.sla(self.registers.D) }
    func sla_e() -> Void { self.registers.E = self.sla(self.registers.E) }
    func sla_h() -> Void { self.registers.H = self.sla(self.registers.H) }
    func sla_l() -> Void { self.registers.L = self.sla(self.registers.L) }
    func sla_hlp() -> Void { mmu.write(address: self.registers.HL, val: self.sla(mmu.read(address: self.registers.HL))) }
    func sla_a() -> Void { self.registers.A = self.sla(self.registers.A) }
    func sra_b() -> Void { self.registers.B = self.sra(self.registers.B) }
    func sra_c() -> Void { self.registers.C = self.sra(self.registers.C) }
    func sra_d() -> Void { self.registers.D = self.sra(self.registers.D) }
    func sra_e() -> Void { self.registers.E = self.sra(self.registers.E) }
    func sra_h() -> Void { self.registers.H = self.sra(self.registers.H) }
    func sra_l() -> Void { self.registers.L = self.sra(self.registers.L) }
    func sra_hlp() -> Void { mmu.write(address: self.registers.HL, val: self.sra(mmu.read(address: self.registers.HL))) }
    func sra_a() -> Void { self.registers.A = self.sra(self.registers.A) }
    func swap_b() -> Void { self.registers.B = self.swap(self.registers.B) }
    func swap_c() -> Void { self.registers.C = self.swap(self.registers.C) }
    func swap_d() -> Void { self.registers.D = self.swap(self.registers.D) }
    func swap_e() -> Void { self.registers.E = self.swap(self.registers.E) }
    func swap_h() -> Void { self.registers.H = self.swap(self.registers.H) }
    func swap_l() -> Void { self.registers.L = self.swap(self.registers.L) }
    func swap_hlp() -> Void { mmu.write(address: self.registers.HL, val: self.swap(mmu.read(address: self.registers.HL))) }
    func swap_a() -> Void { self.registers.A = self.swap(self.registers.A) }
    func srl_b() -> Void { self.registers.B = self.srl(self.registers.B) }
    func srl_c() -> Void { self.registers.C = self.srl(self.registers.C) }
    func srl_d() -> Void { self.registers.D = self.srl(self.registers.D) }
    func srl_e() -> Void { self.registers.E = self.srl(self.registers.E) }
    func srl_h() -> Void { self.registers.H = self.srl(self.registers.H) }
    func srl_l() -> Void { self.registers.L = self.srl(self.registers.L) }
    func srl_hlp() -> Void { mmu.write(address: self.registers.HL, val: self.srl(mmu.read(address: self.registers.HL))) }
    func srl_a() -> Void { self.registers.A = self.srl(self.registers.A) }
    func bit_0_b() -> Void { test_bit(.Bit_0, self.registers.B) }
    func bit_0_c() -> Void { test_bit(.Bit_0, self.registers.C) }
    func bit_0_d() -> Void { test_bit(.Bit_0, self.registers.D) }
    func bit_0_e() -> Void { test_bit(.Bit_0, self.registers.E) }
    func bit_0_h() -> Void { test_bit(.Bit_0, self.registers.H) }
    func bit_0_l() -> Void { test_bit(.Bit_0, self.registers.L) }
    func bit_0_hlp() -> Void { test_bit(.Bit_0, mmu.read(address: self.registers.HL)) }
    func bit_0_a() -> Void { test_bit(.Bit_0, self.registers.A) }
    func bit_1_b() -> Void { test_bit(.Bit_1, self.registers.B) }
    func bit_1_c() -> Void { test_bit(.Bit_1, self.registers.C) }
    func bit_1_d() -> Void { test_bit(.Bit_1, self.registers.D) }
    func bit_1_e() -> Void { test_bit(.Bit_1, self.registers.E) }
    func bit_1_h() -> Void { test_bit(.Bit_1, self.registers.H) }
    func bit_1_l() -> Void { test_bit(.Bit_1, self.registers.L) }
    func bit_1_hlp() -> Void { test_bit(.Bit_1, mmu.read(address: self.registers.HL)) }
    func bit_1_a() -> Void { test_bit(.Bit_1, self.registers.A) }
    func bit_2_b() -> Void { test_bit(.Bit_2, self.registers.B) }
    func bit_2_c() -> Void { test_bit(.Bit_2, self.registers.C) }
    func bit_2_d() -> Void { test_bit(.Bit_2, self.registers.D) }
    func bit_2_e() -> Void { test_bit(.Bit_2, self.registers.E) }
    func bit_2_h() -> Void { test_bit(.Bit_2, self.registers.H) }
    func bit_2_l() -> Void { test_bit(.Bit_2, self.registers.L) }
    func bit_2_hlp() -> Void { test_bit(.Bit_2, mmu.read(address: self.registers.HL)) }
    func bit_2_a() -> Void { test_bit(.Bit_2, self.registers.A) }
    func bit_3_b() -> Void { test_bit(.Bit_3, self.registers.B) }
    func bit_3_c() -> Void { test_bit(.Bit_3, self.registers.C) }
    func bit_3_d() -> Void { test_bit(.Bit_3, self.registers.D) }
    func bit_3_e() -> Void { test_bit(.Bit_3, self.registers.E) }
    func bit_3_h() -> Void { test_bit(.Bit_3, self.registers.H) }
    func bit_3_l() -> Void { test_bit(.Bit_3, self.registers.L) }
    func bit_3_hlp() -> Void { test_bit(.Bit_3, mmu.read(address: self.registers.HL)) }
    func bit_3_a() -> Void { test_bit(.Bit_3, self.registers.A) }
    func bit_4_b() -> Void { test_bit(.Bit_4, self.registers.B) }
    func bit_4_c() -> Void { test_bit(.Bit_4, self.registers.C) }
    func bit_4_d() -> Void { test_bit(.Bit_4, self.registers.D) }
    func bit_4_e() -> Void { test_bit(.Bit_4, self.registers.E) }
    func bit_4_h() -> Void { test_bit(.Bit_4, self.registers.H) }
    func bit_4_l() -> Void { test_bit(.Bit_4, self.registers.L) }
    func bit_4_hlp() -> Void { test_bit(.Bit_4, mmu.read(address: self.registers.HL)) }
    func bit_4_a() -> Void { test_bit(.Bit_4, self.registers.A) }
    func bit_5_b() -> Void { test_bit(.Bit_5, self.registers.B) }
    func bit_5_c() -> Void { test_bit(.Bit_5, self.registers.C) }
    func bit_5_d() -> Void { test_bit(.Bit_5, self.registers.D) }
    func bit_5_e() -> Void { test_bit(.Bit_5, self.registers.E) }
    func bit_5_h() -> Void { test_bit(.Bit_5, self.registers.H) }
    func bit_5_l() -> Void { test_bit(.Bit_5, self.registers.L) }
    func bit_5_hlp() -> Void { test_bit(.Bit_5, mmu.read(address: self.registers.HL)) }
    func bit_5_a() -> Void { test_bit(.Bit_5, self.registers.A) }
    func bit_6_b() -> Void { test_bit(.Bit_6, self.registers.B) }
    func bit_6_c() -> Void { test_bit(.Bit_6, self.registers.C) }
    func bit_6_d() -> Void { test_bit(.Bit_6, self.registers.D) }
    func bit_6_e() -> Void { test_bit(.Bit_6, self.registers.E) }
    func bit_6_h() -> Void { test_bit(.Bit_6, self.registers.H) }
    func bit_6_l() -> Void { test_bit(.Bit_6, self.registers.L) }
    func bit_6_hlp() -> Void { test_bit(.Bit_6, mmu.read(address: self.registers.HL)) }
    func bit_6_a() -> Void { test_bit(.Bit_6, self.registers.A) }
    func bit_7_b() -> Void { test_bit(.Bit_7, self.registers.B) }
    func bit_7_c() -> Void { test_bit(.Bit_7, self.registers.C) }
    func bit_7_d() -> Void { test_bit(.Bit_7, self.registers.D) }
    func bit_7_e() -> Void { test_bit(.Bit_7, self.registers.E) }
    func bit_7_h() -> Void { test_bit(.Bit_7, self.registers.H) }
    func bit_7_l() -> Void { test_bit(.Bit_7, self.registers.L) }
    func bit_7_hlp() -> Void { test_bit(.Bit_7, mmu.read(address: self.registers.HL)) }
    func bit_7_a() -> Void { test_bit(.Bit_7, self.registers.A) }
    func res_0_b() -> Void { self.registers.B = clear(.Bit_0, self.registers.B) }
    func res_0_c() -> Void { self.registers.C = clear(.Bit_0, self.registers.C) }
    func res_0_d() -> Void { self.registers.D = clear(.Bit_0, self.registers.D) }
    func res_0_e() -> Void { self.registers.E = clear(.Bit_0, self.registers.E) }
    func res_0_h() -> Void { self.registers.H = clear(.Bit_0, self.registers.H) }
    func res_0_l() -> Void { self.registers.L = clear(.Bit_0, self.registers.L) }
    func res_0_hlp() -> Void { mmu.write(address: self.registers.HL, val: clear(.Bit_0,mmu.read(address: self.registers.HL))) }
    func res_0_a() -> Void { self.registers.A = clear(.Bit_0, self.registers.A) }
    func res_1_b() -> Void { self.registers.B = clear(.Bit_1, self.registers.B) }
    func res_1_c() -> Void { self.registers.C = clear(.Bit_1, self.registers.C) }
    func res_1_d() -> Void { self.registers.D = clear(.Bit_1, self.registers.D) }
    func res_1_e() -> Void { self.registers.E = clear(.Bit_1, self.registers.E) }
    func res_1_h() -> Void { self.registers.H = clear(.Bit_1, self.registers.H) }
    func res_1_l() -> Void { self.registers.L = clear(.Bit_1, self.registers.L) }
    func res_1_hlp() -> Void { mmu.write(address: self.registers.HL, val: clear(.Bit_1,mmu.read(address: self.registers.HL))) }
    func res_1_a() -> Void { self.registers.A = clear(.Bit_1, self.registers.A) }
    func res_2_b() -> Void { self.registers.B = clear(.Bit_2, self.registers.B) }
    func res_2_c() -> Void { self.registers.C = clear(.Bit_2, self.registers.C) }
    func res_2_d() -> Void { self.registers.D = clear(.Bit_2, self.registers.D) }
    func res_2_e() -> Void { self.registers.E = clear(.Bit_2, self.registers.E) }
    func res_2_h() -> Void { self.registers.H = clear(.Bit_2, self.registers.H) }
    func res_2_l() -> Void { self.registers.L = clear(.Bit_2, self.registers.L) }
    func res_2_hlp() -> Void { mmu.write(address: self.registers.HL, val: clear(.Bit_2,mmu.read(address: self.registers.HL))) }
    func res_2_a() -> Void { self.registers.A = clear(.Bit_2, self.registers.A) }
    func res_3_b() -> Void { self.registers.B = clear(.Bit_3, self.registers.B) }
    func res_3_c() -> Void { self.registers.C = clear(.Bit_3, self.registers.C) }
    func res_3_d() -> Void { self.registers.D = clear(.Bit_3, self.registers.D) }
    func res_3_e() -> Void { self.registers.E = clear(.Bit_3, self.registers.E) }
    func res_3_h() -> Void { self.registers.H = clear(.Bit_3, self.registers.H) }
    func res_3_l() -> Void { self.registers.L = clear(.Bit_3, self.registers.L) }
    func res_3_hlp() -> Void { mmu.write(address: self.registers.HL, val: clear(.Bit_3,mmu.read(address: self.registers.HL))) }
    func res_3_a() -> Void { self.registers.A = clear(.Bit_3, self.registers.A) }
    func res_4_b() -> Void { self.registers.B = clear(.Bit_4, self.registers.B) }
    func res_4_c() -> Void { self.registers.C = clear(.Bit_4, self.registers.C) }
    func res_4_d() -> Void { self.registers.D = clear(.Bit_4, self.registers.D) }
    func res_4_e() -> Void { self.registers.E = clear(.Bit_4, self.registers.E) }
    func res_4_h() -> Void { self.registers.H = clear(.Bit_4, self.registers.H) }
    func res_4_l() -> Void { self.registers.L = clear(.Bit_4, self.registers.L) }
    func res_4_hlp() -> Void { mmu.write(address: self.registers.HL, val: clear(.Bit_4,mmu.read(address: self.registers.HL))) }
    func res_4_a() -> Void { self.registers.A = clear(.Bit_4, self.registers.A) }
    func res_5_b() -> Void { self.registers.B = clear(.Bit_5, self.registers.B) }
    func res_5_c() -> Void { self.registers.C = clear(.Bit_5, self.registers.C) }
    func res_5_d() -> Void { self.registers.D = clear(.Bit_5, self.registers.D) }
    func res_5_e() -> Void { self.registers.E = clear(.Bit_5, self.registers.E) }
    func res_5_h() -> Void { self.registers.H = clear(.Bit_5, self.registers.H) }
    func res_5_l() -> Void { self.registers.L = clear(.Bit_5, self.registers.L) }
    func res_5_hlp() -> Void { mmu.write(address: self.registers.HL, val: clear(.Bit_5,mmu.read(address: self.registers.HL))) }
    func res_5_a() -> Void { self.registers.A = clear(.Bit_5, self.registers.A) }
    func res_6_b() -> Void { self.registers.B = clear(.Bit_6, self.registers.B) }
    func res_6_c() -> Void { self.registers.C = clear(.Bit_6, self.registers.C) }
    func res_6_d() -> Void { self.registers.D = clear(.Bit_6, self.registers.D) }
    func res_6_e() -> Void { self.registers.E = clear(.Bit_6, self.registers.E) }
    func res_6_h() -> Void { self.registers.H = clear(.Bit_6, self.registers.H) }
    func res_6_l() -> Void { self.registers.L = clear(.Bit_6, self.registers.L) }
    func res_6_hlp() -> Void { mmu.write(address: self.registers.HL, val: clear(.Bit_6,mmu.read(address: self.registers.HL))) }
    func res_6_a() -> Void { self.registers.A = clear(.Bit_6, self.registers.A) }
    func res_7_b() -> Void { self.registers.B = clear(.Bit_7, self.registers.B) }
    func res_7_c() -> Void { self.registers.C = clear(.Bit_7, self.registers.C) }
    func res_7_d() -> Void { self.registers.D = clear(.Bit_7, self.registers.D) }
    func res_7_e() -> Void { self.registers.E = clear(.Bit_7, self.registers.E) }
    func res_7_h() -> Void { self.registers.H = clear(.Bit_7, self.registers.H) }
    func res_7_l() -> Void { self.registers.L = clear(.Bit_7, self.registers.L) }
    func res_7_hlp() -> Void { mmu.write(address: self.registers.HL, val: clear(.Bit_7,mmu.read(address: self.registers.HL))) }
    func res_7_a() -> Void { self.registers.A = clear(.Bit_7, self.registers.A) }
    func set_0_b() -> Void { self.registers.B = set(.Bit_0, self.registers.B) }
    func set_0_c() -> Void { self.registers.C = set(.Bit_0, self.registers.C) }
    func set_0_d() -> Void { self.registers.D = set(.Bit_0, self.registers.D) }
    func set_0_e() -> Void { self.registers.E = set(.Bit_0, self.registers.E) }
    func set_0_h() -> Void { self.registers.H = set(.Bit_0, self.registers.H) }
    func set_0_l() -> Void { self.registers.L = set(.Bit_0, self.registers.L) }
    func set_0_hlp() -> Void { mmu.write(address: self.registers.HL, val: set(.Bit_0,mmu.read(address: self.registers.HL))) }
    func set_0_a() -> Void { self.registers.A = set(.Bit_0, self.registers.A) }
    func set_1_b() -> Void { self.registers.B = set(.Bit_1, self.registers.B) }
    func set_1_c() -> Void { self.registers.C = set(.Bit_1, self.registers.C) }
    func set_1_d() -> Void { self.registers.D = set(.Bit_1, self.registers.D) }
    func set_1_e() -> Void { self.registers.E = set(.Bit_1, self.registers.E) }
    func set_1_h() -> Void { self.registers.H = set(.Bit_1, self.registers.H) }
    func set_1_l() -> Void { self.registers.L = set(.Bit_1, self.registers.L) }
    func set_1_hlp() -> Void { mmu.write(address: self.registers.HL, val: set(.Bit_1,mmu.read(address: self.registers.HL))) }
    func set_1_a() -> Void { self.registers.A = set(.Bit_1, self.registers.A) }
    func set_2_b() -> Void { self.registers.B = set(.Bit_2, self.registers.B) }
    func set_2_c() -> Void { self.registers.C = set(.Bit_2, self.registers.C) }
    func set_2_d() -> Void { self.registers.D = set(.Bit_2, self.registers.D) }
    func set_2_e() -> Void { self.registers.E = set(.Bit_2, self.registers.E) }
    func set_2_h() -> Void { self.registers.H = set(.Bit_2, self.registers.H) }
    func set_2_l() -> Void { self.registers.L = set(.Bit_2, self.registers.L) }
    func set_2_hlp() -> Void { mmu.write(address: self.registers.HL, val: set(.Bit_2,mmu.read(address: self.registers.HL))) }
    func set_2_a() -> Void { self.registers.A = set(.Bit_2, self.registers.A) }
    func set_3_b() -> Void { self.registers.B = set(.Bit_3, self.registers.B) }
    func set_3_c() -> Void { self.registers.C = set(.Bit_3, self.registers.C) }
    func set_3_d() -> Void { self.registers.D = set(.Bit_3, self.registers.D) }
    func set_3_e() -> Void { self.registers.E = set(.Bit_3, self.registers.E) }
    func set_3_h() -> Void { self.registers.H = set(.Bit_3, self.registers.H) }
    func set_3_l() -> Void { self.registers.L = set(.Bit_3, self.registers.L) }
    func set_3_hlp() -> Void { mmu.write(address: self.registers.HL, val: set(.Bit_3,mmu.read(address: self.registers.HL))) }
    func set_3_a() -> Void { self.registers.A = set(.Bit_3, self.registers.A) }
    func set_4_b() -> Void { self.registers.B = set(.Bit_4, self.registers.B) }
    func set_4_c() -> Void { self.registers.C = set(.Bit_4, self.registers.C) }
    func set_4_d() -> Void { self.registers.D = set(.Bit_4, self.registers.D) }
    func set_4_e() -> Void { self.registers.E = set(.Bit_4, self.registers.E) }
    func set_4_h() -> Void { self.registers.H = set(.Bit_4, self.registers.H) }
    func set_4_l() -> Void { self.registers.L = set(.Bit_4, self.registers.L) }
    func set_4_hlp() -> Void { mmu.write(address: self.registers.HL, val: set(.Bit_4,mmu.read(address: self.registers.HL))) }
    func set_4_a() -> Void { self.registers.A = set(.Bit_4, self.registers.A) }
    func set_5_b() -> Void { self.registers.B = set(.Bit_5, self.registers.B) }
    func set_5_c() -> Void { self.registers.C = set(.Bit_5, self.registers.C) }
    func set_5_d() -> Void { self.registers.D = set(.Bit_5, self.registers.D) }
    func set_5_e() -> Void { self.registers.E = set(.Bit_5, self.registers.E) }
    func set_5_h() -> Void { self.registers.H = set(.Bit_5, self.registers.H) }
    func set_5_l() -> Void { self.registers.L = set(.Bit_5, self.registers.L) }
    func set_5_hlp() -> Void { mmu.write(address: self.registers.HL, val: set(.Bit_5,mmu.read(address: self.registers.HL))) }
    func set_5_a() -> Void { self.registers.A = set(.Bit_5, self.registers.A) }
    func set_6_b() -> Void { self.registers.B = set(.Bit_6, self.registers.B) }
    func set_6_c() -> Void { self.registers.C = set(.Bit_6, self.registers.C) }
    func set_6_d() -> Void { self.registers.D = set(.Bit_6, self.registers.D) }
    func set_6_e() -> Void { self.registers.E = set(.Bit_6, self.registers.E) }
    func set_6_h() -> Void { self.registers.H = set(.Bit_6, self.registers.H) }
    func set_6_l() -> Void { self.registers.L = set(.Bit_6, self.registers.L) }
    func set_6_hlp() -> Void { mmu.write(address: self.registers.HL, val: set(.Bit_6,mmu.read(address: self.registers.HL))) }
    func set_6_a() -> Void { self.registers.A = set(.Bit_6, self.registers.A) }
    func set_7_b() -> Void { self.registers.B = set(.Bit_7, self.registers.B) }
    func set_7_c() -> Void { self.registers.C = set(.Bit_7, self.registers.C) }
    func set_7_d() -> Void { self.registers.D = set(.Bit_7, self.registers.D) }
    func set_7_e() -> Void { self.registers.E = set(.Bit_7, self.registers.E) }
    func set_7_h() -> Void { self.registers.H = set(.Bit_7, self.registers.H) }
    func set_7_l() -> Void { self.registers.L = set(.Bit_7, self.registers.L) }
    func set_7_hlp() -> Void { mmu.write(address: self.registers.HL, val: set(.Bit_7,mmu.read(address: self.registers.HL))) }
    func set_7_a() -> Void { self.registers.A = set(.Bit_7, self.registers.A) }
}
