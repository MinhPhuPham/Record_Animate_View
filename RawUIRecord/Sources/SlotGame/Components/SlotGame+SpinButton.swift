//
//  SlotGame+SpinButton.swift
//  RawUIRecord
//
//  Created by Phu Pham on 15/1/25.
//

import SwiftUI

struct SlotGameSpinButton: View {
    @EnvironmentObject private var slotGameVM: SlotGameViewModel
    
    @Environment(\.layoutPositionConfig) var layoutPositionConfig
    var parentSize: CGSize
    
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
            "↪ Again"
        }
    }
    
    var body: some View {
        Group {
            ForEach(0..<3, id: \.self) { index in
                SlotGameStopButton(
                    index: index,
                    parentSize: parentSize,
                    buttonPosition: layoutPositionConfig.buttonsConfigs[index],
                    onStopClick: { [weak slotGameVM] in
                    slotGameVM?.stopScrollingForElement(at: index)
                })
            }
        }
        .disabled(!slotGameVM.spiningState.isPlaying)
        .opacity(slotGameVM.spiningState.isPlaying ? 1 : 0.6)
        
        Button(action: slotGameVM.clickSpinButton) {
            Text(spningText)
                .font(.footnote)
                .foregroundColor(.white)
                .frame(
                    width: parentSize.width * layoutPositionConfig.playButtonConfig.widthRatioWithParent,
                    height: parentSize.height * layoutPositionConfig.playButtonConfig.heightRatioWithParent,
                    alignment: .center
                )
        }
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.orange)
        )
        .disabled(slotGameVM.spiningState.isBlockingSpinBtn)
        .frameSetting(parentSize: parentSize, elementConfigFrame: layoutPositionConfig.playButtonConfig)
    }
}

private struct SlotGameStopButton: View {
    let index: Int
    var parentSize: CGSize
    let buttonPosition: SlotMachineElementPositionModel
    let onStopClick: () -> Void
    
    var body: some View {
        Button(action: onStopClick) {
            Text("\(index + 1)")
                .foregroundColor(.white)
                .frame(
                    width: parentSize.width * buttonPosition.widthRatioWithParent,
                    height: parentSize.height * buttonPosition.heightRatioWithParent,
                    alignment: .center
                )
        }
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.orange)
        )
        .frameSetting(parentSize: parentSize, elementConfigFrame: buttonPosition)
    }
}
