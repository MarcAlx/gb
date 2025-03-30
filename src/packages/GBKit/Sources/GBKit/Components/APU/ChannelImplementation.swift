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
    
    public var amplitude:Byte {
        get {
            return 0 // override in subclass
        }
    }
    
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
        self.cycles = self.cycles &+ GBConstants.MCycleLength
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
    //channel volume, only for envelope one, (n.b wave channel has its own volume behavior)
    public internal(set) var volume:Byte = 0
    
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
    public override var amplitude:Byte {
        get {
            if(self.enabled){
                //amplitude is equal to DutyPattern value (0 or 1) multiplied by volume (byte value)
                return GBConstants.DutyPatterns[Int(self.mmu.getDutyPattern(self.squareId))][Int(self.dutyStep)]
                     * self.volume
            }
            return 0
        }
    }
    
    override public func tick(_ masterCycles: Int, _ frameCycles: Int) {
        if(self.dutyTimer > 0){
            self.dutyTimer -= 1
        }
        if(self.dutyTimer <= 0){
            //duty timer is re-armed by subtracting period divider to period
            self.dutyTimer = (GBConstants.APUPeriodDivider - Int(self.mmu.getPeriod(self.periodId))) * GBConstants.EnveloppeAbsoluteSpeedDivider
            //n.b multiplited by Absoulute divider as APU is ticked every 1t (normal speed) as its faster than how it should run (APU is slower than CPU) so multiply
            
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
    
    //current sample read in wave
    private var position:Short = 0
    //nibble read, upper: true, false else
    private var isUpperNibbleRead:Bool = true
    //initial wave timer value to avoid update before trigger
    private var initialWaveTimer:Int = 0
    //timer at which wave is updated
    private var waveTimer:Int = 0
    
    override public func trigger() {
        super.trigger()
        self.position = 0
        self.isUpperNibbleRead = true //read upper nibble first
        self.initialWaveTimer = GBConstants.APUPeriodDivider - Int(self.mmu.getPeriod(self.periodId)) * GBConstants.APUSpeedDivider /*wave runs at APU speed*/
        self.waveTimer = self.initialWaveTimer
    }
    
    override public func tick(_ masterCycles: Int, _ frameCycles: Int) {
        if(self.enabled){
            if(self.waveTimer > 0){
                self.waveTimer -= 1
            }
            
            if(self.waveTimer <= 0){
                //reload wave timer
                self.waveTimer = self.initialWaveTimer
                //update nibble read
                self.isUpperNibbleRead = !self.isUpperNibbleRead
                //increment position if nibble has been switched from low to high
                if(self.isUpperNibbleRead){
                    self.position += 1
                }
            }
        }
    }
    
    /// returns channel amplitude according to current wave pattern
    public override var amplitude:Byte {
        get {
            if(self.enabled){
                let sample:Byte = self.mmu[MMUAddressSpaces.WAVE_RAM.lowerBound+self.position]
                //if upper nibble is read erase by shift lower nibble, else erase by & upper nibble
                let sampleValue:Byte = self.isUpperNibbleRead ? sample >> 4
                                                              : sample & 0b0000_1111
                //apply volume shift (wave channel has no individual volume control as others)
                return sampleValue >> GBConstants.WaveShiftValue[Int(self.mmu.getWaveOutputLevel())]
            }
            else {
                return 0
            }
        }
    }
}

/// channel 4 is a noise channel
public class Noise: AudioChannelWithEnvelope, NoiseChannel {
    
    //timer at which noise is updated
    private var noiseTimer:Int = 0
    
    /// linear feedback shift register used to produce noise
    private var LSFR:Short = 0
    
    override public var id: AudioChannelId {
        AudioChannelId.CH4
    }
    override public func trigger() {
        super.trigger()
        //on trigger re-inits to all 1 bits for its 15bits width
        self.LSFR = 0b0111_1111_1111_1111
    }
    
    override public func tick(_ masterCycles: Int, _ frameCycles: Int) {
        if(self.enabled){
            if(self.noiseTimer > 0){
                self.noiseTimer -= 1
            }
            
            if(self.noiseTimer <= 0){
                //reload noise timer
                self.noiseTimer = self.mmu.getNoiseClockDivisor() * Int(pow(2.0, Double(self.mmu.getNoiseClockShift())))
                //compute LFSR bit to apply to bit 15 of LSFR (and bit 7 if short mode)
                let xor:Short = (self.LSFR & 0b10 >> 1) ^ self.LSFR & 0b01
                //shift LFSR right then store xor at 15bit position
                self.LSFR = self.LSFR >> 1 & (xor << 14)
                //in case of short width store it at bit 7 too
                if(self.mmu.hasNoiseShortWidth()){
                    self.LSFR = (self.LSFR & 0b1111_1111_1011_1111) //clear bit 7 in lfsr
                              | self.LSFR & xor << 6                //store bit 7 at bit 7
                }
            }
        }
    }
    
    /// returns channel amplitude
    public override var amplitude:Byte {
        get {
            if(self.enabled){
                //amplitude is equal to LFSR bit 1 value (0 or 1) multiplied by volume (byte value)
                return ~(Byte(self.LSFR & 0xFF) & 0b0000_0001)//value is equal to inverse of first bit
                     * self.volume
            }
            else {
                return 0
            }
        }
    }
}
