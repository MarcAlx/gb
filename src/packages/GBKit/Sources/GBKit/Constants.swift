import Foundation

public struct GameBoyConstants {
    // CPU speed in hertz
    public let CPUSpeed:Int = 4_194_304

    // length of an M cycle in T cycle, 1 M cycle = 4 T cycles
    public let MCycleLength:Int = 4

    public let ScreenWidth:Int = 160
    public let ScreenHeight:Int = 144
    public let PixelCount:Int

    ///All tile have the same width
    public let TileWidth:UInt8 = 8

    //length of tile in byte
    public let TileLength:UInt8 = 16

    //BG/Win/Normal obj tile height
    public let StandardTileHeight:Byte = 8
    
    //Used for extended Obj tile
    public let LargeTileHeight:Byte = 16
    
    //window has a 7 pixels shift
    public let WinXOffset:Byte = 7
    
    //Obj tiles have an X offset to consider for positionning
    public let ObjXOffset:Byte = 8
    
    //Obj tiles have an Y offset to consider for positioning
    public let ObjYOffset:Int = 16 // Int to avoid useless casting
    
    //number of bytes needed to represent a single tileinfo in OAM
    public let ObjTileInfoSize:Short = 4 //Short to avoid useless casting
    
    //An hardware limite of 10 objects max per line exists
    public let ObjLimitPerLine:Byte = 10

    // Nb of scanline drawn per frame (144 + 10 VBlank)
    public let ScanlinesPerFrame:Int = 154
    // time needed (in M cycles) to render a scanline
    public let MCyclesPerScanline:Int = PPUTimings.OAM_SEARCH_LENGTH.rawValue
                                      + PPUTimings.PIXEL_RENDER_LENGTH.rawValue
                                      + PPUTimings.HBLANK_LENGTH.rawValue

    // MCycles than occurs each frame
    public let MCyclesPerFrame:Int
    
    // DMA transfer duration in T cycles
    public let DMADuration:Int = 640

    // Exact GB frame rate (likely ignored, rounded to 60 by CADisplayLink)
    public let ExactFrameRate:Float

    //duration of a frame expressed in ms
    public let FrameDuration:Float

    //Ram size
    public let RAMSize:Int = 0xFFFF+1

    //opcode to lookup for extended instructions
    public let ExtentedInstructionSetOpcode:Byte = 0xCB
    
    //Div timer frequency in T cycle
    public let DivTimerFrequency:Int = 64;
    
    //APU frame sequencer frequency, 512hz
    public let APUFrameSequencerFrequency:Int = 512
    
    //APU is slower than CPU by this divider
    public let APUSpeedDivider:Int = 2
    
    //Channel with Enveloppe are slower relative to APU
    public let EnveloppeRelativeSpeedDivider:Int = 2
    
    //Speed divider relative to CPU speed
    public let EnveloppeAbsoluteSpeedDivider:Int
    
    //length on an APU frame sequencer step
    public let APUFrameSequencerStepLength:Int
    
    //value used to determine audio channel frequency
    public let APUPeriodDivider:Int = 2048
    
    //duty patterns indexed to their matching NR11 and NR21 value
    public let DutyPatterns:[[Byte]] = [
        [0, 0, 0, 0, 0, 0, 0, 1], //00 -> 12,5%
        [0, 0, 0, 0, 0, 0, 1, 1], //01 -> 25%
        [0, 0, 0, 0, 1, 1, 1, 1], //10 -> 50%
        [1, 1, 1, 1, 1, 1, 0, 0], //11 -> 75%
    ]
    
    //length timer duration (on entry for each channel)
    public let DefaultLengthTimer:[Int] = [
        64,
        64,
        256,//wave channel has longer duration
        64
    ]
    
    //mask for NRX1 register to extract length
    public let NRX1_lengthMask:[Byte] = [
        0b0011_1111,
        0b0011_1111,
        0b1111_1111,///channel 3 takes full 8 bits
        0b0011_1111
    ]
    
