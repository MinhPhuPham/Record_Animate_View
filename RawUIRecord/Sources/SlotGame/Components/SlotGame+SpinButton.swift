//
//  SlotGame+SpinButton.swift
//  RawUIRecord
//
//  Created by Phu Pham on 15/1/25.
//

import SwiftUI

struct SlotGameSpinButton: View {
    @EnvironmentObject private var slotGameVM: SlotGameViewModel
    
    private var spningText: String {
        switch slotGameVM.spiningState {
        case .unset:
            "Spin"
        case .playingStarting:
            "Starting..."
        case .playing:
            "Stop all"
        case .playingEnding:
            "Ending..."
        case .played:
            "↪ Play again"
        }
    }
    
    var body: some View {
        VStack(spacing: 45) {
            HStack {
                ForEach(0..<3, id: \.self) { index in
                    SlotGameStopButton(index: index, onStopClick: { [weak slotGameVM] in
                        slotGameVM?.stopScrollingForElement(at: index)
                    })
                }
            }
            .disabled(!slotGameVM.spiningState.isPlaying)
            .opacity(slotGameVM.spiningState.isPlaying ? 1 : 0.6)
            
            Button(action: slotGameVM.clickSpinButton) {
                Text(spningText)
                    .font(.headline)
                    .foregroundColor(.green)
                    .padding(.vertical, 8)
                    .padding(.horizontal)
            }
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.green, lineWidth: 3) // green outline with width of 3
            )
            .disabled(slotGameVM.spiningState.isBlockingSpinBtn)
        }
        .padding(.top, 10)
    }
}

private struct SlotGameStopButton: View {
    let index: Int
    let onStopClick: () -> Void
    
    var body: some View {
        Button(action: onStopClick) {
            Text("Stop line \(index + 1)")
                .foregroundColor(.appNotification)
                .padding(.vertical, 5)
                .padding(.horizontal, 10)
        }
        .background(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.appNotification, lineWidth: 3) // green outline with width of 3
        )
    }
}
