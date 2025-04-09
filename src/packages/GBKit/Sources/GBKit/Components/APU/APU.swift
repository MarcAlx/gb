//not normalized audio sample (int value randed from 0 to 255
typealias RawAudioSample = (L:Int, R:Int)

//An audio sample that holds both L and R channel values
public typealias AudioSample = (L:Float, R:Float)

///Function to be passed that will play input sample buffer, it's your responsability to interleaved L and R channel sample
public typealias PlayCallback = (_ samples:[AudioSample]) -> Void

///how AudioSampleNormalization are normalized
public enum AudioSampleNormalization {
    ///samples values ranged from 0 to 255
    case RAW
    ///samples will be normalized as values ranged from -1.0 to 1.0
    case FLOAT_MINUS_1_TO_1
}

///Configuration to provide to APU,
public struct APUConfiguration {
    ///Audio sample rate (in Hz)
    ///n.b as in 44100Hz or 48000Hz
    public let sampleRate:Int
    
    ///Amount of sample to store
    public let bufferSize:Int
    
    ///normalization method
    public let normalizationMethod:AudioSampleNormalization
    
    ///Callback tha will be called once buffer size has been riched
    public let playback:PlayCallback
    
    public init(sampleRate: Int,
                bufferSize: Int,
                normalizationMethod: AudioSampleNormalization,
                playback: PlayCallback?) {
        self.sampleRate = sampleRate
        self.bufferSize = bufferSize
        self.normalizationMethod = normalizationMethod
        self.playback = playback!
    }
    
    ///default configuration, mainly for init purpose
    public static let DEFAULT:APUConfiguration = APUConfiguration(
        sampleRate: 441000,
        bufferSize: 256,
        normalizationMethod: .RAW,
        playback: { _ in } )
}

public class APU: Component, Clockable {
    ///buffer filled with 0.0 to express silence
    public private(set) var SILENT_BUFFER:[AudioSample] = []
    
    public private(set) var cycles:Int = 0
    
    private let mmu:MMU
    
    private var frameSequencerCounter:Int = 0
    
    private var frameSequencerStep:Int = 0
    
    private let channel1:SquareWithSweepChannel
    private let channel2:SquareChannel
    private let channel3:WaveChannel
    private let channel4:NoiseChannel
    
    //rate (in M tick) at which we sample
    private var sampleTickRate:Int = 0
    
    private var _configuration:APUConfiguration = APUConfiguration.DEFAULT
    public var configuration:APUConfiguration {
        set {
            //set value
            self._configuration = newValue
            //on configuration set update silent buffer with proper size
            self.SILENT_BUFFER = Array(0 ..< newValue.bufferSize ).map { _ in (L: 0.0, R: 0.0) }
            //reset audio buffer
            self._audioBuffer = self.SILENT_BUFFER
            //init sample rate, we will tick every sampleRate fraction of CPUSpeed (both are expressed in the same unit Hz)
            self.sampleTickRate = GBConstants.CPUSpeed / newValue.sampleRate
        }
        get {
            self._configuration
        }
    }
    
    ///to avoid useless computation when normalized is prompted, map each value from 0 to 255 with its counterpart between 0.0 and 1.0
    private let byteToFloatMap:[Float] = Array(0 ..< Int(Byte.max)+1 ).map { Float($0) / 255.0 }
    
    private var _audioBuffer:[AudioSample] = []
    /// last commited audio buffer, ready to play
    public var audioBuffer:[AudioSample] {
        get {
            //return a copy to avoid concurrent access
            return self._audioBuffer.map { $0 }
        }
    }
    
    //next audio buffer (note that this buffer is not normalized)
    private var nextBuffer:[RawAudioSample] = []
    
    //timer to generate timer
    private var sampleTimer = 0
    
    init(mmu:MMU) {
        self.mmu = mmu
        self.channel1 = Sweep(mmu: self.mmu)
        self.channel2 = Pulse(mmu: self.mmu)
        self.channel3 = Wave(mmu: self.mmu)
        self.channel4 = Noise(mmu: self.mmu)
        //ensure configuration related properties are set on init
        self.configuration = APUConfiguration.DEFAULT
    }
    