    //helps in converting wave 4bits value to effective value
    public let WaveShiftValue:[Int] = [
        4, // 4bits shifted by 4 means 0
        0, // 4bits shifted by 0 means "keep value"
        1, // 4bits shifted by 1 means "divide by 2" (keep 50%)
        2  // 4bits shifted by 2 means "divide by 2 then by 2" (keep 25%)
    ]
    
    //value used to convert Noise divisor code to noise effective divisor
    public let APUNoiseDivisor:[Int] = [
        8,
        16,
        32,
        48,
        64,
        80,
        96,
        112
    ]
    
    //register to control audio channels (trigger / enable length)
    public let AudioChannelControlRegisters:[Short] = [
        IOAddresses.AUDIO_NR14.rawValue,
        IOAddresses.AUDIO_NR24.rawValue,
        IOAddresses.AUDIO_NR34.rawValue,
        IOAddresses.AUDIO_NR44.rawValue
    ]
    
    //register to control enveloppe
    public let EnvelopeControlRegisters:[Short] = [
        IOAddresses.AUDIO_NR12.rawValue,
        IOAddresses.AUDIO_NR22.rawValue,
        //no channel 3 is intentionnal, it doesn't support enveloppe
        IOAddresses.AUDIO_NR42.rawValue,
    ]
    
    //register to control wave duty
    public let WaveDutyRegisters:[Short] = [
        IOAddresses.AUDIO_NR11.rawValue,
        IOAddresses.AUDIO_NR21.rawValue,
        //no channel 3 is intentionnal, it doesn't support wave duty
        //no channel 4 is intentionnal, it doesn't support wave duty
    ]
    
    //register to control period
    public let PeriodRegisters:[Short] = [
        IOAddresses.AUDIO_NR13.rawValue,
        IOAddresses.AUDIO_NR23.rawValue,
        IOAddresses.AUDIO_NR33.rawValue,
        //no channel 4 is intentionnal, it doesn't support period
    ]

    public let NintendoLogo:[Byte] = [
        0xCE, 0xED, 0x66, 0x66, 0xCC, 0x0D, 0x00, 0x0B, 0x03, 0x73, 0x00, 0x83, 0x00, 0x0C, 0x00, 0x0D,
        0x00, 0x08, 0x11, 0x1F, 0x88, 0x89, 0x00, 0x0E, 0xDC, 0xCC, 0x6E, 0xE6, 0xDD, 0xDD, 0xD9, 0x99,
        0xBB, 0xBB, 0x67, 0x63, 0x6E, 0x0E, 0xEC, 0xCC, 0xDD, 0xDC, 0x99, 0x9F, 0xBB, 0xB9, 0x33, 0x3E,
    ]

