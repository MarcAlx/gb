public class APU: Component, Clockable {
    
    public private(set) var cycles:Int = 0
    
    private let mmu:MMU
    
    private var frameSequencerCounter:Int = 0
    
    private var frameSequencerStep:Int = 0
    
    private let channel1:SquareWithSweepChannel
    private let channel2:SquareChannel
    private let channel3:WaveChannel
    private let channel4:NoiseChannel
    
    init(mmu:MMU) {
        self.mmu = mmu
        self.channel1 = Sweep(mmu: self.mmu)
        self.channel2 = Pulse(mmu: self.mmu)
        self.channel3 = Wave(mmu: self.mmu)
        self.channel4 = Noise(mmu: self.mmu)
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
    func sample() -> (L:Int, R:Int) {
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
