/// An rgb color, values are stored in an RGB array
struct Color {
    public let values:[Byte]
    
    public subscript(componentIndex:Int) -> Byte {
        get {
            return self.values[componentIndex]
        }
    }
    
    public init(values:[Byte]){
        assert(values.count == 3, "color must have exactly 3 components")
        self.values = values
    }
    
    public init(_ r:Byte, _ g:Byte, _ b:Byte){
        self.init(values: [r,g,b])
    }
}

/// a color palette, made of three colors
struct ColorPalette {
    private let values:[Color]
    
    public subscript(colorIndex:Int) -> Color {
        get {
            return self.values[colorIndex]
        }
    }
    
    /// init with values from light to dark
    public init(_ values:[Color]) {
        assert(values.count == 4, "color must have exactly 4 colors")
        self.values = values
    }
    
    /// init a color palette from a reference palette and a byte that define shuffling (@see FF47 mmu address)
    public init(paletteData:Byte, reference:ColorPalette){
        //todo keep only lower two bit via & 0b0000_0011 instead of double shifting
        let color3Index = (paletteData /*<< 0*/) >> 6
        let color2Index = (paletteData << 2) >> 6
        let color1Index = (paletteData << 4) >> 6
        let color0Index = (paletteData << 6) >> 6
        self.init([
            reference[Int(color0Index)],
            reference[Int(color1Index)],
            reference[Int(color2Index)],
            reference[Int(color3Index)]
        ])
    }
}

/// available palette
enum PalettesIndexes: Int {
    ///Game Boy
    case DMG = 0
    
    /// Game Boy Pocket
    case MGB = 1
    
    ///User defined palette
    case CUSTOM = 2
}

/// to ease palette referencing and customization
class PaletteManager {
    public static let sharedInstance = PaletteManager()
    
    /// available palette
    private var palettes:[ColorPalette] = [
        StandardColorPalettes.DMG,
        StandardColorPalettes.MGB,
        //user defined palette, always last one
        ColorPalette([Color(0x9B, 0xBC, 0x0F),Color(0x8B, 0xAC, 0x0F),Color(0x30, 0x62, 0x30),Color(0x0F, 0x38, 0x15)])
    ]
    
    /// current palette
    public private(set) var currentPalette:ColorPalette = StandardColorPalettes.DMG
    
    /// change current palette
    public func setCurrentPalette(palette:PalettesIndexes) {
        self.currentPalette = palettes[palette.rawValue]
    }
    
    /// set user defined palette
    public func setCustomPalette(palette:ColorPalette) {
        self.palettes[self.palettes.count-1] = palette
    }
}