    ///old licensee code lookup
    public let OldLicenseeCodeLookup:[Byte:String] = [
        0x00 : "None",
        0x01 : "Nintendo",
        0x08 : "Capcom",
        0x09 : "Hot-B",
        0x0A : "Jaleco",
        0x0B : "Coconuts Japan",
        0x0C : "Elite Systems",
        0x13 : "EA (Electronic Arts)",
        0x18 : "Hudsonsoft",
        0x19 : "ITC Entertainment",
        0x1A : "Yanoman",
        0x1D : "Japan Clary",
        0x1F : "Virgin Interactive",
        0x24 : "PCM Complete",
        0x25 : "San-X",
        0x28 : "Kotobuki Systems",
        0x29 : "Seta",
        0x30 : "Infogrames",
        0x31 : "Nintendo",
        0x32 : "Bandai",
        0x33 : "",
        0x34 : "Konami",
        0x35 : "HectorSoft",
        0x38 : "Capcom",
        0x39 : "Banpresto",
        0x3C : ".Entertainment i",
        0x3E : "Gremlin",
        0x41 : "Ubisoft",
        0x42 : "Atlus",
        0x44 : "Malibu",
        0x46 : "Angel",
        0x47 : "Spectrum Holoby",
        0x49 : "Irem",
        0x4A : "Virgin Interactive",
        0x4D : "Malibu",
        0x4F : "U.S. Gold",
        0x50 : "Absolute",
        0x51 : "Acclaim",
        0x52 : "Activision",
        0x53 : "American Sammy",
        0x54 : "GameTek",
        0x55 : "Park Place",
        0x56 : "LJN",
        0x57 : "Matchbox",
        0x59 : "Milton Bradley",
        0x5A : "Mindscape",
        0x5B : "Romstar",
        0x5C : "Naxat Soft",
        0x5D : "Tradewest",
        0x60 : "Titus",
        0x61 : "Virgin Interactive",
        0x67 : "Ocean Interactive",
        0x69 : "EA (Electronic Arts)",
        0x6E : "Elite Systems",
        0x6F : "Electro Brain",
        0x70 : "Infogrames",
        0x71 : "Interplay",
        0x72 : "Broderbund",
        0x73 : "Sculptered Soft",
        0x75 : "The Sales Curve",
        0x78 : "t.hq",
        0x79 : "Accolade",
        0x7A : "Triffix Entertainment",
        0x7C : "Microprose",
        0x7F : "Kemco",
        0x80 : "Misawa Entertainment",
        0x83 : "Lozc",
        0x86 : "Tokuma Shoten Intermedia",
        0x8B : "Bullet-Proof Software",
        0x8C : "Vic Tokai",
        0x8E : "Ape",
        0x8F : "I’Max",
        0x91 : "Chunsoft Co.",
        0x92 : "Video System",
        0x93 : "Tsubaraya Productions Co.",
        0x95 : "Varie Corporation",
        0x96 : "Yonezawa/S’Pal",
        0x97 : "Kaneko",
        0x99 : "Arc",
        0x9A : "Nihon Bussan",
        0x9B : "Tecmo",
        0x9C : "Imagineer",
        0x9D : "Banpresto",
        0x9F : "Nova",
        0xA1 : "Hori Electric",
        0xA2 : "Bandai",
        0xA4 : "Konami",
        0xA6 : "Kawada",
        0xA7 : "Takara",
        0xA9 : "Technos Japan",
        0xAA : "Broderbund",
        0xAC : "Toei Animation",
        0xAD : "Toho",
        0xAF : "Namco",
        0xB0 : "acclaim",
        0xB1 : "ASCII or Nexsoft",
        0xB2 : "Bandai",
        0xB4 : "Square Enix",
        0xB6 : "HAL Laboratory",
        0xB7 : "SNK",
        0xB9 : "Pony Canyon",
        0xBA : "Culture Brain",
        0xBB : "Sunsoft",
        0xBD : "Sony Imagesoft",
        0xBF : "Sammy",
        0xC0 : "Taito",
        0xC2 : "Kemco",
        0xC3 : "Squaresoft",
        0xC4 : "Tokuma Shoten Intermedia",
        0xC5 : "Data East",
        0xC6 : "Tonkinhouse",
        0xC8 : "Koei",
        0xC9 : "UFL",
        0xCA : "Ultra",
        0xCB : "Vap",
        0xCC : "Use Corporation",
        0xCD : "Meldac",
        0xCE : "Pony Canyon or",
        0xCF : "Angel",
        0xD0 : "Taito",
        0xD1 : "Sofel",
        0xD2 : "Quest",
        0xD3 : "Sigma Enterprises",
        0xD4 : "ASK Kodansha Co.",
        0xD6 : "Naxat Soft",
        0xD7 : "Copya System",
        0xD9 : "Banpresto",
        0xDA : "Tomy",
        0xDB : "LJN",
        0xDD : "NCS",
        0xDE : "Human",
        0xDF : "Altron",
        0xE0 : "Jaleco",
        0xE1 : "Towa Chiki",
        0xE2 : "Yutaka",
        0xE3 : "Varie",
        0xE5 : "Epcoh",
        0xE7 : "Athena",
        0xE8 : "Asmik ACE Entertainment",
        0xE9 : "Natsume",
        0xEA : "King Records",
        0xEB : "Atlus",
        0xEC : "Epic/Sony Records",
        0xEE : "IGS",
        0xF0 : "A Wave",
        0xF3 : "Extreme Entertainment",
        0xFF : "LJN"
    ]

    ///old licensee value that indicates that new values must be used
    public let SwitchToNewLicenseeValue:Byte = 0x33

