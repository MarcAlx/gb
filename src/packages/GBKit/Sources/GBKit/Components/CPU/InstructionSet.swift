/// A note on function naming
/// i8 is i8 (signed int)
/// u8 is n
/// u16 is nn
/// + is p
/// Pointers   are suffixed p, (BC) is _bcp_
/// Increments are suffixed i, BD+  is _bci_
/// Decrements are suffixed d, BC-  is _bcd_
/// Pointer increment are suffixed ip and so on... 
/// (HL+) is hlpi (post increment)
/// (HL-) is hlpd (post decrement)
/// ff00pnp is ff00 +(u8)
///
/// misc :
/// (HL-) post decrement HL
/// (HL+) post increment HL


//standard functions
protocol StandardInstructionSet {
    /// no operation, does nothing
    func nop() -> Void
    
    /// loads value into BC
    func ld_bc_nn(val:EnhancedShort) -> Void
    
    /// loads a into address pointed by BC 
    func ld_bcp_a() -> Void
    
    /// increments BC
    func inc_bc() -> Void
    
    /// increments B, clears N, affects HC and Z
    func inc_b() -> Void
    
    /// decrements B, raises N, affects HC and Z
    func dec_b() -> Void
    
    /// loads val into B 
    func ld_b_n(val:Byte) -> Void
    
    /// rotate left A circular
    func rlca() -> Void
    
    /// loads SP into address 
    func ld_nnp_sp(address:EnhancedShort) -> Void
    
    /// adds BC to HL
    func add_hl_bc() -> Void
    
    /// loads value pointed by address at BC in A 
    func ld_a_bcp() -> Void
    
    /// decrements BC 
    func dec_bc() -> Void
    
    /// increments C, clears N, affects HC and Z
    func inc_c() -> Void
    
    /// decrements C, raises N, affects HC and Z 
    func dec_c() -> Void
    
    /// loads val into C
    func ld_c_n(val:Byte) -> Void
    
    /// rotate right A circular
    func rrca() -> Void
    
    /// stop cpu 
    func stop() -> Void
    
    /// loads val into DE 
    func ld_de_nn(val:EnhancedShort) -> Void
    
    /// loads A into address pointed at DE
    func ld_dep_a() -> Void
    
    /// increments DE, clears N, affects HC and Z
    func inc_de() -> Void
    
    /// increments D, clears N, affects HC and Z
    func inc_d() -> Void
    
    /// decrements D, raises N, affects HC and Z 
    func dec_d() -> Void
    
    /// loads val into D 
    func ld_d_n(val:Byte) -> Void
    
    /// rotate left A through carry flag
    func rla() -> Void
    
    /// jump relative by val
    func jr_i8(val:Byte) -> Void
    
    /// adds DE to HL
    func add_hl_de() -> Void
    
    /// loads value pointed by address at DE into A
    func ld_a_dep() -> Void
    
    /// decrements DE 
    func dec_de() -> Void
    
    /// increments E, clears N, affects HC and Z
    func inc_e() -> Void
    
    /// decrements E, raises N, affects HC and Z 
    func dec_e() -> Void
    
    /// loads val into E
    func ld_e_n(val:Byte) -> Void
    
    /// right rotate A through carry flag
    func rra() -> Void
    
    /// jump relative by val if Z flag not set
    func jr_nz_i8(val:Byte) -> Void
    
    /// loads val into HL 
    func ld_hl_nn(val:EnhancedShort) -> Void
    
    /// increments HL then loads A into address pointed by (incremented) HL
    func ld_hlpi_a() -> Void
    
    /// increments address HL
    func inc_hl() -> Void
    
    /// increments H, clears N, affects HC and Z
    func inc_h() -> Void
    
    /// decrements H, raises N, affects HC and Z 
    func dec_h() -> Void
    
    /// loads N into H 
    func ld_h_n(val:Byte) -> Void
    
    /// Decimal Adjust A, replace the contents of A by its BCD value, (in fact it's more Binary Coded Hex, 0x32 -> 0b0011_0010)
    func daa() -> Void
    
    /// jump relative by val if Z flag is set 
    func jr_z_i8(val:Byte) -> Void
    
    /// adds HL to HL
    func add_hl_hl() -> Void
    
    /// increments HL then loads into A value pointed by (incremented) HL 
    func ld_a_hlpi() -> Void
    
    /// decrements HL 
    func dec_hl() -> Void
    
    /// increments L, clears N, affects HC and Z
    func inc_l() -> Void
    
    /// decrements L, raises N, affects HC and Z 
    func dec_l() -> Void
    
    /// load value into L
    func ld_l_n(val:Byte) -> Void
    
    /// complement register A, (flip all bits)
    func cpl() -> Void
    
    /// jump relative by val if NC flags are set 
    func jr_nc_i8(val:Byte) -> Void
    
