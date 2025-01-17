//
//  ESlotMachineState.swift
//  RawUIRecord
//
//  Created by Phu Pham on 17/1/25.
//

import SwiftUI

enum ESlotMachineState {
    case unset
    case playingStarting
    case playing
    case playingEnding
    case played
    
    var isPlaying: Bool {
        self == .playing
    }
    
    var isBlockingSpinBtn: Bool {
        self == .playingEnding || self == .playingStarting
    }
}
