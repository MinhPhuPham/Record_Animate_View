//
//  SlotGame+WinningControl.swift
//  RawUIRecord
//
//  Created by Phu Pham on 16/1/25.
//

import SwiftUI

struct SlotGameWinningControl: View {
    @EnvironmentObject private var slotGameVM: SlotGameViewModel

    var body: some View {
        Toggle(isOn: $slotGameVM.winningState.isWinning) {
            Text("Winning:")
                .font(.headline.weight(.medium))
                .foregroundColor(Color.white)
        }
        .controlSize(.small)
        .toggleStyle(.switch)
        .frame(width: 150)
    }
}