    /// loads val into SP 
    func ld_sp_nn(val:EnhancedShort) -> Void
    
    /// write A to address pointed by HL, then decrement HL
    func ld_hlpd_a() -> Void
    
    /// increments SP
    func inc_sp() -> Void
    
    /// increments address pointed by HL, clears N, affects HC and Z
    func inc_hlp() -> Void
    
    /// decrements address pointed by HL, raises N, affects HC and Z 
    func dec_hlp() -> Void
    
    /// loads val into address pointed by HL
    func ld_hlp_n(val:Byte) -> Void
    
    /// set carry flag
    func scf() -> Void
    
    /// jump relative by val if C flag is set
    func jr_c_i8(val:Byte) -> Void
    
    /// adds SP to HL
    func add_hl_sp() -> Void
    
    /// loads A with value pointed by HL then decrement HL
    func ld_a_hlpd() -> Void
    
    /// decrements SP 
    func dec_sp() -> Void
    
    /// increments A
    func inc_a() -> Void
    
    /// decrements A, raises N, affects HC and Z 
    func dec_a() -> Void
    
    /// loads N into A
    func ld_a_n(val:Byte) -> Void
    
    /// complement carry flag (toggle it)
    func ccf() -> Void
    
    /// loads B into B (does nothing) 
    func ld_b_b() -> Void
    
    /// loads C into B
    func ld_b_c() -> Void
    
    /// loads D into B
    func ld_b_d() -> Void
    
    /// loads E into B 
    func ld_b_e() -> Void
    
    /// loads H into B
    func ld_b_h() -> Void
    
    /// loads L into B
    func ld_b_l() -> Void
    
    /// loads value pointed by address at HL into B
    func ld_b_hlp() -> Void
    
    /// loads A into B
    func ld_b_a() -> Void
    
    /// loads B into C
    func ld_c_b() -> Void
    
    /// loads C into C (does nothing)
    func ld_c_c() -> Void
    
    /// loads D into C
    func ld_c_d() -> Void
    
    /// loads E into C
    func ld_c_e() -> Void
    
    /// loads H into C
    func ld_c_h() -> Void
    
    /// loads L into C
    func ld_c_l() -> Void
    
    /// loads value pointed by address at HL into C
    func ld_c_hlp() -> Void
    
    /// loads A into C 
    func ld_c_a() -> Void
    
    /// loads B into D
    func ld_d_b() -> Void
    
    /// loads C into D 
    func ld_d_c() -> Void
    
    /// loads D into D (does nothing)
    func ld_d_d() -> Void
    
    /// loads E into D
    func ld_d_e() -> Void
    
    /// loads H into D 
    func ld_d_h() -> Void
    
    /// loads L into D 
    func ld_d_l() -> Void
    
    /// loads value pointed by address at HL into D 
    func ld_d_hlp() -> Void
    
    /// loads A into D 
    func ld_d_a() -> Void
    
    /// loads B into E
    func ld_e_b() -> Void
    
    /// loads C into E
    func ld_e_c() -> Void
    
    /// loads D into E
    func ld_e_d() -> Void
    
    /// loads E into E (does nothing)
    func ld_e_e() -> Void
    
    /// loads H into E
    func ld_e_h() -> Void
    
    /// loads L into E 
    func ld_e_l() -> Void
    
    /// loads value pointed by address at HL into E
    func ld_e_hlp() -> Void
    
    /// loads A into E 
    func ld_e_a() -> Void
    
    /// loads B into H
    func ld_h_b() -> Void
    
    /// loads C into H 
    func ld_h_c() -> Void
    
    /// loads D into H 
    func ld_h_d() -> Void
    
    /// loads E into H 
    func ld_h_e() -> Void
    
    /// loads H into H (does nothing)
    func ld_h_h() -> Void
    
    /// loads L into H
    func ld_h_l() -> Void
    
    /// loads value pointed by address at HL into H
    func ld_h_hlp() -> Void
    
    /// loads A into H
    func ld_h_a() -> Void
    
    /// loads B into L
    func ld_l_b() -> Void
    
    /// loads C into L
    func ld_l_c() -> Void
    
    /// loads D into L
    func ld_l_d() -> Void
    
    /// loads E into L
    func ld_l_e() -> Void
    
    /// loads H into L
    func ld_l_h() -> Void
    
    /// loads L into L (does nothing)
    func ld_l_l() -> Void
    
    /// loads value pointed by address at HL into L
    func ld_l_hlp() -> Void
    
    /// loads A into L 
    func ld_l_a() -> Void
    
    /// loads B into address pointed by value at HL
    func ld_hlp_b() -> Void
    
    /// loads C into address pointed by value at HL
    func ld_hlp_c() -> Void
    
    /// loads D into address pointed by value at HL
    func ld_hlp_d() -> Void
    