    ///new licensee code lookup
    public let NewLicenseeCodeLookup:[Byte:String] = [
        0x00 : "None",
        0x01 : "Nintendo R&D1",
        0x08 : "Capcom",
        0x13 : "Electronic Arts",
        0x18 : "Hudson Soft",
        0x19 : "b-ai",
        0x20 : "kss",
        0x22 : "pow",
        0x24 : "PCM Complete",
        0x25 : "san-x",
        0x28 : "Kemco Japan",
        0x29 : "seta",
        0x30 : "Viacom",
        0x31 : "Nintendo",
        0x32 : "Bandai",
        0x33 : "Ocean/Acclaim",
        0x34 : "Konami",
        0x35 : "Hector",
        0x37 : "Taito",
        0x38 : "Hudson",
        0x39 : "Banpresto",
        0x41 : "Ubi Soft",
        0x42 : "Atlus",
        0x44 : "Malibu",
        0x46 : "angel",
        0x47 : "Bullet-Proof",
        0x49 : "irem",
        0x50 : "Absolute",
        0x51 : "Acclaim",
        0x52 : "Activision",
        0x53 : "American sammy",
        0x54 : "Konami",
        0x55 : "Hi tech entertainment",
        0x56 : "LJN",
        0x57 : "Matchbox",
        0x58 : "Mattel",
        0x59 : "Milton Bradley",
        0x60 : "Titus",
        0x61 : "Virgin",
        0x64 : "LucasArts",
        0x67 : "Ocean",
        0x69 : "Electronic Arts",
        0x70 : "Infogrames",
        0x71 : "Interplay",
        0x72 : "Broderbund",
        0x73 : "sculptured",
        0x75 : "sci",
        0x78 : "THQ",
        0x79 : "Accolade",
        0x80 : "misawa",
        0x83 : "lozc",
        0x86 : "Tokuma Shoten Intermedia",
        0x87 : "Tsukuda Original",
        0x91 : "Chunsoft",
        0x92 : "Video system",
        0x93 : "Ocean/Acclaim",
        0x95 : "Varie",
        0x96 : "Yonezawa/s’pal",
        0x97 : "Kaneko",
        0x99 : "Pack in soft",
        0xA4 : "Konami (Yu-Gi-Oh!)"
    ]

    /// size of bank in ROM, in KiB
    public let ROMBankSize:Int = 16
    
    /// size of bank in rom in B
    public let ROMBankSizeInBytes:Int

    /// size of bank in ROM, in KiB
    public let RAMBankSize:Int = 8

    /// work RAM  ank size
    let WRAMBankSize:Int = 4096
    
    //M-Cycles at which PIXEL_RENDER starts
    public let PIXEL_RENDER_TRIGGER = PPUTimings.OAM_SEARCH_LENGTH.rawValue
    //M-Cycles at which H-Blank starts
    public let HBLANK_TRIGGER = PPUTimings.OAM_SEARCH_LENGTH.rawValue + PPUTimings.PIXEL_RENDER_LENGTH.rawValue
    //M-Cycles at which V-Blank starts
    public let VBLANK_TRIGGER:Int
    
    public init() {
        self.PixelCount = ScreenWidth * ScreenHeight
        self.MCyclesPerFrame  = ScanlinesPerFrame * MCyclesPerScanline
        self.ExactFrameRate = Float(CPUSpeed) / Float(MCyclesPerFrame)//59.7275
        self.FrameDuration = 1/ExactFrameRate
        self.ROMBankSizeInBytes = ROMBankSize * 1024
        self.VBLANK_TRIGGER = ScreenHeight * MCyclesPerScanline //Vblank is triggered after all line has been rendered
        self.APUFrameSequencerStepLength =  CPUSpeed / APUFrameSequencerFrequency
        self.EnveloppeAbsoluteSpeedDivider = APUSpeedDivider * EnveloppeRelativeSpeedDivider
    }
}

public let GBConstants:GameBoyConstants = GameBoyConstants()

