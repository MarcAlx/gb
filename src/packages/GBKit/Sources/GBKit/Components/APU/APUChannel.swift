/// common properties of an APU channel
public protocol APUChannel {
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
    /// tick volume
    func tickVolume()
}

/// channel that supports enveloppe control
public protocol EnveloppableChannel {
    /// tick volume
    func tickEnveloppe()
}

/// square1 channel support length and enveloppe control
public protocol SquareChannel: APUChannel, LengthableChannel, EnveloppableChannel {
}

/// square2 channel  support length and enveloppe control along with sweep control
public protocol SquareWithSweepChannel: APUChannel, LengthableChannel, EnveloppableChannel, SweepableChannel {
}

/// wave channel supports length and volume control
public protocol WaveChannel: APUChannel, LengthableChannel, VolumableChannel {
}

/// noise channel supports length and enveloppe control
public protocol NoiseChannel: APUChannel, LengthableChannel, EnveloppableChannel {
}
