/// channel 1 is same as channel 2 but with sweep
public class Sweep: Pulse, SquareWithSweepChannel {
    override public func tick(_ masterCycles: Int, _ frameCycles: Int) {
        super.tick(masterCycles, frameCycles)
    }
    
    override public func reset() {
        super.reset()
    }
    
    public func tickSweep() {
    }
}

/// channel 2 is a square channel
public class Pulse: SquareChannel {
    public private(set) var cycles: Int = 0
    
    private var dutyStep:Int = 0
    
    public func tick(_ masterCycles: Int, _ frameCycles: Int) {
        self.cycles = self.cycles &+ 4
    }
    
    public func reset() {
        self.cycles = 0
    }
    
    public func tickLength() {
    }
    
    public func tickEnveloppe() {
    }
}

/// channel 3 is a wave channel
public class Wave: WaveChannel {
    public private(set) var cycles: Int = 0
    
    public func tick(_ masterCycles: Int, _ frameCycles: Int) {
        self.cycles = self.cycles &+ 4
    }
    
    public func reset() {
        self.cycles = 0
    }
    
    public func tickLength() {
    }
    
    public func tickVolume() {
    }
}

/// channel 4 is a noise channel
public class Noise: NoiseChannel {
    public private(set) var cycles: Int = 0
    
    public func tick(_ masterCycles: Int, _ frameCycles: Int) {
        self.cycles = self.cycles &+ 4
    }
    
    public func reset() {
        self.cycles = 0
    }
    
    public func tickLength() {
    }
    
    public func tickEnveloppe() {
    }
}
