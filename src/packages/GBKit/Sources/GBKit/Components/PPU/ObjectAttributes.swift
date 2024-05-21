///stores tile info for an OBJ tile
public struct ObjectAttributes {
    ///position along x axis
    public let xPos:Byte
    
    ///position along y axis
    public let yPos:Byte
    
    ///tile index in tilemap
    public let tileIndex:Byte
    
    ///tile attributes/flags
    private let flags:Byte
    
    ///true if this BG/Win color (1 to 3) are over this tile
    public let isBelowBGWIN:Bool
    
    /// true if line bits are flipped
    public let isXFlipped:Bool
    
    /// true if lines are flipped
    public let isYFlipped:Bool
    
    ///true if Obj palette 1 should be used in place of 0
    public let useObjPalette1:Bool
    
    ///where this tile info was found
    public let OamAddress:Short
    
    ///x pos in viewport (i.e xPos considering x offset)
    public let viewportXPos:Int
    
    ///y pos in viewport (i.e yPos considering y offset)
    public let viewportYPos:Int
    
    /// init with location adress and effectie bytes
    public init(_ address:Short, _ bytes:[Byte]) {
        assert(bytes.count != GBConstants.ObjTileInfoSize, "tile info are made of exactly 4 bytes")
        
        self.OamAddress     = address
        self.yPos           = bytes[0]
        self.xPos           = bytes[1]
        self.tileIndex      = bytes[2]
        self.flags          = bytes[3]
        self.viewportXPos   = Int(self.xPos) - Int(GBConstants.ObjXOffset)
        self.viewportYPos   = Int(self.yPos) - Int(GBConstants.ObjYOffset)
        self.isBelowBGWIN   = isBitSet(ByteMask.Bit_7, self.flags)
        self.isYFlipped     = isBitSet(ByteMask.Bit_6, self.flags)
        self.isXFlipped     = isBitSet(ByteMask.Bit_5, self.flags)
        self.useObjPalette1 = isBitSet(ByteMask.Bit_4, self.flags)
    }
    
    ///True if this tile is on line considering a tile height (8 or 16) (independantly of X)
    public func isVerticallyVisible(onLine:Byte,withHeight:Byte) -> Bool {
        let effectiveY = self.viewportYPos
        let bottomY = effectiveY + Int(withHeight) - 1 // -1 as 0-indexed
        return effectiveY <= onLine && onLine <= bottomY
    }
    
    ///True if this tile is not horizontally offscreen (independantly of Y)
    public func isHorizontallyVisible() -> Bool {
        return 0 <= self.viewportXPos && self.viewportXPos < GBConstants.ScreenWidth
    }
}
