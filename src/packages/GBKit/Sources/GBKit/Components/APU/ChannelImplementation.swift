/// channel 1 is a square channel
public class Channel1: SquareChannel {
    public func tickLength() {
    }
    
    public func tickEnveloppe() {
    }
}

/// channel 2 is same as channel 1 but with sweep
public class Channel2: Channel1, SquareWithSweepChannel {
    public func tickSweep() {
    }
}

/// channel 3 is a wave channel
public class Channel3: WaveChannel {
    public func tickLength() {
    }
    
    public func tickVolume() {
    }
}

/// channel 4 is a noise channel
public class Channel4: NoiseChannel {
    public func tickLength() {
    }
    
    public func tickEnveloppe() {
    }
}
