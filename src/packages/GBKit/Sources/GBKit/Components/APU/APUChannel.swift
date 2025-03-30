/// common properties of an APU channel
public protocol APUChannel: Component, Clockable {    
    /// can be seen as channel value
    var amplitude:Byte { get }
    
    /// true if enabled
    var enabled:Bool { get }
    
    ///channel id
    var id:AudioChannelId { get }
    
    /// causes this channel to trigger
    func trigger()
}

/// channel that supports length control
public protocol LengthableChannel {
    /// tick length
    func tickLength()
}

/// channel that supports sweep control
public protocol SweepableChannel {
    /// tick sweep
    func tickSweep()
}

/// channel that supports volume control
public protocol VolumableChannel {
    //volume is not something ticked, this protocol is mainly there for typing
}

/// channel that supports period
public protocol PeriodicChannel {
    ///channel id
    var periodId:ChannelWithPeriodId { get }
}

/// channel that supports enveloppe control
public protocol EnvelopableChannel {
    ///channel id
    var envelopeId:EnveloppableAudioChannelId { get }
    
    /// tick volume
    func tickEnveloppe()
}

/// square1 channel support length and enveloppe control
public protocol SquareChannel: APUChannel, PeriodicChannel, LengthableChannel, EnvelopableChannel {
    ///square id
    var squareId:DutyAudioChannelId { get }
}

/// square2 channel  support length and enveloppe control along with sweep control
public protocol SquareWithSweepChannel: APUChannel, PeriodicChannel, LengthableChannel, EnvelopableChannel, SweepableChannel {
}

/// wave channel supports length and volume control
public protocol WaveChannel: APUChannel, PeriodicChannel, LengthableChannel, VolumableChannel {
}

/// noise channel supports length and enveloppe control
public protocol NoiseChannel: APUChannel, LengthableChannel, EnvelopableChannel {
}
