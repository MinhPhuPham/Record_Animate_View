//
//  PlaySouldHelper.swift
//  RawUIRecord
//
//  Created by Phu Pham on 17/1/25.
//
import AVFoundation

class PlaySoundHelper {
    private let audioEngine = AVAudioEngine()
    private let audioPlayerNode = AVAudioPlayerNode()
    private var audioBuffer: AVAudioPCMBuffer?
    private let soundName: String
    private let type: String

    private var isLoop: Bool
    private var isPreloaded = false
    private var playAfterPreload = false

    deinit {
        stopSound()
    }

    init(soundName: String, type: String = "mp3", isLoop: Bool = false, volume: Float = 1.0) {
        self.soundName = soundName
        self.type = type
        self.isLoop = isLoop
        preloadSound()

        setVolume(volume)
    }

    private func preloadSound() {
        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let self = self else { return }

            guard let path = Bundle.main.path(forResource: self.soundName, ofType: self.type),
                  let fileURL = URL(string: path) else {
                print("ERROR: Sound file not found.")
                return
            }

            do {
                let audioFile = try AVAudioFile(forReading: fileURL)
                let format = audioFile.processingFormat
                let frameCount = AVAudioFrameCount(audioFile.length)
                self.audioBuffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount)
                try audioFile.read(into: self.audioBuffer!)

                DispatchQueue.main.async {
                    self.setupAudioEngine()
                    self.isPreloaded = true
                    if self.playAfterPreload {
                        self.playSound(self.isLoop)
                    }
                }
            } catch {
                print("ERROR: Could not load the sound file: \(error.localizedDescription)")
            }
        }
    }

    private func setupAudioEngine() {
        audioEngine.attach(audioPlayerNode)

        if let bufferFormat = audioBuffer?.format {
            audioEngine.connect(audioPlayerNode, to: audioEngine.mainMixerNode, format: bufferFormat)
        }

        do {
            try audioEngine.start()
        } catch {
            print("Audio engine couldn't start: \(error.localizedDescription)")
        }
    }

    func playSound(_ isLoop: Bool = false, volume: Float = 1.0) {
        guard isPreloaded else {
            // If not preloaded, store playback intent
            self.playAfterPreload = true
            self.isLoop = isLoop
            return
        }

        guard let audioBuffer = audioBuffer else {
            print("Attempted to play sound before it was preloaded.")
            return
        }

        if audioPlayerNode.isPlaying {
            audioPlayerNode.stop()
        }

        setVolume(volume)

        let options: AVAudioPlayerNodeBufferOptions = isLoop ? .loops : []
        audioPlayerNode.scheduleBuffer(audioBuffer, at: nil, options: options, completionHandler: nil)
        audioPlayerNode.play()
    }

    func stopSound() {
        if audioPlayerNode.isPlaying {
            audioPlayerNode.stop()
        }
        audioEngine.stop()
    }

    private func setVolume(_ volume: Float) {
        if volume >= 1.0 {
            return
        }
        
        audioPlayerNode.volume = min(max(volume, 0.0), 1.0) // Clamps the volume between 0.0 and 1.0
    }
}
