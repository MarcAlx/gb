import GBKit
import Foundation

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
public class VideoManager {
    public static let sharedInstance = VideoManager()
    
    /// available palette
    private var palettes:[ColorPalette] = [
        StandardColorPalettes.DMG,
        StandardColorPalettes.MGB,
        //user defined palette, always last one
        ColorPalette([Color(0x9B, 0xBC, 0x0F),Color(0x8B, 0xAC, 0x0F),Color(0x30, 0x62, 0x30),Color(0x0F, 0x38, 0x15)])
    ]
    
    public private(set) var paletteIndex:PalettesIndexes = PalettesIndexes.DMG
    
    public init() {
    }
    
    /// change current palette
    public func setCurrentPalette(palette:PalettesIndexes, ppu:PPU) {
        self.paletteIndex = palette
        ppu.configuration.palette = palettes[self.paletteIndex.rawValue]
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
