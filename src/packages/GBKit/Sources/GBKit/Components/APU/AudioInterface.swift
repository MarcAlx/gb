///maps each Audio channel to an int value, ease further indexing
public enum AudioChannelId:Int {
    case CH1 = 0
    case CH2 = 1
    case CH3 = 2
    case CH4 = 3
}

///maps each Audio channel that supports enveloppe to an int value, ease further indexing
public enum EnveloppableAudioChannelId:Int {
    case CH1 = 0
    case CH2 = 1
    case CH4 = 2
}

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
    
    /// returns actual length timer value for an audio channel
    func getLengthTimer(_ channel:AudioChannelId) -> Int

    /// resets length timer value for an audio channel (value is reset to DefaultLengthTImer value for channel)
    func resetLengthTimer(_ channel:AudioChannelId)
    
    ///decrements length timer for an audio channel
    func decrementLengthTimer(_ channel:AudioChannelId)
    
    /// true if length is enabled
    func isLengthEnabled(_ channel:AudioChannelId) -> Bool
    
    /// true if channel is triggered
    func isTriggered(_ channel:AudioChannelId) -> Bool
    
    /// reset trigger for a channel
    func resetTrigger(_ channel:AudioChannelId)
    
    ///notify NR52 about channel state
    func setAudioChannelState(_ channel:AudioChannelId, enabled:Bool)
    
    ///returns enveloppe direction, 0 -> Descreasing, 1-> Increasing
    func getEnvelopeDirection(_ channel:EnveloppableAudioChannelId) -> Byte
    
    ///returns enveloppe pace, every each enveloppe tick of this value enveloppe is applied
    func getEnvelopeSweepPace(_ channel:EnveloppableAudioChannelId) -> Byte
    
    ///returns enveloppe pace, every each enveloppe tick of this value enveloppe is applied
    func getEnvelopeInitialVolume(_ channel:EnveloppableAudioChannelId) -> Byte
}
