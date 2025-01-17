//
//  PlaySouldHelper.swift
//  RawUIRecord
//
//  Created by Phu Pham on 17/1/25.
//
import AVFoundation

class PlaySoundHelper {
    // AVAudioEngine components
    private var audioEngine: AVAudioEngine?
    private var audioPlayerNode: AVAudioPlayerNode?
    private var audioBuffer: AVAudioPCMBuffer?

    // AVPlayer component
    private var avPlayer: AVPlayer?

    private let soundName: String
    private let type: String
    private let isBigFile: Bool
    
    private var isLoop: Bool
    private var isPreloaded = false
    private var playAfterPreload = false

    deinit {
        stopSound()
        NotificationCenter.default.removeObserver(self)
    }

    init(soundName: String, type: String = "mp3", isLoop: Bool = false, volume: Float = 1.0, isBigFile: Bool = false) {
        self.soundName = soundName
        self.type = type
        self.isLoop = isLoop
        self.isBigFile = isBigFile
        
        if isBigFile {
            setupAVPlayer()
        } else {
            setupAVAudioEngine()
        }
        
        setVolume(volume)
    }
    
    private func setupAVPlayer() {
        guard let path = Bundle.main.path(forResource: soundName, ofType: type) else {
            print("ERROR: Sound file not found.")
            return
        }
        
        let fileURL = URL(fileURLWithPath: path)
        avPlayer = AVPlayer(url: fileURL)
    }

    private func setupAVAudioEngine() {
        self.audioEngine = AVAudioEngine()
        self.audioPlayerNode = AVAudioPlayerNode()
        preloadSound()
    }

    private func preloadSound() {
        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let self = self, let audioPlayerNode = self.audioPlayerNode else { return }

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
                    self.audioEngine?.attach(audioPlayerNode)
                    
                    if let bufferFormat = self.audioBuffer?.format {
                        self.audioEngine?.connect(audioPlayerNode, to: self.audioEngine!.mainMixerNode, format: bufferFormat)
                    }
                    
                    do {
                        try self.audioEngine?.start()
                        self.isPreloaded = true
                        if self.playAfterPreload {
                            self.playSound(self.isLoop)
                        }
                    } catch {
                        print("Audio engine couldn't start: \(error.localizedDescription)")
                    }
                }
            } catch {
                print("ERROR: Could not load the sound file: \(error.localizedDescription)")
            }
        }
    }

    func playSound(_ isLoop: Bool = false, volume: Float = 1.0) {
        setVolume(volume)

        if isBigFile {
            guard let avPlayer = avPlayer else { return }
            avPlayer.play()

            if isLoop {
                NotificationCenter.default.addObserver(self, selector: #selector(itemDidFinishPlaying),
                                                       name: .AVPlayerItemDidPlayToEndTime, object: avPlayer.currentItem)
            }
        } else {
            guard isPreloaded, let audioBuffer = audioBuffer, let audioPlayerNode = audioPlayerNode else {
                // If not preloaded, store playback intent
                self.playAfterPreload = true
                self.isLoop = isLoop
                return
            }
            
            if audioPlayerNode.isPlaying {
                audioPlayerNode.stop()
            }

            let options: AVAudioPlayerNodeBufferOptions = isLoop ? .loops : []
            audioPlayerNode.scheduleBuffer(audioBuffer, at: nil, options: options, completionHandler: nil)
            audioPlayerNode.play()
        }
    }

    @objc private func itemDidFinishPlaying() {
        avPlayer?.seek(to: .zero)
        avPlayer?.play()
    }

    func stopSound() {
        if isBigFile {
            avPlayer?.pause()
        } else {
            if let audioPlayerNode = audioPlayerNode, audioPlayerNode.isPlaying {
                audioPlayerNode.stop()
            }
            audioEngine?.stop()
        }
    }

    private func setVolume(_ volume: Float) {
        if volume >= 1.0 {
            return
        }
        
        if isBigFile {
            avPlayer?.volume = min(max(volume, 0.0), 1.0)
        } else {
            audioPlayerNode?.volume = min(max(volume, 0.0), 1.0)
        }
    }
}

