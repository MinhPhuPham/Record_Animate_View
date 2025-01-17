//
//  SlotGame+Machine.swift
//  RawUIRecord
//
//  Created by Phu Pham on 15/1/25.
//

import SwiftUI

struct SlotGameMachineView: View {
    var body: some View {
        VStack(spacing: 30) {
            SlotGameWinningControl()
            
            SlotGameMachineElement()
            
            SlotGameSpinButton()
        }
    }
}

private struct SlotGameMachineElement: View {
    var body: some View {
        ZStack {
//            Image("slot_machine")
//                .resizable()
//                .scaledToFit()
//                .frame(maxWidth: ScreenHelper.width * 0.9, maxHeight: ScreenHelper.height * 0.8, alignment: .center)
            
            SlotGameMachineColumns()
        }
    }
}