/// Cartridge header addresses
enum CHAddresses: Int /*Int to ease subscripting*/ {
    case ENTRY_POINT             = 0x0100
    case ENTRY_POINT_END         = 0x0103
    case NINTENDO_LOGO           = 0x0104
    case NINTENDO_LOGO_END       = 0x0133
    case TITLE                   = 0x0134
    case MANUFACTURER_CODE       = 0x013F
    case MANUFACTURER_CODE_END   = 0x0142
    case CGB_FLAG_OR_TITLE_END   = 0x0143
    case NEW_LICENSEE_CODE       = 0x0144
    case NEW_LICENSEE_CODE_END   = 0x0145
    case CARTRIDGE_TYPE          = 0x0147
    case ROM_SIZE                = 0x0148
    case RAM_SIZE                = 0x0149
    case DESTINATION_CODE        = 0x014A
    case OLD_LICENSEE_CODE       = 0x014B
    case MASK_ROM_VERSION_NUMBER = 0x014C
    case HEADER_CHECKSUM         = 0x014D
    case GLOBAL_CHECKSUM         = 0x014E
    case GLOBAL_CHECKSUM_END     = 0x014F
}

///Color Gameboy flag
public enum CGBFlag:Byte {
    ///Game is backward compatible with non CGB and provides enhancements for CGB
    case BC_ENHANCED = 0x80
    ///Game only works on CGB
    case CGB_ONLY    = 0xC0
}

///destination code
public enum DestinationCode: Byte {
    ///Game is for Japan and possibly overseas
    case JAPAN_OVERSEAS = 0x00
    ///Game is for overseas only
    case OVERSEAS_ONLY  = 0x01
}

///cartridge type
public enum CartridgeType:Byte {
    case ROM_ONLY                       = 0x00
    case MBC1                           = 0x01
    case MBC1_RAM                       = 0x02
    case MBC1_RAM_BATTERY               = 0x03
    case MBC2                           = 0x05
    case MBC2_BATTERY                   = 0x06
    case ROM_RAM                        = 0x08
    case ROM_RAM_BATTERY                = 0x09
    case MMM01                          = 0x0B
    case MMM01_RAM                      = 0x0C
    case MMM01_RAM_BATTERY              = 0x0D
    case MBC3_TIMER_BATTERY             = 0x0F
    case MBC3_TIMER_RAM_BATTERY         = 0x10
    case MBC3                           = 0x11
    case MBC3_RAM                       = 0x12
    case MBC3_RAM_BATTERY               = 0x13
    case MBC5                           = 0x19
    case MBC5_RAM                       = 0x1A
    case MBC5_RAM_BATTERY               = 0x1B
    case MBC5_RUMBLE                    = 0x1C
    case MBC5_RUMBLE_RAM                = 0x1D
    case MBC5_RUMBLE_RAM_BATTERY        = 0x1E
    case MBC6                           = 0x20
    case MBC7_SENSOR_RUMBLE_RAM_BATTERY = 0x22
    case POCKET_CAMERA                  = 0xFC
    case BANDAI_TAMA5                   = 0xFD
    case HuC3                           = 0xFE
    case HuC1_RAM_BATTERY               = 0xFF
}

public enum ReservedMemoryLocationAddresses : Short {
    case RESTART_00         = 0x0000
    case RESTART_08         = 0x0008
    case RESTART_10         = 0x0010
    case RESTART_18         = 0x0018
    case RESTART_20         = 0x0020
    case RESTART_28         = 0x0028
    case RESTART_30         = 0x0030
    case RESTART_38         = 0x0038
    case INTERRUPT_VBLANK   = 0x0040
    case INTERRUPT_LCD_STAT = 0x0048
    case INTERRUPT_TIMER    = 0x0050
    case INTERRUPT_SERIAL   = 0x0058
    case INTERRUPT_JOYPAD   = 0x0060
}

