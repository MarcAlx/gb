import Foundation

/// An rgb color, values are stored in an RGB array
public struct Color {
    
    /// red component
    public let r:Byte
    
    ///green component
    public let g:Byte
    
    ///blue component
    public let b:Byte
    
    public init(_ r:Byte, _ g:Byte, _ b:Byte){
        self.r = r
        self.g = g
        self.b = b
    }
}

/// a color palette, made of three colors
public struct ColorPalette {
    private var values:[Color]
    
    public subscript(colorIndex:Int) -> Color {
        get {
            return self.values[colorIndex]
        }
        set {
            self.values[colorIndex] = newValue
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
public enum PalettesIndexes: Int {
    ///Game Boy
    case DMG = 0
    
    /// Game Boy Pocket
    case MGB = 1
    
    ///User defined palette
    case CUSTOM = 2
}

/// to ease palette referencing and customization
public class PaletteManager {
    public static let sharedInstance = PaletteManager()
    
    /// available palette
    private var palettes:[ColorPalette] = [
        StandardColorPalettes.DMG,
        StandardColorPalettes.MGB,
        //user defined palette, always last one
        ColorPalette([Color(0x9B, 0xBC, 0x0F),Color(0x8B, 0xAC, 0x0F),Color(0x30, 0x62, 0x30),Color(0x0F, 0x38, 0x15)])
    ]
    
    /// shorthand for drawing, palette aware empty frame, made of Color 0 of current frame
    public private(set) var currentEmptyFrame:Data = Data(stride(from: 0, to: GBConstants.PixelCount, by: 1).flatMap {
        _ in return [0x00, 0x00, 0x00,255]//R,G,B,A
    })
    
    /// current palette
    public private(set) var currentPalette:ColorPalette = StandardColorPalettes.DMG
    
    public private(set) var paletteIndex:PalettesIndexes = PalettesIndexes.DMG
    
    public init() {
        self.setCurrentPalette(palette: .DMG)//ensure empty frame init
    }
    
    /// change current palette
    public func setCurrentPalette(palette:PalettesIndexes) {
        self.paletteIndex = palette
        self.currentPalette = palettes[self.paletteIndex.rawValue]
        self.currentEmptyFrame = Data(stride(from: 0, to: GBConstants.PixelCount, by: 1).flatMap {
            _ in return [
                self.currentPalette[0].r,
                self.currentPalette[0].g,
                self.currentPalette[0].b,
                255
            ]//R,G,B,A
        })
    }
    
    /// set user defined palette
    public var customPalette:ColorPalette {
        get {
            return self.palettes[self.palettes.count-1]
        }
        set {
            self.palettes[self.palettes.count-1] = newValue
        }
    }
}
