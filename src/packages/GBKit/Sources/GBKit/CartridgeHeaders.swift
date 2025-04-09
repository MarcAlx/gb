/**
 * Compute ROM size from a byte got from header byte
 * - parametery byte : input
 * - returns size in KiB
 */
private func computeROMSizeFromHeaderByte(byte:Byte) -> Int {
    return 32 * (1 << byte)
}

/**
 * Compute RAM size from a byte got from header byte
 * - parametery byte : input
 * - returns size in KiB
 */
private func computeRAMSizeFromHeaderByte(byte:Byte) -> Int {
    switch(byte) {
    case 0x02:
        return 8
    case 0x03:
        return 32
    case 0x04:
        return 128
    case 0x05:
        return 64
    default:
        return 0
    }
}

/**
 * compute header checksum from cartridge data
 */
private func computeHeaderChecksum(data:[Byte]) -> Byte {
    var checksum:UInt16 = 0;
    for address in CHAddresses.TITLE.rawValue...CHAddresses.MASK_ROM_VERSION_NUMBER.rawValue {
        checksum += UInt16(~data[address])
    }
    //get lower 8 bits
    return split(checksum).1
}

/**
 * compute cartridge cheksum, from data array, toExclude is an optional array of addresses to exclude
 */
private func computeChecksum(data:[Byte],toExclude:[Int] = []) -> UInt16 {
    var checksum:UInt32 = 0
    for address in 0..<data.count {
        if(!toExclude.contains(address)) {
            checksum += UInt32(data[address])
        }
    }
    //trim to 16 bits
    return UInt16((checksum << 16) >> 16)
}

/**
 * Cartridge header
 */
public class CartridgeHeader {
    public private(set) var title:String = ""
    public private(set) var isNintendoLogoPresent:Bool = false
    public private(set) var manufacturerCode:String? = nil
    public private(set) var cgbFlag:CGBFlag? = nil
    public private(set) var cartridgeType:CartridgeType = CartridgeType.ROM_ONLY
    public private(set) var oldLicenseeCode:Byte = 0
    public private(set) var newLicenseeCode:Byte = 0
    public private(set) var licensee:String? = ""
    public private(set) var romSize:Int = 0
    public private(set) var nbBankInROM:Int = 0
    public private(set) var ramSize:Int = 0
    public private(set) var nbBankInRAM:Int = 0
    public private(set) var destination:DestinationCode = DestinationCode.OVERSEAS_ONLY
    public private(set) var versionNumber:Byte = 0
    public private(set) var headerChecksum:Byte = 0
    public private(set) var headerChecksumComputed:Byte = 0
    public private(set) var checksum:Short = 0
    public private(set) var checksumComputed:Short = 0
    
    
    public init() {
        
    }
    
    public init(cartridgeData:[Byte]) throws {
        if(cartridgeData.count < CHAddresses.GLOBAL_CHECKSUM_END.rawValue) {
            throw errors.invalidCartridgeSize    
        }
        
        //logo
        self.isNintendoLogoPresent = Array(cartridgeData[CHAddresses.NINTENDO_LOGO.rawValue...CHAddresses.NINTENDO_LOGO_END.rawValue]) == GBConstants.NintendoLogo
        
        //manufacturer code
        let mCode = String(bytes: cartridgeData[CHAddresses.MANUFACTURER_CODE.rawValue...CHAddresses.MANUFACTURER_CODE_END.rawValue], encoding: .ascii)!.trimmingCharacters(in: .whitespaces)
        
        //title is padded on newer cartridge as some of its addresses are used for CGB flag and/or manufacturer code
        var titlePaddingRight:Int = 0
        //mCode is lower than 4 chars when trimmed -> it's an old cartridge that doesn't supports it
        if(mCode.count == 4) {
            self.manufacturerCode = mCode
            titlePaddingRight = 4
        }
        else {
            self.manufacturerCode = nil
        }
        
        //CGB flag
        self.cgbFlag = CGBFlag(rawValue: cartridgeData[CHAddresses.CGB_FLAG_OR_TITLE_END.rawValue])
        
        //cartridge type
        self.cartridgeType = CartridgeType(rawValue: cartridgeData[CHAddresses.CARTRIDGE_TYPE.rawValue])!
        
        //title
        self.title = String(bytes: cartridgeData[CHAddresses.TITLE.rawValue...CHAddresses.CGB_FLAG_OR_TITLE_END.rawValue-titlePaddingRight], encoding: .ascii)!.trimmingCharacters(in: .whitespaces)
        
        //licensee code
        self.oldLicenseeCode = cartridgeData[CHAddresses.OLD_LICENSEE_CODE.rawValue]
        self.newLicenseeCode = cartridgeData[CHAddresses.NEW_LICENSEE_CODE.rawValue]
        if oldLicenseeCode == GBConstants.SwitchToNewLicenseeValue, let l = GBConstants.NewLicenseeCodeLookup[newLicenseeCode] {
            self.licensee = l
        }
        else if let l = GBConstants.OldLicenseeCodeLookup[oldLicenseeCode] {
            self.licensee = l
        }
        else {
            self.licensee = nil
        }
        
        //ROM size
        self.romSize = computeROMSizeFromHeaderByte(byte: cartridgeData[CHAddresses.ROM_SIZE.rawValue])
        self.nbBankInROM = self.romSize/GBConstants.ROMBankSize
        
        //RAM size
        self.ramSize = computeRAMSizeFromHeaderByte(byte: cartridgeData[CHAddresses.RAM_SIZE.rawValue])
        self.nbBankInRAM = self.ramSize/GBConstants.RAMBankSize
        
        //destination
        self.destination = DestinationCode(rawValue: cartridgeData[CHAddresses.DESTINATION_CODE.rawValue])!
   
        //version number
        self.versionNumber = cartridgeData[CHAddresses.MASK_ROM_VERSION_NUMBER.rawValue]
        
        //header checksum
        self.headerChecksum = cartridgeData[CHAddresses.HEADER_CHECKSUM.rawValue]
        self.headerChecksumComputed = computeHeaderChecksum(data: cartridgeData)
        
        // checksum
        self.checksum = merge(cartridgeData[CHAddresses.GLOBAL_CHECKSUM.rawValue], cartridgeData[CHAddresses.GLOBAL_CHECKSUM_END.rawValue])
        self.checksumComputed = computeChecksum(data: cartridgeData,toExclude: [CHAddresses.GLOBAL_CHECKSUM.rawValue,CHAddresses.GLOBAL_CHECKSUM_END.rawValue])
    }
}