    /// loads E into address pointed by value at HL
    func ld_hlp_e() -> Void
    
    /// loads H into address pointed by value at HL
    func ld_hlp_h() -> Void
    
    /// loads L into address pointed by value at HL
    func ld_hlp_l() -> Void
    
    /// pause cpu until next interrupt
    func halt() -> Void
    
    /// loads A into address pointed by value at HL
    func ld_hlp_a() -> Void
    
    /// loads B into A
    func ld_a_b() -> Void
    
    /// loads C into A
    func ld_a_c() -> Void
    
    /// loads D into A
    func ld_a_d() -> Void
    
    /// loads E into A
    func ld_a_e() -> Void
    
    /// loads H into A
    func ld_a_h() -> Void
    
    /// loads L into A
    func ld_a_l() -> Void
    
    /// loads value pointed by address at HL into A
    func ld_a_hlp() -> Void
    
    /// loads A into A (does nothing)
    func ld_a_a() -> Void
    
    /// adds B to A
    func add_a_b() -> Void
    
    /// adds C to A
    func add_a_c() -> Void
    
    /// adds D to A
    func add_a_d() -> Void
    
    /// adds E to A
    func add_a_e() -> Void
    
    /// adds H to A
    func add_a_h() -> Void
    
    /// adds L to A
    func add_a_l() -> Void
    
    /// adds value pointed by address at HL to A
    func add_a_hlp() -> Void
    
    /// adds A to A 
    func add_a_a() -> Void
    
    /// add B to A + carry flag
    func adc_a_b() -> Void
    
    /// add C to A + carry flag 
    func adc_a_c() -> Void
    
    /// add D to A + carry flag 
    func adc_a_d() -> Void
    
    /// add E to A + carry flag 
    func adc_a_e() -> Void
    
    /// add H to A + carry flag 
    func adc_a_h() -> Void
    
    /// add L to A + carry flag 
    func adc_a_l() -> Void
    
    /// add value at HL to A + carry flag 
    func adc_a_hlp() -> Void
    
    /// add A to A + carry flag 
    func adc_a_a() -> Void
    
    /// subs B to A
    func sub_a_b() -> Void
    
    /// subs C to A
    func sub_a_c() -> Void
    
    /// subs D to A
    func sub_a_d() -> Void
    
    /// subs E to A
    func sub_a_e() -> Void
    
    /// subs H to A
    func sub_a_h() -> Void
    
    /// subs L to A
    func sub_a_l() -> Void
    
    /// subs value pointed by address at HL to A
    func sub_a_hlp() -> Void
    
    /// subs A to A
    func sub_a_a() -> Void
    
    /// subs B + carry to A
    func sbc_a_b() -> Void
    
    /// subs C + carry to A 
    func sbc_a_c() -> Void
    
    /// subs D + carry to A
    func sbc_a_d() -> Void
    
    /// subs E + carry to A
    func sbc_a_e() -> Void
    
    /// subs H + carry to A
    func sbc_a_h() -> Void
    
    /// subs L + carry to A
    func sbc_a_l() -> Void
    
    /// subs value pointed by address at HL + carry to A
    func sbc_a_hlp() -> Void
    
    /// subs A + carry to A
    func sbc_a_a() -> Void
    
    /// and B with A
    func and_a_b() -> Void
    
    /// and C with A
    func and_a_c() -> Void
    
    /// and D with A
    func and_a_d() -> Void
    
    /// and E with A
    func and_a_e() -> Void
    
    /// and H with A
    func and_a_h() -> Void
    
    /// and L with A
    func and_a_l() -> Void
    
    /// and value pointed by address at HL with A
    func and_a_hlp() -> Void
    
    /// and A with A
    func and_a_a() -> Void
    
    /// xor A with B and stores result in A
    func xor_a_b() -> Void
    
    /// xor A with C and stores result in A
    func xor_a_c() -> Void
    
    /// xor A with D and stores result in A 
    func xor_a_d() -> Void
    
    /// xor A with E and stores result in A 
    func xor_a_e() -> Void
    
    /// xor A with H and stores result in A 
    func xor_a_h() -> Void
    
    /// xor A with L and stores result in A
    func xor_a_l() -> Void
    
    /// xor A with address pointed by HL and stores result in A
    func xor_a_hlp() -> Void
    
    /// xor A with A and stores result in A
    func xor_a_a() -> Void
    
    /// or B with A
    func or_a_b() -> Void
    
    /// or C with A
    func or_a_c() -> Void
    
    /// or D with A
    func or_a_d() -> Void
    
    /// or E with A 
    func or_a_e() -> Void
    
    /// or H with A
    func or_a_h() -> Void
    
    /// or L with A
    func or_a_l() -> Void
    
    /// or value pointed by address at HL with A
    func or_a_hlp() -> Void
    
