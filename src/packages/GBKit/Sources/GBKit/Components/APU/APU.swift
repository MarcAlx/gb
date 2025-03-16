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
        self.channel1 = Channel1()
        self.channel2 = Channel2()
        self.channel3 = Channel3()
        self.channel4 = Channel4()
    }
    
    public func tick(_ masterCycles: Int, _ frameCycles: Int) {
        if(self.frameSequencerCounter >= GBConstants.APUFrameSequencerStepLength){
            self.stepFrameSequencer()
            self.frameSequencerCounter = 0
        }
        else {
            self.frameSequencerCounter = self.frameSequencerCounter &+ 4
        }
        
        self.cycles = self.cycles &+ 4
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
            self.channel3.tickVolume()
            self.channel4.tickEnveloppe()
            break
        default:
            break
        }
        
        //go to next step
        self.frameSequencerStep = (self.frameSequencerStep + 1) % 8
    }
    
    func reset() {
        self.cycles = 0
    }
    
}
