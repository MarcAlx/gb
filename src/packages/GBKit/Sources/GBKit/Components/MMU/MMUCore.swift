/**
 * Memory Management Unit
 */
public class MMUCore:Component, Clockable {
    public var cycles: Int = 0
    
    /// index of the current switchable bank
    private var currentSwitchableBank:Int = 1
    
    /// current cartridge
    public private(set) var currentCartridge:Cartridge = Cartridge()
    
    private let ram:MemoryBank = MemoryBank(size: GBConstants.RAMSize,name: "ram")
        
    /// tick counter for dma period
    private var dmaCounter: Int = 0
    
    private var currentDMATransferRange: ClosedRange<Int> = MMUAddressSpacesInt.OBJECT_ATTRIBUTE_MEMORY
    
    /// true if dma transfer is currently in progress
    public var isDMATransferInProgress: Bool {
        get {
            return self.dmaCounter > 0
        }
    }
    
    ///stores current buttons state, should be updated by JoyPad
    var buttonsState:Byte = 0
    
    ///stores current dpad state, should be updated by JoyPad
    var dpadState:Byte = 0
    
    ///length timers for each APU channels, holds inside MMU to avoid having an APU reference inside MMU
    var lengthTimers:[Int] = GBConstants.DefaultLengthTimer

    public init(){
    }
    
    public func tick(_ masterCycles: Int, _ frameCycles: Int) {
        if(isDMATransferInProgress){
            self.dmaCounter = self.dmaCounter - GBConstants.MCycleLength
        }
        self.cycles = self.cycles &+ GBConstants.MCycleLength
    }
    
    ///subscript to dispatch address to its corresponding location
    public subscript(address:Short) -> Byte {
        get {
            //during DMA transfer conflicts occurs if transfer source or dest (always OAM) is accessed while being wrote
            if(self.isDMATransferInProgress
            && (self.currentDMATransferRange.contains(Int(address))
                || MMUAddressSpaces.OBJECT_ATTRIBUTE_MEMORY.contains(address))){
                return 0xFF
            }
            
            switch address {
            case IOAddresses.JOYPAD_INPUT.rawValue:
                let joy1 = self.ram[address]
                //buttons
                if(isBitCleared(.Bit_5, joy1)){
                    return joy1 & buttonsState
                }
                //dpad
                else if(isBitCleared(.Bit_4, joy1)){
                    return joy1 & dpadState
                }
                else {
                    //lower nible -> 0xF
                    return joy1 & ButtonModifiers.ALL_RELEASED.rawValue
                }
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
            //during DMA transfer conflicts occurs if transfer dest (always OAM) is accessed while being wrote
            if(self.isDMATransferInProgress
            && MMUAddressSpaces.OBJECT_ATTRIBUTE_MEMORY.contains(address)) {
                return
            }
            
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
            //dma transfer start
            case IOAddresses.LCD_DMA.rawValue:
                self.startDMATransfer(start: newValue)
                break;
            //writing to DIV resets it to 0x00
            case IOAddresses.DIV.rawValue:
                self.ram[address] = 0;
                break;
            //LCD status first three bits are read only
            case IOAddresses.LCD_STATUS.rawValue:
                self.ram[address] = (self.ram[address] & 0b0000_0111) //keep 3 lower bits untouched
                                  | (newValue & 0b1111_1000)          //only writes other bits
                break
            //LYC is update check LYCeqLY flag
            case IOAddresses.LCD_LYC.rawValue:
                self.onLYCSet(newValue)
                self.ram[address] = newValue
                break
            //updating NR11 must init length timer for channel 1
            case IOAddresses.AUDIO_NR11.rawValue:
                self.initLengthTimer(AudioChannelId.CH1, newValue)
                self.ram[address] = newValue
                break
            //updating NR21 must init length timer for channel 2
            case IOAddresses.AUDIO_NR21.rawValue:
                self.initLengthTimer(AudioChannelId.CH2, newValue)
                self.ram[address] = newValue
                break
                //updating NR31 must init length timer for channel 3
            case IOAddresses.AUDIO_NR31.rawValue:
                self.initLengthTimer(AudioChannelId.CH3, newValue)
                self.ram[address] = newValue
                break
            //updating NR41 must init length timer for channel 4
            case IOAddresses.AUDIO_NR41.rawValue:
                self.initLengthTimer(AudioChannelId.CH4, newValue)
                self.ram[address] = newValue
                break
            //only bit 7 of NR52 is R/W
            case IOAddresses.AUDIO_NR41.rawValue:
                self.ram[address] = self.ram[address] & NegativeByteMask.Bit_7.rawValue // clear actual bit 7
                                  | newValue & ByteMask.Bit_7.rawValue                  // keep only bit 7 of new value
                break
            //default to ram
            default:
                self.ram[address] = newValue
            }
        }
    }
    
    ///called everytime LYC is updated
    func onLYCSet(_ newVal: Byte)
    {
        
    }
    
    /// load cartridge inside MMU, n.b it's not done like that in reality
    public func loadCartridge(cartridge:Cartridge){
        self.currentCartridge = cartridge
        self.ram.load(bank: cartridge.banks[0], at: Int(MMUAddresses.CARTRIDGE_BANK0.rawValue))
        self.ram.load(bank: cartridge.banks[1], at: Int(MMUAddresses.CARTRIDGE_SWITCHABLE_BANK.rawValue))
    }
    
    public func reset() {
        self.cycles = 0
        self.currentSwitchableBank = 1
        self.dmaCounter = 0
        self.currentDMATransferRange = MMUAddressSpacesInt.OBJECT_ATTRIBUTE_MEMORY
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
    
    /// uncontroled read short at address (lsb) and address+1 (msb)
    public func directRead(address:Short) -> Short {
        let lsb:Byte = self.ram[address]
        let msb:Byte = self.ram[address+1]
        return merge(msb, lsb)
    }
    
    /// write byte to address without control
    public func directWrite(address:Short, val:Byte) -> Void {
        self.ram[address] = val
    }
    
    /// direct write short to address without control
    public func directWrite(address:Short, val:EnhancedShort) -> Void {
        self.ram[address] = val.lsb
        self.ram[address+1] = val.msb
    }
    
    /// direct write short to address (lsb at address, msb at address+1
    public func directWrite(address:Short, val:Short) -> Void {
        self.write(address: address, val: EnhancedShort(val))
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
    
    /// starts DMA transfer from 0xXX00 -> 0xXX9F to 0xFE00 -> 0xFE9F where XX is the provided byte
    /// XX must be between 0x00 and 0xDF
    private func startDMATransfer(start:Byte) -> Void {
        let sourceRadix:Int = Int(start) * 0x100//shift input byte
        let sourceRange = sourceRadix...(sourceRadix+0x9F)
        self.ram[MMUAddressSpacesInt.OBJECT_ATTRIBUTE_MEMORY] = self.ram[sourceRange]
        self.dmaCounter = GBConstants.DMADuration
        self.currentDMATransferRange = sourceRange
    }
    
    /// initis length timer for a given channel using value from an NRX1 register
    private func initLengthTimer(_ channel: AudioChannelId, _ nrx1Value:Byte){
        //get channel index
        let chIdx:Int = AudioChannelId.CH1.rawValue;
        //timer is set to Default values minus masked part of nrx1 value
        self.lengthTimers[chIdx] = GBConstants.DefaultLengthTimer[chIdx]
                                 - Int((nrx1Value & GBConstants.NRX1_lengthMask[chIdx]))
    }
}