    /// or A with A 
    func or_a_a() -> Void
    
    /// compare A with B, result observed in flags 
    func cp_a_b() -> Void
    
    /// compare A with C, result observed in flags 
    func cp_a_c() -> Void
    
    /// compare A with D, result observed in flags 
    func cp_a_d() -> Void
    
    /// compare A with E, result observed in flags 
    func cp_a_e() -> Void
    
    /// compare A with H, result observed in flags 
    func cp_a_h() -> Void
    
    /// compare A with L, result observed in flags 
    func cp_a_l() -> Void
    
    /// compare A with value pointed by address at HL, result observed in flags 
    func cp_a_hlp() -> Void
    
    /// compare A with A, result observed in flags 
    func cp_a_a() -> Void
    
    /// return if Z flag not raised
    func ret_nz() -> Void
    
    /// pop from stack into BC
    func pop_bc() -> Void
    
    /// jump to address if Z not set  
    func jp_nz_nn(address:EnhancedShort) -> Void
    
    /// jump to an address, without condition
    func jp_nn(address:EnhancedShort) -> Void
    
    /// push PC to stack and jump to NN if Z not raised
    func call_nz_nn(address:EnhancedShort) -> Void
    
    /// push BC to stack
    func push_bc() -> Void
    
    /// adds val to A 
    func add_a_n(val:Byte) -> Void
    
    /// push PC to stack then jump to 00, same as call to 0x0000
    func rst_00h() -> Void
    
    /// return if Z flag is raised
    func ret_z() -> Void
    
    /// return 
    func ret() -> Void
    
    /// jump to address if Z is set  
    func jp_z_nn(address:EnhancedShort) -> Void
    
    /// push PC to stack and jump to NN if Z raised
    func call_z_nn(address:EnhancedShort) -> Void
    
    /// push PC to stack and jump to NN
    func call_nn(address:EnhancedShort) -> Void
    
    /// add byte value to A + carry flag  
    func adc_a_n(val:Byte) -> Void
    
    /// push PC to stack then jump to 00, same as call to 0x0008
    func rst_08h() -> Void
    
    /// return if NC flags are raised
    func ret_nc() -> Void
    
    /// pop from stack into DE
    func pop_de() -> Void
    
    /// jump to address if NC are set  
    func jp_nc_nn(address:EnhancedShort) -> Void
    
    /// push PC to stack and jump to NN if C not raised
    func call_nc_nn(address:EnhancedShort) -> Void
    
    /// push DE to stack
    func push_de() -> Void
    
    /// subs N to A 
    func sub_a_n(val:Byte) -> Void
    
    /// push PC to stack then jump to 00, same as call to 0x0010
    func rst_10h() -> Void
    
    /// return if C flag is raised 
    func ret_c() -> Void
    
    /// same as ret + ei (but ei are enabled directly whereas ei())
    func reti() -> Void
    
    /// push PC to stack and jump to NN if C raised
    func jp_c_nn(address:EnhancedShort) -> Void
    
    /// call address nn if C raised
    func call_c_nn(address:EnhancedShort) -> Void
    
    /// subs n + carry to A 
    func sbc_a_n(val:Byte) -> Void
    
    /// push PC to stack then jump to 00, same as call to 0x0018
    func rst_18h() -> Void
    
    /// loads A into address at 0xFF00+val
    func ld_ff00pn_a(val:Byte) -> Void
    
    /// pop from stack into HL
    func pop_hl() -> Void
    
    /// loads A into address at 0xFF00+C
    func ld_ff00pc_a() -> Void
    
    /// push HL to stack
    func push_hl() -> Void
    
    /// and val with A 
    func and_a_n(val:Byte) -> Void
    
    /// push PC to stack then jump to 00, same as call to 0x0020
    func rst_20h() -> Void
    
    /// adds val to sp (can be negative)
    func add_sp_i8(val:Byte) -> Void
    
    /// jump to address designed by HL 
    func jp_hl() -> Void
    
    /// loads A into address
    func ld_nnp_a(address:EnhancedShort) -> Void
    
    /// xor A with byte value and store result in A
    func xor_a_n(val:Byte) -> Void
    
    /// push PC to stack then jump to 00, same as call to 0x0028
    func rst_28h() -> Void
    
    /// read value at (0xFF00 + val) into A
    func ld_a_ff00pn(val:Byte) -> Void
    
    /// pop from stack into AF
    func pop_af() -> Void
    
    /// read value at 0xFF00 + C into A
    func ld_a_ff00pc() -> Void
    
    /// set IME to false (disable interrupts) 
    func di() -> Void
    
    /// push AF 
    func push_af() -> Void
    
    /// or val with A 
    func or_a_n(val:Byte) -> Void
    
