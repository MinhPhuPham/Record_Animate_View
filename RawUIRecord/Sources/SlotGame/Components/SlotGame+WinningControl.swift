//
//  SlotGame+WinningControl.swift
//  RawUIRecord
//
//  Created by Phu Pham on 16/1/25.
//

import SwiftUI

struct SlotGameWinningControl: View {
    @EnvironmentObject private var slotMachineVM: SlotMachineViewModel

    var body: some View {
        Toggle(isOn: $slotMachineVM.winningState.isWinning) {
            Text("isWinning:")
                .font(.headline.weight(.medium))
                .foregroundColor(Color.white)
        }
        .controlSize(.small)
        .toggleStyle(.switch)
        .frame(width: 150)
    }
}