/// MMU addresses
enum MMUAddresses:Short {
    case CARTRIDGE_BANK0               = 0x0000
    case CARTRIDGE_BANK0_END           = 0x3FFF
    case CARTRIDGE_SWITCHABLE_BANK     = 0x4000
    case CARTRIDGE_SWITCHABLE_BANK_END = 0x7FFF
    case VIDEO_RAM                     = 0x8000
    case VIDEO_RAM_END                 = 0x9FFF
    case EXTERNAL_RAM_BANK             = 0xA000
    case EXTERNAL_RAM_BANK_END         = 0xBFFF
    case WORK_RAM                      = 0xC000
    case WORK_RAM_END                  = 0xCFFF
    case SWITCHABLE_WORK_RAM           = 0xD000 // switchable at least in cgb
    case SWITCHABLE_WORK_RAM_END       = 0xDFFF // switchable at least in cgb
    case ECHO_RAM                      = 0xE000
    case ECHO_RAM_END                  = 0xFDFF
    case OBJECT_ATTRIBUTE_MEMORY       = 0xFE00
    case OBJECT_ATTRIBUTE_MEMORY_END   = 0xFE9F
    case PROHIBITED_AREA               = 0xFEA0
    case PROHIBITED_AREA_END           = 0xFEFF
    case IO_REGISTERS                  = 0xFF00
    case WAVE_RAM                      = 0xFF30 // inside IO registers
    case WAVE_RAM_END                  = 0xFF3F // inside IO registers
    case IO_REGISTERS_END              = 0xFF7F
    case HIGH_RAM                      = 0xFF80
    case HIGH_RAM_END                  = 0xFFFE
    case INTERRUPT_FLAG_REGISTER       = 0xFF0F
    case INTERRUPT_ENABLE_REGISTER     = 0xFFFF
}

public enum MMUAddressSpaces {
    //n.b enum doesn't support ClosedRange<Int> but using static let does the tricks
    
    static let CARTRIDGE_BANK0:ClosedRange<Short> = MMUAddresses.CARTRIDGE_BANK0.rawValue...MMUAddresses.CARTRIDGE_BANK0_END.rawValue
    static let CARTRIDGE_SWITCHABLE_BANK:ClosedRange<Short> = MMUAddresses.CARTRIDGE_SWITCHABLE_BANK.rawValue...MMUAddresses.CARTRIDGE_SWITCHABLE_BANK_END.rawValue
    static let VIDEO_RAM:ClosedRange<Short> = MMUAddresses.VIDEO_RAM.rawValue...MMUAddresses.VIDEO_RAM_END.rawValue
    static let EXTERNAL_RAM_BANK:ClosedRange<Short> = MMUAddresses.EXTERNAL_RAM_BANK.rawValue...MMUAddresses.EXTERNAL_RAM_BANK_END.rawValue
    static let WORK_RAM = MMUAddresses.WORK_RAM.rawValue...MMUAddresses.WORK_RAM_END.rawValue
    static let SWITCHABLE_WORK_RAM:ClosedRange<Short> = MMUAddresses.SWITCHABLE_WORK_RAM.rawValue...MMUAddresses.SWITCHABLE_WORK_RAM_END.rawValue
    static let ECHO_RAM = MMUAddresses.ECHO_RAM.rawValue...MMUAddresses.ECHO_RAM_END.rawValue
    static let PROHIBITED_AREA = MMUAddresses.PROHIBITED_AREA.rawValue...MMUAddresses.PROHIBITED_AREA_END.rawValue
    static let OBJECT_ATTRIBUTE_MEMORY:ClosedRange<Short> = MMUAddresses.OBJECT_ATTRIBUTE_MEMORY.rawValue...MMUAddresses.OBJECT_ATTRIBUTE_MEMORY_END.rawValue
    static let IO_REGISTERS = MMUAddresses.IO_REGISTERS.rawValue...MMUAddresses.IO_REGISTERS_END.rawValue
    static let WAVE_RAM = MMUAddresses.WAVE_RAM.rawValue...MMUAddresses.WAVE_RAM_END.rawValue
    static let HIGH_RAM:ClosedRange<Short> = MMUAddresses.HIGH_RAM.rawValue...MMUAddresses.HIGH_RAM_END.rawValue
    static let WINDOW_TILE_MAP_AREA_0:ClosedRange<Short> = 0x9800...0x9BFF
    static let WINDOW_TILE_MAP_AREA_1:ClosedRange<Short> = 0x9C00...0x9FFF
    static let BG_WINDOW_TILE_DATA_AREA_0:ClosedRange<Short> = 0x8800...0x97FF
    static let BG_WINDOW_TILE_DATA_AREA_1:ClosedRange<Short> = 0x8000...0x8FFF
    static let BG_TILE_MAP_AREA_0:ClosedRange<Short> = 0x9800...0x9BFF
    static let BG_TILE_MAP_AREA_1:ClosedRange<Short> = 0x9C00...0x9FFF
    static let OBJ_TILE_DATA_AREA:ClosedRange<Short> = 0x8000...0x8FFF
}