    /// push PC to stack then jump to 00, same as call to 0x0030
    func rst_30h() -> Void
    
    /// adds val (can be negative) to SP then load into HL, affect carry anf half carry flags
    func ld_hl_sppi8(val:Byte) -> Void
    
    /// loads HL into SP 
    func ld_sp_hl() -> Void
    
    /// loads value pointed by address into A
    func ld_a_nnp(address:EnhancedShort) -> Void
    
    /// set IME to true (enable interrupts), only enabled after next op executed
    func ei() -> Void
    
    /// compare A with val, result observed in flags 
    func cp_a_n(val:Byte) -> Void
    
    /// push PC to stack then jump to 00, same as call to 0x0038
    func rst_38h() -> Void
}

///Extended Instruction 0xCB
protocol ExtendedInstructionSet{
    /// rotate left B circular
    func rlc_b()
    
    /// rotate left C circular
    func rlc_c()
    
    /// rotate left D circular
    func rlc_d()
    
    /// rotate left E circular
    func rlc_e()
    
    /// rotate left H circular
    func rlc_h()
    
    /// rotate left L circular
    func rlc_l()
    
    /// rotate left value pointed by address at HL circular
    func rlc_hlp()
    
    /// rotate left A circular
    func rlc_a()
    
    /// right rotate circular B
    func rrc_b()
    
    /// right rotate circular C
    func rrc_c()
    
    /// right rotate circular D
    func rrc_d()
    
    /// right rotate circular E
    func rrc_e()
    
    /// right rotate circular H
    func rrc_h()
    
    /// right rotate circular L
    func rrc_l()
    
    /// right rotate circular value pointer by address at HL
    func rrc_hlp()
    
    /// right rotate circular A
    func rrc_a()
    
    /// rotate left B through carry
    func rl_b()
    
    /// rotate left C through carry
    func rl_c()
    
    /// rotate left BDthrough carry
    func rl_d()
    
    /// rotate left E through carry
    func rl_e()
    
    /// rotate left H through carry
    func rl_h()
    
    /// rotate left L through carry
    func rl_l()
    
    /// rotate left value pointed by address at HL through carry
    func rl_hlp()
    
    /// rotate left A through carry
    func rl_a()
    
    /// right rotate B through carry
    func rr_b()
    
    /// right rotate C through carry
    func rr_c()
    
    /// right rotate D through carry
    func rr_d()
    
    /// right rotate E through carry
    func rr_e()
    
    /// right rotate H through carry
    func rr_h()
    
    /// right rotate L through carry
    func rr_l()
    
    /// right rotate value pointer by address at HL through carry
    func rr_hlp()
    
    /// right rotate A through carry
    func rr_a()
    
    /// shift left arithmetic B 
    func sla_b()
    
    /// shift left arithmetic C
    func sla_c()
    
    /// shift left arithmetic D
    func sla_d()
    
    /// shift left arithmetic E
    func sla_e()
    
    /// shift left arithmetic H
    func sla_h()
    
    /// shift left arithmetic L
    func sla_l()
    
    /// shift left arithmetic value pointed at HL and stores back in HL
    func sla_hlp()
    
    /// shift left arithmetic A 
    func sla_a()
    
    /// shift right arithmetic B
    func sra_b()
    
    /// shift right arithmetic C
    func sra_c()
    
    /// shift right arithmetic D
    func sra_d()
    
    /// shift right arithmetic E
    func sra_e()
    
    /// shift right arithmetic H
    func sra_h()
    
    /// shift right arithmetic L
    func sra_l()
    
    /// shift right arithmetic value pointed at HL and stores back in HL
    func sra_hlp()
    
    /// shift right arithmetic A
    func sra_a()
    
    /// swap msb and lsb in B
    func swap_b()
    
    /// swap msb and lsb in C
    func swap_c()
    
    /// swap msb and lsb in D
    func swap_d()
    
    /// swap msb and lsb in E
    func swap_e()
    
    /// swap msb and lsb in H
    func swap_h()
    
    /// swap msb and lsb in L
    func swap_l()
    
    /// swap msb and lsb at address pointed by HL
    func swap_hlp()
    
    /// swap msb and lsb in A
    func swap_a()
    
    /// shift right logical B
    func srl_b()
    
    /// shift right logical C
    func srl_c()
    
    /// shift right logical D
    func srl_d()
    
    /// shift right logical E
    func srl_e()
    
    /// shift right logical H
    func srl_h()
    
    /// shift right logical L
    func srl_l()
    
    /// shift right logical value pointed at HL and stores back in HL
    func srl_hlp()
    
    /// shift right logical A
    func srl_a()
    
    /// test if bit 0 is 0 (res stored in Z) in B
    func bit_0_b()
      
    /// test if bit 0 is 0 (res stored in Z) in C
    func bit_0_c()

