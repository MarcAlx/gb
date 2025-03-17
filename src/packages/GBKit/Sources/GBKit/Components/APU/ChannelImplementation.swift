///a super class for all audio channel
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
    
    private var _enabled:Bool = false
    public internal(set) var enabled:Bool{
        get {
            return self._enabled
        }
        set {
            self._enabled = newValue
            //notify MMU that channel state has changed
            self.mmu.setAudioChannelState(self.id, enabled: newValue)
        }
    }
    
    public internal(set) var volume:Byte = 0
    
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

///a super class for channel with envelope
public class AudioChannelWithEnvelope: AudioChannel, EnvelopableChannel{
    public var envelopeId: EnveloppableAudioChannelId {
        get {
            return EnveloppableAudioChannelId.CH1 //override in sublcass
        }
    }
    
    private var envelopePace:Byte = 0
    private var envelopeTimer:Byte = 0
    //if envelope direction is up -> true, else direction down so false
    private var isEnvelopeDirectionUp:Bool = false
    
    override public func trigger() {
        super.trigger()
        
        //init volume with initial value
        self.volume = self.mmu.getEnvelopeInitialVolume(self.envelopeId)
        //reset sweep pace
        self.envelopePace = self.mmu.getEnvelopeSweepPace(self.envelopeId)
        self.envelopeTimer = self.envelopePace
        //save enveloppe direction
        self.isEnvelopeDirectionUp = self.mmu.getEnvelopeDirection(self.envelopeId) == 0
    }
    
    public func tickEnveloppe() {
        //a pacing of 0 means enveloppe is disabled
        if(self.envelopePace != 0){
            //every tick decrease pace
            if(self.envelopeTimer>0){
                self.envelopeTimer -= 1
            }
            //it's time to apply enveloppe
            if(self.envelopeTimer == 0){
                self.envelopeTimer = self.envelopePace //re-arm timer with initial value (n.b needs retrigger to re-read mmu value)
                
                //envelope is only applied for a volume between 0x0 and 0xF (15)
                if(self.volume < 0xF && self.isEnvelopeDirectionUp) {
                    self.volume += 1
                }
                else if(self.volume > 0x0 && !self.isEnvelopeDirectionUp) {
                    self.volume -= 1
                }
            }
        }
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
public class Pulse: AudioChannelWithEnvelope, SquareChannel {
    
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
            //increment duty step (it wraps arround when overflown)
            self.dutyStep = (self.dutyStep + 1) % 8
        }
        super.tick(masterCycles, frameCycles)
    }
    
    override public func reset() {
        super.reset()
        self.dutyTimer = 0
        self.dutyStep = 0
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
public class Noise: AudioChannelWithEnvelope, NoiseChannel {
    override public var id: AudioChannelId {
        AudioChannelId.CH4
    }
}
