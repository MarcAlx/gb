import SwiftUI
import AVFoundation
import GBKit

/// manager responsible to play audio
class AudioManager {
    @EnvironmentObject private var lVM:LoggingViewModel
    
    /// engine that will ensure audio rendering
    private let engine = AVAudioEngine()
    
    /// player that will ensure playback
    private let playerNode = AVAudioPlayerNode()
    
    // audio sample rate
    private let sampleRate: Int
    
    /// two channels L and R
    private let channels: AVAudioChannelCount = 2
    
    private let gameboy: GameBoy
    
    init(frequency:Int, gb:GameBoy) {
        self.sampleRate = frequency
        self.gameboy = gb
        
        // Set up audio session (especially important on iOS)
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
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
            bufferSize: 1024,
            normalizationMethod: .FLOAT_MINUS_1_TO_1,
            playback: self.playBack)
    }
    
    /// called by APU once buffer size has been reached
    func playBack(buffer:[AudioSample]){
        // Calculate number of frames from the sample count.
        let frameCount = AVAudioFrameCount(buffer.count)
        guard let format = AVAudioFormat(standardFormatWithSampleRate: Double(sampleRate), channels: channels),
              let res = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount) else {
            return
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
        
        // Schedule the buffer for playback.
        playerNode.scheduleBuffer(res, completionHandler: nil)
        // If not already playing, start playback.
        if !playerNode.isPlaying {
            playerNode.play()
        }
    }
}
