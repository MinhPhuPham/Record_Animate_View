//
//  PlaySoundViewModel.swift
//  RawUIRecord
//
//  Created by Phu Pham on 15/1/25.
//

import AVFoundation

class PlaySouldHelper {
    var audioPlayer: AVAudioPlayer?
    
    deinit {
        audioPlayer?.stop()
        audioPlayer = nil
    }

    // Set this to -1 to loop the sound indefinitely
    func playSound(sound: String, type: String = "mp3", numberOfLoops: Int = 0) {
        if let path = Bundle.main.path(forResource: sound, ofType: type) {
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: path))
                audioPlayer?.numberOfLoops = numberOfLoops
                audioPlayer?.prepareToPlay()
                audioPlayer?.play()
            } catch {
                print("ERROR: Could not find and play the sound file!")
            }
        } else {
            print("ERROR: Sound file not found.")
        }
    }
    
    func stopSound() {
        audioPlayer?.stop()
    }
}

class PlaySoundViewModel: ObservableObject {
    var playsouldHelper = PlaySouldHelper()
    
    func playSound(sound: String, type: String, numberOfLoops: Int = 0) {
        playsouldHelper.playSound(sound: sound, type: type, numberOfLoops: numberOfLoops)
    }
    
    func stopSound() {
        playsouldHelper.audioPlayer?.stop()
    }
}
