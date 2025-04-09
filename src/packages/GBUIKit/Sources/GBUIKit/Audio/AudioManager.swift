import SwiftUI
import AVFoundation
import GBKit

/// manager responsible to play audio
class AudioManager {
    @EnvironmentObject private var lVM:LoggingViewModel
    
    /// engine that will ensure audio rendering
    private let engine:AVAudioEngine = AVAudioEngine()
    
    /// player that will ensure playback
    private let playerNode:AVAudioPlayerNode = AVAudioPlayerNode()
    
    // audio sample rate
    private let sampleRate: Int
    
    /// two channels L and R
    private let channels: AVAudioChannelCount = 2
    
    /// gameboy to which audio is setup
    private let gameboy: GameBoy
    
    /// workQueue to ensure high qos dispatch
    private let workQueue:DispatchQueue
    
    /// samples ready to play
    private var audioQueue:[[AudioSample]] = []
    
    /// number of sample required for playing
    private let queueFloor = 10
    
    /// buffer size
    private let bufferSize = 1024
    
    init(frequency:Int, gb:GameBoy) {
        
        self.workQueue = DispatchQueue(label: "gb audio queue", qos:.userInteractive)
        self.sampleRate = frequency
        self.gameboy = gb
        
        // Set up audio session (especially important on iOS)
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
            try AVAudioSession.sharedInstance().setPreferredIOBufferDuration(TimeInterval(self.bufferSize/self.sampleRate))
        } catch {
            self.lVM.log("Failed to set up AVAudioSession: \(error)")
        }
        
        // Attach and connect the player node.
        engine.attach(playerNode)
        guard let format = AVAudioFormat(standardFormatWithSampleRate: Double(sampleRate), channels: channels) else {
            fatalError("Unable to create audio format")
        }
        
        engine.connect(playerNode, to: engine.mainMixerNode, format: format)
        
        // Start the engine.
        do {
            try engine.start()
        } catch {
            self.lVM.log("Error starting engine: \(error)")
        }
        
        self.engine.mainMixerNode.volume = 1.0
        self.playerNode.volume = 1.0
        
        //configure APU
        self.gameboy.apuConfiguration = APUConfiguration(
            sampleRate: self.sampleRate,
            bufferSize: self.bufferSize,
            normalizationMethod: .FLOAT_MINUS_1_TO_1,
            playback: self.enqueueBuffer)
    }
    
    ///queue a buffer
    private func enqueueBuffer(buffer:[AudioSample]) {
        //store sample
        self.audioQueue.append(buffer)
        //we have enough sample queued -> play
        //not playing or enough buffer
        if self.playerNode.isPlaying == false || self.audioQueue.count > self.queueFloor {
            self.playBack()
        }
    }
    
    /// dequeue and play next buffer
    private func playBack(){
        //prevent playback if no sample
        //guard self.audioQueue.count > 0 else { return }
        while(self.audioQueue.count > 0){
            //remove sample to play
            let next = self.audioQueue.removeFirst()
            //prepare
            let toPlay = self.convertAudioSamples(buffer: next)
            //schedule play on workqueue
            self.workQueue.async {
                //schedule doesn't cancel current playback but queue it
                self.playerNode.scheduleBuffer(toPlay, completionHandler: {
                    //try playback once schedule
                    self.playBack()
                })
                
                //only start playing when we have start scheduling
                if(!self.playerNode.isPlaying) {
                    self.playerNode.play()
                }
            }
        }
    }
    
    /// convert audio samples to AVAudioPCMBuffer
    private func convertAudioSamples(buffer:[AudioSample]) -> AVAudioPCMBuffer {
        // Calculate number of frames from the sample count.
        let frameCount = AVAudioFrameCount(buffer.count)
        guard let format = AVAudioFormat(standardFormatWithSampleRate: Double(sampleRate), channels: channels),
              let res = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount)
        else {
            return AVAudioPCMBuffer()
        }
        
        res.frameLength = frameCount
        
        // buffer.floatChannelData returns an UnsafeMutablePointer for each channel.
        if let channelData = res.floatChannelData {
            //interleaved Audio samples into channel data
            for frame in 0..<Int(frameCount) {
                // Left channel
                channelData[0][frame] = buffer[frame].L
                // Right channel
                channelData[1][frame] = buffer[frame].R
            }
        }
        
        return res
    }
}
