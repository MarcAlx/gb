public enum InterruptFlag : Byte {
    case VBlank  = 0b0000_0001
    case LCDStat = 0b0000_0010
    case Timer   = 0b0000_0100
    case Serial  = 0b0000_1000
    case Joypad  = 0b0001_0000
}

/// Interrupts controller
///
/// i.e: an interrupt is raised if IME is true AND enabled (by code/game) via IE AND flagged at runtime (by PPU) via IF
///    for LCDStat on top of these conditions some bits must be set (by code/game) to true in LCD_STATUS (4 cases may trigger LCDStat : LYeqLYC, HBlank, VBLANK, OAM)
public protocol InterruptsControlInterface {
    
    /// Interrupts Master Enable
    var IME:Bool { get set }
    
    /// Interrupt Enabled, stores in its 5 lsb which interrupts are enabled
    var IE:Byte { get set }
    
    /// Interrupt Flagged, stores in its 5 lsb which interrupts are flagged (ready to fire)
    var IF:Byte { get set }

    /// set interrrupt enabled value
    func setInterruptEnableValue(_ interrupt:InterruptFlag, _ enable:Bool)
    
    /// set interrrupt flagged value
    func setInterruptFlagValue(_ interrupt:InterruptFlag, _ enable:Bool)
    
    /// true if interrupt is enabled
    func isInterruptEnabled(_ interrupt:InterruptFlag) -> Bool
    
    ///true if interrupt is flagged
    func isInterruptFlagged(_ interrupt:InterruptFlag) -> Bool
}