    public func tick(_ masterCycles: Int, _ frameCycles: Int) {
        self.channel1.tick(masterCycles, frameCycles)
        self.channel2.tick(masterCycles, frameCycles)
        self.channel3.tick(masterCycles, frameCycles)
        self.channel4.tick(masterCycles, frameCycles)
        
        if(self.frameSequencerCounter >= GBConstants.APUFrameSequencerStepLength){
            self.stepFrameSequencer()
            self.frameSequencerCounter = 0
        }
        else {
            self.frameSequencerCounter = self.frameSequencerCounter &+ GBConstants.MCycleLength
        }
        
        self.cycles = self.cycles &+ GBConstants.MCycleLength
        self.sampleTimer += GBConstants.MCycleLength
        
        //sample timer has been reached -> sample
        if(self.sampleTimer >= self.sampleTickRate) {
            //reset timer
            self.sampleTimer = 0
            //store sample
            self.nextBuffer.append(self.sample())
            //buffer size has been reached commit
            if(self.nextBuffer.count >= self.configuration.bufferSize){
                //commit buffer
                self.commitBuffer()
                //playback
                self.configuration.playback(self.audioBuffer)
                //ready for next buffer
                self.nextBuffer = []
            }
        }
    }
    
    /// set current buffer as ready to use
    private func commitBuffer() {
        //convert raw audio buffer to normalized buffer
        switch(self.configuration.normalizationMethod){
        case .RAW:
            self._audioBuffer = self.nextBuffer.map { (L:Float($0.L), R:Float($0.R)) }
        case .FLOAT_MINUS_1_TO_1:
            self._audioBuffer = self.nextBuffer.map { (L:self.byteToFloatMap[$0.L], R:self.byteToFloatMap[$0.L]) }
        }
    }
    
    private func stepFrameSequencer(){
        switch(self.frameSequencerStep){
        case 0:
            self.channel1.tickLength()
            self.channel2.tickLength()
            self.channel3.tickLength()
            self.channel4.tickLength()
            break
        case 1:
            break
        case 2:
            self.channel1.tickLength()
            self.channel2.tickLength()
            self.channel3.tickLength()
            self.channel4.tickLength()
            self.channel1.tickSweep()
            break
        case 3:
            break
        case 4:
            self.channel1.tickLength()
            self.channel2.tickLength()
            self.channel3.tickLength()
            self.channel4.tickLength()
            break
        case 5:
            break
        case 6:
            self.channel1.tickLength()
            self.channel2.tickLength()
            self.channel3.tickLength()
            self.channel4.tickLength()
            self.channel1.tickSweep()
            break
        case 7:
            self.channel1.tickEnveloppe()
            self.channel2.tickEnveloppe()
            self.channel4.tickEnveloppe()
            break
        default:
            break
        }
        
        //go to next step
        self.frameSequencerStep = (self.frameSequencerStep + 1) % 8
    }
    
    /// return L and R sample by mixing each channel amplitude
    func sample() -> RawAudioSample {
        let panning = self.mmu.getAPUChannelPanning()
        let volume  = self.mmu.getMasterVolume()
        //todo handle VIN (audio comming from cartridge)
        
        //sample to build
        var leftSample:Int  = 0;
        var rightSample:Int = 0;
        
        //apply panning
        
        //CH1
        if(panning.CH1_L){
            leftSample += Int(self.channel1.amplitude)
        }
        if(panning.CH1_R){
            rightSample += Int(self.channel1.amplitude)
        }
        
        //CH2
        if(panning.CH2_L){
            leftSample += Int(self.channel2.amplitude)
        }
        if(panning.CH2_R){
            rightSample += Int(self.channel2.amplitude)
        }
        
        //CH3
        if(panning.CH3_L){
            leftSample += Int(self.channel3.amplitude)
        }
        if(panning.CH3_R){
            rightSample += Int(self.channel3.amplitude)
        }
        
        //CH4
        if(panning.CH4_L){
            leftSample += Int(self.channel4.amplitude)
        }
        if(panning.CH4_R){
            rightSample += Int(self.channel4.amplitude)
        }
        
        //return sample by applying master volume
        // divide each sample             by 4, as we have summed up all 4 channel amplitudes
        // divide volume multiplied value by 7, as volume is stored on 3 bits (max value = 0b111 -> 7)
        return (L: ((leftSample  / 4) * Int(volume.L)) / 7,
                R: ((rightSample / 4) * Int(volume.R)) / 7)
    }
    
    public func reset() {
        self.cycles = 0
        self.channel1.reset()
        self.channel2.reset()
        self.channel3.reset()
        self.channel4.reset()
    }
    
}
