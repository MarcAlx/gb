/**
 * Memory Management Unit
 */
class MMU:Component {
    public static let sharedInstance = MMU()
    
    /// index of the current switchable bank
    private var currentSwitchableBank:Int = 1
    
   /* /// work ram
    private var wram:MemoryBank = MemoryBank(size: WRAMBankSize,name: "wram")
    
    /// switchable work ram
    private var swram:MemoryBank = MemoryBank(size: WRAMBankSize,name: "swram")
    
    /// ios bus
    private var ios:MemoryBank = MemoryBank(size: Int(MMUAddresses.IO_REGISTERS_END.rawValue - MMUAddresses.IO_REGISTERS.rawValue) + 1,name: "ios")
    
    /// video ram
    private var vram:MemoryBank = MemoryBank(size: Int(MMUAddresses.VIDEO_RAM_END.rawValue - MMUAddresses.VIDEO_RAM.rawValue) + 1, name: "vram")
    
    /// high ram
    private var hram:MemoryBank = MemoryBank(size: Int(MMUAddresses.HIGH_RAM_END.rawValue - MMUAddresses.HIGH_RAM.rawValue)  + 1,name: "hram")*/
    
    /// current cartridge
    private var currentCartridge:Cartridge = Cartridge()
    
    private let ram:MemoryBank = MemoryBank(size: RAMSize,name: "ram")
        
    private init() {
    }
    
    var IF:Byte = 0
    var IE:Byte = 0
    ///subscript to dispatch address to its corresponding location
    public subscript(address:Short) -> Byte {
        get {
            return self.ram[address]
            /*switch address {
            case MMuAddressSpaces.CARTRIDGE_BANK0:
                return self.currentCartridge.banks[0][address]
            case MMuAddressSpaces.CARTRIDGE_SWITCHABLE_BANK:
                return self.currentCartridge.banks[self.currentSwitchableBank][address - MMUAddresses.CARTRIDGE_BANK0_END.rawValue]
            case MMuAddressSpaces.VIDEO_RAM:
                return self.vram[address - MMUAddresses.VIDEO_RAM.rawValue]
            case MMuAddressSpaces.WORK_RAM:
                return self.wram[address - MMUAddresses.WORK_RAM.rawValue]
            case MMuAddressSpaces.SWITCHABLE_WORK_RAM:
                return self.swram[address - MMUAddresses.SWITCHABLE_WORK_RAM.rawValue]
            case MMuAddressSpaces.IO_REGISTERS:
                return self.ios[address - MMUAddresses.IO_REGISTERS.rawValue]
            case MMuAddressSpaces.HIGH_RAM:
                return self.hram[address - MMUAddresses.HIGH_RAM.rawValue]
            case MMUAddresses.INTERRUPT_FLAG_REGISTER.rawValue:
                return self.IF//self.motherboard.interrupts.IF
            case MMUAddresses.INTERRUPT_ENABLE_REGISTER.rawValue:
                return self.IE//self.motherboard.interrupts.IE
            default:
                //by default return 0
                return 0
            }*/
        }
        set {
            self.ram[address] = newValue
            /*return
            switch address {
            case MMuAddressSpaces.CARTRIDGE_BANK0:
                //throw errors.readOnlyMemoryLocation(address: address)
                //do nothing read only
                break;
            case MMuAddressSpaces.CARTRIDGE_SWITCHABLE_BANK:
                //throw errors.readOnlyMemoryLocation(address: address)
                //do nothing read only
                break;
            case MMuAddressSpaces.VIDEO_RAM:
                self.vram[address - MMUAddresses.VIDEO_RAM.rawValue] = newValue
            case MMuAddressSpaces.WORK_RAM:
                self.wram[address - MMUAddresses.WORK_RAM.rawValue] = newValue
            case MMuAddressSpaces.SWITCHABLE_WORK_RAM:
                self.swram[address - MMUAddresses.SWITCHABLE_WORK_RAM.rawValue] = newValue
            case MMuAddressSpaces.IO_REGISTERS:
                self.ios[address - MMUAddresses.IO_REGISTERS.rawValue] = newValue
            case MMuAddressSpaces.HIGH_RAM:
                self.hram[address - MMUAddresses.HIGH_RAM.rawValue] = newValue
            case MMUAddresses.INTERRUPT_FLAG_REGISTER.rawValue:
                self.IF = newValue//self.motherboard.interrupts.IF = newValue
            case MMUAddresses.INTERRUPT_ENABLE_REGISTER.rawValue:
                self.IE = newValue// self.motherboard.interrupts.IE = newValue
            default:
                //unsupported memory location, report
                ErrorService.report(error: errors.unsupportedMemoryLocation(address: address))
                break;
            }*/
        }
    }
    
    /// load cartridge inside MMU, n.b it's not done like that in reality
    public func loadCartridge(cartridge:Cartridge){
        self.currentCartridge = cartridge
        self.ram.load(bank: cartridge.banks[0], at: Int(MMUAddresses.CARTRIDGE_BANK0.rawValue))
        self.ram.load(bank: cartridge.banks[1], at: Int(MMUAddresses.CARTRIDGE_SWITCHABLE_BANK.rawValue))
    }
    
    public func reset() {
        self.currentSwitchableBank = 1
        //todo init memory with default value
    }
    
    /// read byte at address
    public func read(address:Short) -> Byte {
        return self[address]
    }
    
    /// read short at address (lsb) and address+1 (msb)
    public func read(address:Short) -> Short {
        let lsb:Byte = self.read(address: address)
        let msb:Byte = self.read(address: address+1)
        return merge(msb, lsb)
    }
    
    /// write byte to address
    public func write(address:Short, val:Byte) -> Void {
        self[address] = val
    }
    
    /// write short to address (lsb at address, msb at address+1
    public func write(address:Short, val:EnhancedShort) -> Void {
        self.write(address: address, val: val.lsb)
        self.write(address: address+1, val: val.msb)
    }
    
    /// write short to address (lsb at address, msb at address+1
    public func write(address:Short, val:Short) -> Void {
        self.write(address: address, val: EnhancedShort(val))
    }
}