    /// test if bit 0 is 0 (res stored in Z) in D
    func bit_0_d()

    /// test if bit 0 is 0 (res stored in Z) in E
    func bit_0_e()

    /// test if bit 0 is 0 (res stored in Z) in H
    func bit_0_h()

    /// test if bit 0 is 0 (res stored in Z) in L
    func bit_0_l()

    /// test if bit 0 is 0 (res stored in Z) in value pointed by HL
    func bit_0_hlp()

    /// test if bit 0 is 0 (res stored in Z) in A
    func bit_0_a()

    /// test if bit 1 is 0 (res stored in Z) in B
    func bit_1_b()

    /// test if bit 1 is 0 (res stored in Z) in C
    func bit_1_c()

    /// test if bit 1 is 0 (res stored in Z) in D
    func bit_1_d()

    /// test if bit 1 is 0 (res stored in Z) in E
    func bit_1_e()

    /// test if bit 1 is 0 (res stored in Z) in H
    func bit_1_h()

    /// test if bit 1 is 0 (res stored in Z) in L
    func bit_1_l()

    /// test if bit 1 is 0 (res stored in Z) in value pointed by HL
    func bit_1_hlp()

    /// test if bit 1 is 0 (res stored in Z) in A
    func bit_1_a()

    /// test if bit 2 is 0 (res stored in Z) in B
    func bit_2_b()

    /// test if bit 2 is 0 (res stored in Z) in C
    func bit_2_c()

    /// test if bit 2 is 0 (res stored in Z) in D
    func bit_2_d()

    /// test if bit 2 is 0 (res stored in Z) in E
    func bit_2_e()

    /// test if bit 2 is 0 (res stored in Z) in H
    func bit_2_h()

    /// test if bit 2 is 0 (res stored in Z) in L
    func bit_2_l()

    /// test if bit 2 is 0 (res stored in Z) in value pointed by HL
    func bit_2_hlp()

    /// test if bit 2 is 0 (res stored in Z) in A
    func bit_2_a()

    /// test if bit 3 is 0 (res stored in Z) in B
    func bit_3_b()

    /// test if bit 3 is 0 (res stored in Z) in C
    func bit_3_c()

    /// test if bit 3 is 0 (res stored in Z) in D
    func bit_3_d()

    /// test if bit 3 is 0 (res stored in Z) in E
    func bit_3_e()

    /// test if bit 3 is 0 (res stored in Z) in H
    func bit_3_h()

    /// test if bit 3 is 0 (res stored in Z) in L
    func bit_3_l()

    /// test if bit 3 is 0 (res stored in Z) in value pointed by HL
    func bit_3_hlp()

    /// test if bit 3 is 0 (res stored in Z) in A
    func bit_3_a()

    /// test if bit 4 is 0 (res stored in Z) in B
    func bit_4_b()

    /// test if bit 4 is 0 (res stored in Z) in C
    func bit_4_c()

    /// test if bit 4 is 0 (res stored in Z) in D
    func bit_4_d()

    /// test if bit 4 is 0 (res stored in Z) in E
    func bit_4_e()

    /// test if bit 4 is 0 (res stored in Z) in H
    func bit_4_h()

    /// test if bit 4 is 0 (res stored in Z) in L
    func bit_4_l()

    /// test if bit 4 is 0 (res stored in Z) in value pointed by HL
    func bit_4_hlp()

    /// test if bit 4 is 0 (res stored in Z) in A
    func bit_4_a()

    /// test if bit 5 is 0 (res stored in Z) in B
    func bit_5_b()

    /// test if bit 5 is 0 (res stored in Z) in C
    func bit_5_c()

    /// test if bit 5 is 0 (res stored in Z) in D
    func bit_5_d()

    /// test if bit 5 is 0 (res stored in Z) in E
    func bit_5_e()

    /// test if bit 5 is 0 (res stored in Z) in H
    func bit_5_h()

    /// test if bit 5 is 0 (res stored in Z) in L
    func bit_5_l()

    /// test if bit 5 is 0 (res stored in Z) in value pointed by HL
    func bit_5_hlp()

    /// test if bit 5 is 0 (res stored in Z) in A
    func bit_5_a()

    /// test if bit 6 is 0 (res stored in Z) in B
    func bit_6_b()

    /// test if bit 6 is 0 (res stored in Z) in C
    func bit_6_c()

    /// test if bit 6 is 0 (res stored in Z) in D
    func bit_6_d()

    /// test if bit 6 is 0 (res stored in Z) in E
    func bit_6_e()

    /// test if bit 6 is 0 (res stored in Z) in H
    func bit_6_h()

    /// test if bit 6 is 0 (res stored in Z) in L
    func bit_6_l()

    /// test if bit 6 is 0 (res stored in Z) in value pointed by HL
    func bit_6_hlp()

