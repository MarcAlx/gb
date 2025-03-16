public class AudioChannel: Component,
                           APUChannel,
                           Clockable,
                           LengthableChannel /*since all channel have Length handle it in super class*/ {
    
    public var id: AudioChannelId {
        get {
            return AudioChannelId.CH1 //override in sublcass
        }
    }
    
    let mmu:MMU
    
    public internal(set) var cycles: Int = 0
    
    public internal(set) var enabled:Bool = false
    
    public init(mmu: MMU) {
        self.mmu = mmu
    }
    
    public func tick(_ masterCycles: Int, _ frameCycles: Int) {
        //check mmu to check if channel is triggered
        if(self.mmu.isTriggered(self.id)){
            //if so trigger
            self.trigger()
            //reset mmu value
            self.mmu.resetTrigger(self.id)
        }
        self.cycles = self.cycles &+ 4
    }
        
    public func trigger() {
        //enable
        self.enabled = true
        //reset length if expired
        if(self.mmu.getLengthTimer(self.id) == 0){
            self.mmu.resetLengthTimer(self.id)
        }
    }
    
    public func tickLength() {
        if(self.mmu.getLengthTimer(self.id)>0 && self.mmu.isLengthEnabled(self.id)) {
            self.mmu.decrementLengthTimer(self.id)
            //when length reaches 0 it disable channel
            if(self.mmu.getLengthTimer(self.id) == 0){
                self.enabled = false
            }
        }
    }
    
    public func reset() {
        self.enabled = false
    }
}

/// channel 1 is same as channel 2 but with sweep
public class Sweep: Pulse, SquareWithSweepChannel {
    override public var id: AudioChannelId {
        AudioChannelId.CH1
    }
    
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
    
    override public var id: AudioChannelId {
        AudioChannelId.CH2
    }
    
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
    
    public func tickEnveloppe() {
    }
    
    /// returns period for this channel
    public func getPeriod() -> Int {
        return Int(self.mmu.CH2_Period)
    }
}

/// channel 3 is a wave channel
public class Wave: AudioChannel, WaveChannel {
    override public var id: AudioChannelId {
        AudioChannelId.CH3
    }
    
    public func tickVolume() {
    }
}

/// channel 4 is a noise channel
public class Noise: AudioChannel, NoiseChannel {
    override public var id: AudioChannelId {
        AudioChannelId.CH4
    }
    
    public func tickEnveloppe() {
    }
}
