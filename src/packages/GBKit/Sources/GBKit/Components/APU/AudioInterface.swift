/// ease access to audio registers
public protocol AudioInterface {
    /// enable or disable audio
    func setAudioState(_ enabled: Bool) -> Void
    
    /// true if audio is enabled
    func isAudioEnabled() -> Bool
    
    /// combines 3bits of NR14 and 8bits of NR13 to get CH1 period
    var CH1_Period:Short { get }
    
    /// returns wave duty pattern
    var CH1_WaveDuty:Byte { get }
    
    /// combines 3bits of NR24 and 8bits of NR23 to get CH2 period
    var CH2_Period:Short { get }
}
