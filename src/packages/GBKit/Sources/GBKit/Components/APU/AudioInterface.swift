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

///maps each Audio channel that supports period
public enum ChannelWithPeriodId:Int {
    case CH1 = 0
    case CH2 = 1
    case CH3 = 2
}

///maps each Audio channel that supports duty to an int value, ease further indexing
public enum DutyAudioChannelId:Int {
    case CH1 = 0
    case CH2 = 1
}

/// ease access to audio registers
public protocol AudioInterface {
    /// enable or disable audio
    func setAudioState(_ enabled: Bool) -> Void
    
    /// true if audio is enabled
    func isAudioEnabled() -> Bool
    
    /// return duty pattern for an audio channel
    func getDutyPattern(_ channel:DutyAudioChannelId) -> Byte
    
    /// return period for an audio channel
    func getPeriod(_ channel:ChannelWithPeriodId) -> Short
    
    /// write duty period for an audio channel
    func setPeriod(_ channel:DutyAudioChannelId, _ val:Short)
    
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
    
    ///return sweep pace (nb of iteration before sweep is applied)
    func getSweepPace() -> Byte
    
    ///return sweep direction, 0 -> Descreasing, 1-> Increasing
    func getSweepDirection() -> Byte
    
    ///get sweep step
    func getSweepStep() -> Byte
    
    ///returns wave output level
    func getWaveOutputLevel() -> Byte
    
    ///returns noise clock shift
    func getNoiseClockShift() -> Byte
    
    /// returns Linear feedback shift register width for noise channel
    func hasNoiseShortWidth() -> Bool
    
    /// returns noise clock divider
    func getNoiseClockDivisor() -> Int
    
    /// returns information about each channel L/R audio panning, if true the corresponding channel componnent L/R is enabled (it's hard panning on/off no seamless transition here)
    func getAPUChannelPanning() -> (CH4_L:Bool,
                                    CH3_L:Bool,
                                    CH2_L:Bool,
                                    CH1_L:Bool,
                                    CH4_R:Bool,
                                    CH3_R:Bool,
                                    CH2_R:Bool,
                                    CH1_R:Bool)/*n.b order is mismatched to match corresponding bit i register, mismatch in swift's tuple order is deprecated*/
 
    /// returns master volume (for L and R)
    func getMasterVolume() -> (L:Byte, R:Byte)
    
    /// returns VIN panning
    func getVINPanning() -> (L:Bool, R:Bool)
}
