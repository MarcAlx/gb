/// channel 1 is same as channel 2 but with sweep
public class Sweep: Pulse, SquareWithSweepChannel {
    public func tickSweep() {
    }
}

/// channel 2 is a square channel
public class Pulse: SquareChannel {
    public var cycles: Int = 0
    
    public func tick(_ masterCycles: Int, _ frameCycles: Int) {
        
    }
    
    public func reset() {
        
    }
    
    public func tickLength() {
    }
    
    public func tickEnveloppe() {
    }
}

/// channel 3 is a wave channel
public class Wave: WaveChannel {
    public var cycles: Int = 0
    
    public func tick(_ masterCycles: Int, _ frameCycles: Int) {
        
    }
    
    public func reset() {
        
    }
    
    public func tickLength() {
    }
    
    public func tickVolume() {
    }
}

/// channel 4 is a noise channel
public class Noise: NoiseChannel {
    public var cycles: Int = 0
    
    public func tick(_ masterCycles: Int, _ frameCycles: Int) {
        
    }
    
    public func reset() {
        
    }
    
    public func tickLength() {
    }
    
    public func tickEnveloppe() {
    }
}
