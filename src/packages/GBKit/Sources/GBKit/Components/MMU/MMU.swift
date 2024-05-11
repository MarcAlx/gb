/**
 * Memory Management Unit
 */
class MMU:Component {
    public static let sharedInstance = MMU()
    
    /// index of the current switchable bank
    private var currentSwitchableBank:Int = 1
    
    /// current cartridge
    public private(set) var currentCartridge:Cartridge = Cartridge()
    
    private let ram:MemoryBank = MemoryBank(size: GBConstants.RAMSize,name: "ram")
        
    private init() {
    }
    
    ///subscript to dispatch address to its corresponding location
    public subscript(address:Short) -> Byte {
        get {
            switch address {
            case IOAddresses.JOYPAD_INPUT.rawValue:
                return 0xFF//TODO read joypad
            case IOAddresses.LCD_STATUS.rawValue:
                return self.ram[address] | 0b1000_0000 //bit 7 is always 1
            //prohibited area, always return 0
            case MMUAddressSpaces.PROHIBITED_AREA:
                return 0x00
            //mirror C000-DDFF (which is 0x2000 behind)
            case MMUAddressSpaces.ECHO_RAM:
                return self.ram[address-0x2000]
            //set ram value
            default:
                return self.ram[address]
            }
        }
        set {
            switch address {
            //mirror C000-DDFF (which is 0x2000 behind)
            case MMUAddressSpaces.ECHO_RAM:
                self.ram[address-0x2000] = newValue
            //prohibited area cannot be set
            case MMUAddressSpaces.PROHIBITED_AREA:
                break
            //bank 0 is read only
            case MMUAddressSpaces.CARTRIDGE_BANK0:
                break
            //switchable bank, switch bank on write
            case MMUAddressSpaces.CARTRIDGE_SWITCHABLE_BANK:
                break//TODO bank switch on write
            //joy pad is not fully W
            case IOAddresses.JOYPAD_INPUT.rawValue:
                //programs often write to 0xFF00 to debounce keys, be sure that the readonly part is not erased in this process.
                
                //bit 7/6 are not used, 5/4 bits are R/W bits 3->0 are read only
                self.ram[address] = (self.ram[address] & 0b1100_1111 /*clear bits 5/4 in ram*/)
                                  | (newValue & 0b0011_0000 /*keep only RW bits of value*/)
                break
            //LCD status first three bits are read only
            case IOAddresses.LCD_STATUS.rawValue:
                self.ram[address] = (self.ram[address] & 0b0000_0111) | (newValue & 0b1111_1000)
                break
            //LYC is update check LYCeqLY flag
            case IOAddresses.LCD_LYC.rawValue:
                IOInterface.sharedInstance.setLCDStatFlag(.LYCeqLY, enabled: newValue == self[IOAddresses.LCD_LY.rawValue])
                self.ram[address] = newValue
                break
            //default to ram
            default:
                self.ram[address] = newValue
            }
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
        self.ram.reset()
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
    
    /// read byte at address without control
    public func directRead(address:Short) -> Byte {
        return self.ram[address]
    }
    
    /// write byte to address without control
    public func directWrite(address:Short, val:Byte) -> Void {
        self.ram[address] = val
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
    
    /// uncontrolled slice read
    public func directRead(range:ClosedRange<Int>) -> ArraySlice<Byte> {
        return self.ram[range]
    }
}
