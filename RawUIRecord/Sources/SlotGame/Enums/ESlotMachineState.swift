//
//  ESlotMachineState.swift
//  RawUIRecord
//
//  Created by Phu Pham on 17/1/25.
//

import SwiftUI

enum ESlotMachineState {
    case unset
    case spining
    case played
    
    var isSpining: Bool {
        self == .spining
    }
}
