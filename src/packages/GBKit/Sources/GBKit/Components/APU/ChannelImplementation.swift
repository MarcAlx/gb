import Foundation

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
    
    override public var squareId: DutyAudioChannelId{
        get {
            return DutyAudioChannelId.CH1
        }
    }
    
    override public var periodId: ChannelWithPeriodId{
        get {
            return ChannelWithPeriodId.CH1 //override in sublcass
        }
    }
    
    //period is saved on trigger to avoid taking into account in between period writes
    private var sweepShadowPeriod:Short = 0
    //sweep has its own timer
    private var sweepTimer:Byte = 0
    //initial timer value to reload the timer with
    private var sweepPace:Byte = 0
    //true if sweep is incremental
    private var isSweepDirectionUp:Bool = false
    //value used for sweep computation, see computePeriod()
    private var sweepStep:Byte = 0
    //if true sweep will be computed and applied
    private var sweepEnabled:Bool = false
    
    override public func tick(_ masterCycles: Int, _ frameCycles: Int) {
        super.tick(masterCycles, frameCycles)
    }
    
    override public func reset() {
        super.reset()
    }
    
    override public func trigger() {
        super.trigger()
        self.sweepShadowPeriod = self.mmu.getPeriod(self.periodId)
        self.sweepPace  = self.mmu.getSweepPace()
        self.loadSweepTimer()
        self.isSweepDirectionUp  = self.mmu.getSweepDirection() != 0
        self.sweepStep  = self.mmu.getSweepStep()
        self.sweepEnabled = self.sweepPace > 0 || self.sweepStep > 0
        //on trigger an OOB check is performed
        if(self.sweepStep > 0){
            self.checkNextOutOfBounds()
        }
    }
    
    /// ensure sweeptimer is loaded with 8 in case of pace being 0
    private func loadSweepTimer() {
        self.sweepTimer = self.sweepPace == 0 ? 8 : self.sweepPace
    }
    
    public func tickSweep() {
        if(self.sweepTimer>0){
            self.sweepTimer -= 1
        }
        //apply sweep when timer is 0
        if(self.sweepTimer==0){
            //reload timer
            self.loadSweepTimer()
            //timer runs even is sweep is disabled
            if(self.sweepEnabled){
                //compute new perdiod
                let res = self.computePeriod()
                //apply if not OOB
                if(!res.outOfBounds){
                    self.mmu.setPeriod(self.squareId, res.newPeriod)
                    self.sweepShadowPeriod = res.newPeriod
                    //on apply check next OOB
                    self.checkNextOutOfBounds()
                }
                else {
                    self.enabled = false
                }
            }
        }
    }
    
    /// computes new period using the following formula:
    ///    NewPeriod = currentPeriod ± (currentPeriod / 2^sweepStep)
    ///    n.b ± depends on isSweepDirectionUp
    ///    returns new period in res, along with indication if this value is out of bounds (11bit overflow (of NR13/NR14) or form an underflow)
    private func computePeriod() -> (newPeriod:Short, outOfBounds:Bool) {
        //sweep formula is: NewPeriod = currentPeriod ± (currentPeriod / 2^sweepStep)
        //n.b ± depends on isSweepDirectionUp
        let currentPeriod = self.sweepShadowPeriod
        let deltaPeriod = (currentPeriod / Short(pow(2.0, Double(self.sweepStep))))
        let newPeriod = self.isSweepDirectionUp ? currentPeriod + deltaPeriod
                                                : currentPeriod &- deltaPeriod
        return (newPeriod: newPeriod,
                outOfBounds: newPeriod >= 0x7FF || newPeriod >= currentPeriod)
    }
    
    /// checks if next period computation would produce overflow/underflow if so disable channels
    /// mainly for anticiaption
    private func checkNextOutOfBounds() {
        self.enabled = !self.computePeriod().outOfBounds
    }
}

/// channel 2 is a square channel
public class Pulse: AudioChannelWithEnvelope, SquareChannel {
    
    override public var id: AudioChannelId {
        AudioChannelId.CH2
    }
    
    public var periodId: ChannelWithPeriodId {
        get {
            return ChannelWithPeriodId.CH2
        }
    }
    
    public var squareId: DutyAudioChannelId{
        get {
            return DutyAudioChannelId.CH2
        }
    }
    
    private var dutyStep:Int = 0
    private var dutyTimer:Int = 0
    
    /// returns channel amplitude according to current wave duty step
    public var amplitude:Byte {
        get {
            GBConstants.DutyPatterns[Int(self.mmu.getDutyPattern(self.squareId))][Int(self.dutyStep)]
        }
    }
    
    override public func tick(_ masterCycles: Int, _ frameCycles: Int) {
        self.dutyTimer -= 4
        if(self.dutyTimer <= 0){
            //duty timer is re-armed by subtracting period divider to period
            self.dutyTimer = (GBConstants.APUPeriodDivider - Int(self.mmu.getPeriod(self.periodId)))
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
}

/// channel 3 is a wave channel
public class Wave: AudioChannel, WaveChannel {
    override public var id: AudioChannelId {
        AudioChannelId.CH3
    }
    
    public var periodId: ChannelWithPeriodId{
        get {
            return ChannelWithPeriodId.CH3
        }
    }
    
    }
}

/// channel 4 is a noise channel
public class Noise: AudioChannelWithEnvelope, NoiseChannel {
    override public var id: AudioChannelId {
        AudioChannelId.CH4
    }
}