    /// test if bit 6 is 0 (res stored in Z) in A
    func bit_6_a()

    /// test if bit 7 is 0 (res stored in Z) in B
    func bit_7_b()

    /// test if bit 7 is 0 (res stored in Z) in C
    func bit_7_c()

    /// test if bit 7 is 0 (res stored in Z) in D
    func bit_7_d()

    /// test if bit 7 is 0 (res stored in Z) in E
    func bit_7_e()

    /// test if bit 7 is 0 (res stored in Z) in H
    func bit_7_h()

    /// test if bit 7 is 0 (res stored in Z) in L
    func bit_7_l()

    /// test if bit 7 is 0 (res stored in Z) in value pointed by HL
    func bit_7_hlp()

    /// test if bit 7 is 0 (res stored in Z) in A
    func bit_7_a()
    
    /// set bit 0 to 0  in B
    func res_0_b()
    
    /// set bit 0 to 0  in C
    func res_0_c()
    
    /// set bit 0 to 0  in D
    func res_0_d()
    
    /// set bit 0 to 0  in E
    func res_0_e()
    
    /// set bit 0 to 0  in H
    func res_0_h()
    
    /// set bit 0 to 0  in L
    func res_0_l()
    
    /// set bit 0 to 0  in value pointed by HL
    func res_0_hlp()
    
    /// set bit 0 to 0 in A
    func res_0_a()
    
    /// set bit 1 to 0 in B
    func res_1_b()
    
    /// set bit 1 to 0 in C
    func res_1_c()
    
    /// set bit 1 to 0 in D
    func res_1_d()
    
    /// set bit 1 to 0 in E
    func res_1_e()
    
    /// set bit 1 to 0 in H
    func res_1_h()
    
    /// set bit 1 to 0 in L
    func res_1_l()
    
    /// set bit 1 to 0 in value pointed by HL
    func res_1_hlp()
    
    /// set bit 1 to 0  in A
    func res_1_a()
    
    /// set bit 2 to 0 in B
    func res_2_b()
    
    /// set bit 2 to 0 in C
    func res_2_c()
    
    /// set bit 2 to 0 in D
    func res_2_d()
    
    /// set bit 2 to 0 in E
    func res_2_e()
    
    /// set bit 2 to 0 in H
    func res_2_h()
    
    /// set bit 2 to 0 in L
    func res_2_l()
    
    /// set bit 2 to 0 in value pointed by HL
    func res_2_hlp()
    
    /// set bit 2 to 0 in A
    func res_2_a()
    
    /// set bit 3 to 0 in B
    func res_3_b()
    
    /// set bit 3 to 0 in C
    func res_3_c()
    
    /// set bit 3 to 0 in D
    func res_3_d()
    
    /// set bit 3 to 0 in E
    func res_3_e()
    
    /// set bit 3 to 0 in H
    func res_3_h()
    
    /// set bit 3 to 0 in L
    func res_3_l()
    
    /// set bit 3 to 0 in value pointed by HL
    func res_3_hlp()
    
    /// set bit 3 to 0 in A
    func res_3_a()
    
    /// set bit 4 to 0 in B
    func res_4_b()
    
    /// set bit 4 to 0 in C
    func res_4_c()
    
    /// set bit 4 to 0 in D
    func res_4_d()
    
    /// set bit 4 to 0 in E
    func res_4_e()
    
    /// set bit 4 to 0 in H
    func res_4_h()
    
    /// set bit 4 to 0 in L
    func res_4_l()
    
    /// set bit 4 to 0 in value pointed by HL
    func res_4_hlp()
    
    /// set bit 4 to 0 in A
    func res_4_a()
    
    /// set bit 5 to 0 in B
    func res_5_b()
    
    /// set bit 5 to 0 in C
    func res_5_c()
    
    /// set bit 5 to 0 in D
    func res_5_d()
    
    /// set bit 5 to 0 in E
    func res_5_e()
    
    /// set bit 5 to 0 in H
    func res_5_h()
    
    /// set bit 5 to 0 in L
    func res_5_l()
    
    /// set bit 5 to 0 in value pointed by HL
    func res_5_hlp()
    
    /// set bit 5 to 0 in A
    func res_5_a()
    
    /// set bit 6 to 0 in B
    func res_6_b()
    
    /// set bit 6 to 0 in C
    func res_6_c()
    
    /// set bit 6 to 0 in D
    func res_6_d()
    
    /// set bit 6 to 0 in E
    func res_6_e()
    
    /// set bit 6 to 0 in H
    func res_6_h()
    
    /// set bit 6 to 0 in L
    func res_6_l()
    
    /// set bit 6 to 0 in value pointed by HL
    func res_6_hlp()
    
    /// set bit 6 to 0 in A
    func res_6_a()
    
    /// set bit 7 to 0 in B
    func res_7_b()
    