/// same as MMUAddressSpaces but with ClosedRange<Int>
public enum MMUAddressSpacesInt {
    static let OBJECT_ATTRIBUTE_MEMORY:ClosedRange<Int> = Int(MMUAddresses.OBJECT_ATTRIBUTE_MEMORY.rawValue)...Int(MMUAddresses.OBJECT_ATTRIBUTE_MEMORY_END.rawValue)
    //add here any other needed range
}

//IO Addresses
public enum IOAddresses:Short {
    case JOYPAD_INPUT       = 0xFF00
    case SERIAL_TRANSFER_SB = 0xFF01
    case SERIAL_TRANSFER_SC = 0xFF02
    case DIV                = 0xFF04
    case TIMA               = 0xFF05
    case TMA                = 0xFF06
    case TAC                = 0xFF07
    
    //Channel 1
    case AUDIO_NR10 = 0xFF10
    case AUDIO_NR11 = 0xFF11
    case AUDIO_NR12 = 0xFF12
    case AUDIO_NR13 = 0xFF13
    case AUDIO_NR14 = 0xFF14
    
    //Channel 2
    //no NR20 in channel 2 as it has no sweep
    case AUDIO_NR21 = 0xFF16
    case AUDIO_NR22 = 0xFF17
    case AUDIO_NR23 = 0xFF18
    case AUDIO_NR24 = 0xFF19
    
    //Channel 3
    case AUDIO_NR30 = 0xFF1A
    case AUDIO_NR31 = 0xFF1B
    case AUDIO_NR32 = 0xFF1C
    case AUDIO_NR33 = 0xFF1D
    case AUDIO_NR34 = 0xFF1E
    
    //Channel 4
    case AUDIO_NR41 = 0xFF20
    case AUDIO_NR42 = 0xFF21
    case AUDIO_NR43 = 0xFF22
    case AUDIO_NR44 = 0xFF23
    
    case AUDIO_WAVE_PATTERN_RAM     = 0xFF30
    case AUDIO_WAVE_PATTERN_RAM_END = 0xFF3F
    
    case AUDIO_NR50 = 0xFF24
    case AUDIO_NR51 = 0xFF25
    case AUDIO_NR52 = 0xFF26
    
    case LCD_CONTROL = 0xFF40
    case LCD_STATUS  = 0xFF41
    case LCD_SCY     = 0xFF42
    case LCD_SCX     = 0xFF43
    case LCD_LY      = 0xFF44
    case LCD_LYC     = 0xFF45
    case LCD_DMA     = 0xFF46
    case LCD_BGP     = 0xFF47
    case LCD_OBP0    = 0xFF48
    case LCD_OBP1    = 0xFF49
    case LCD_WY      = 0xFF4A
    case LCD_WX      = 0xFF4B
}

/// standard color palettes
public enum StandardColorPalettes {
    /// Game Boy
    static let DMG = ColorPalette([Color(0x9B, 0xBC, 0x0F),Color(0x8B, 0xAC, 0x0F),Color(0x30, 0x62, 0x30),Color(0x0F, 0x38, 0x15)])
    
    /// Game Boy Pocket
    static let MGB = ColorPalette([Color(0xFF, 0xFF, 0xFF),Color(0xA9, 0xA9, 0xA9),Color(0x54, 0x54, 0x54),Color(0x00, 0x00, 0x00)])
}

/// PPU Timings of each mode (in T cycles)
enum PPUTimings:Int {
    case OAM_SEARCH_LENGTH = 80
    case PIXEL_RENDER_LENGTH = 172
    case HBLANK_LENGTH = 204
}
