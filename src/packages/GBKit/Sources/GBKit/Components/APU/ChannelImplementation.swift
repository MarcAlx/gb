public class AudioChannel: Component, Clockable {
    let mmu:MMU
    
    public internal(set) var cycles: Int = 0
    
    public init(mmu: MMU) {
        self.mmu = mmu
    }
    
    public func tick(_ masterCycles: Int, _ frameCycles: Int) {
        self.cycles = self.cycles &+ 4
    }
    
    public func reset() {
    }
}

/// channel 1 is same as channel 2 but with sweep
public class Sweep: Pulse, SquareWithSweepChannel {
    override public func tick(_ masterCycles: Int, _ frameCycles: Int) {
        super.tick(masterCycles, frameCycles)
    }
    
    override public func reset() {
        super.reset()
    }
    
    override public func getPeriod() -> Int {
        return Int(self.mmu.CH1_Period)
    }
    
    public func tickSweep() {
    }
}

/// channel 2 is a square channel
public class Pulse: AudioChannel, SquareChannel {
    private var dutyStep:Int = 0
    private var dutyTimer:Int = 0
    
    override public func tick(_ masterCycles: Int, _ frameCycles: Int) {
        self.dutyTimer -= 4
        if(self.dutyTimer <= 0){
            //duty timer is re-armed by subtracting period divider to period
            self.dutyTimer = (GBConstants.APUPeriodDivider - self.getPeriod())
            //increment duty step (it wraps arround when overflown
            self.dutyStep = (self.dutyStep + 1) % 8
        }
        super.tick(masterCycles, frameCycles)
    }
    
    override public func reset() {
        super.reset()
        self.dutyTimer = 0
        self.dutyStep = 0
    }
    
    public func tickLength() {
    }
    
    public func tickEnveloppe() {
    }
    
    /// returns period for this channel
    public func getPeriod() -> Int {
        return Int(self.mmu.CH2_Period)
    }
}

/// channel 3 is a wave channel
public class Wave: AudioChannel, WaveChannel {
    public func tickLength() {
    }
    
    public func tickVolume() {
    }
}

/// channel 4 is a noise channel
public class Noise: AudioChannel, NoiseChannel {
    public func tickLength() {
    }
    
    public func tickEnveloppe() {
    }
}