    /// set bit 7 to 0 in C
    func res_7_c()
    
    /// set bit 7 to 0 in D
    func res_7_d()
    
    /// set bit 7 to 0 in E
    func res_7_e()
    
    /// set bit 7 to 0 in H
    func res_7_h()
    
    /// set bit 7 to 0 in L
    func res_7_l()
    
    /// set bit 7 to 0 in value pointed by HL
    func res_7_hlp()
    
    /// set bit 7 to 0 in A
    func res_7_a()
    
    /// set bit 0 to 1 in B
    func set_0_b()
        
    /// set bit 0 to 1 in C
    func set_0_c()

    /// set bit 0 to 1 in D
    func set_0_d()

    /// set bit 0 to 1 in E
    func set_0_e()

    /// set bit 0 to 1 in H
    func set_0_h()

    /// set bit 0 to 1 in L
    func set_0_l()

    /// set bit 0 to 1 in value pointed by HL
    func set_0_hlp()

    /// set bit 0 to 1 in A
    func set_0_a()

    /// set bit 1 to 1 in B
    func set_1_b()

    /// set bit 1 to 1 in C
    func set_1_c()

    /// set bit 1 to 1 in D
    func set_1_d()

    /// set bit 1 to 1 in E
    func set_1_e()

    /// set bit 1 to 1 in H
    func set_1_h()

    /// set bit 1 to 1 in L
    func set_1_l()

    /// set bit 1 to 1 in value pointed by HL
    func set_1_hlp()

    /// set bit 1 to 1 in A
    func set_1_a()

    /// set bit 2 to 1 in B
    func set_2_b()

    /// set bit 2 to 1 in C
    func set_2_c()

    /// set bit 2 to 1 in D
    func set_2_d()

    /// set bit 2 to 1 in E
    func set_2_e()

    /// set bit 2 to 1 in H
    func set_2_h()

    /// set bit 2 to 1 in L
    func set_2_l()

    /// set bit 2 to 1 in value pointed by HL
    func set_2_hlp()

    /// set bit 2 to 1 in A
    func set_2_a()

    /// set bit 3 to 1 in B
    func set_3_b()

    /// set bit 3 to 1 in C
    func set_3_c()

    /// set bit 3 to 1 in D
    func set_3_d()

    /// set bit 3 to 1 in E
    func set_3_e()

    /// set bit 3 to 1 in H
    func set_3_h()

    /// set bit 3 to 1 in L
    func set_3_l()

    /// set bit 3 to 1 in value pointed by HL
    func set_3_hlp()

    /// set bit 3 to 1 in A
    func set_3_a()

    /// set bit 4 to 1 in B
    func set_4_b()

    /// set bit 4 to 1 in C
    func set_4_c()

    /// set bit 4 to 1 in D
    func set_4_d()

    /// set bit 4 to 1 in E
    func set_4_e()

    /// set bit 4 to 1 in H
    func set_4_h()

    /// set bit 4 to 1 in L
    func set_4_l()

    /// set bit 4 to 1 in value pointed by HL
    func set_4_hlp()

    /// set bit 4 to 1 in A
    func set_4_a()

    /// set bit 5 to 1 in B
    func set_5_b()

    /// set bit 5 to 1 in C
    func set_5_c()

    /// set bit 5 to 1 in D
    func set_5_d()

    /// set bit 5 to 1 in E
    func set_5_e()

    /// set bit 5 to 1 in H
    func set_5_h()

    /// set bit 5 to 1 in L
    func set_5_l()

    /// set bit 5 to 1 in value pointed by HL
    func set_5_hlp()

    /// set bit 5 to 1 in A
    func set_5_a()

    /// set bit 6 to 1 in B
    func set_6_b()

    /// set bit 6 to 1 in C
    func set_6_c()

    /// set bit 6 to 1 in D
    func set_6_d()

    /// set bit 6 to 1 in E
    func set_6_e()

    /// set bit 6 to 1 in H
    func set_6_h()

    /// set bit 6 to 1 in L
    func set_6_l()

    /// set bit 6 to 1 in value pointed by HL
    func set_6_hlp()

    /// set bit 6 to 1 in A
    func set_6_a()

    /// set bit 7 to 1 in B
    func set_7_b()

    /// set bit 7 to 1 in C
    func set_7_c()

    /// set bit 7 to 1 in D
    func set_7_d()

    /// set bit 7 to 1 in E
    func set_7_e()

    /// set bit 7 to 1 in H
    func set_7_h()

    /// set bit 7 to 1 in L
    func set_7_l()

    /// set bit 7 to 1 in value pointed by HL
    func set_7_hlp()

    /// set bit 7 to 1 in A
    func set_7_a()
}

protocol GameBoyInstructionSet: StandardInstructionSet, ExtendedInstructionSet {
}
