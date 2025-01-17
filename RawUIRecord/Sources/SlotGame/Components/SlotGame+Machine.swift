//
//  SlotGame+Machine.swift
//  RawUIRecord
//
//  Created by Phu Pham on 15/1/25.
//

import SwiftUI

struct SlotGameMachineView: View {
    @StateObject private var slotGameVM = SlotGameViewModel()
    
    private func viewDidLoad() {
        DispatchQueue.main.async { [weak slotGameVM] in
            slotGameVM?.musicPlayer[.backgroundSound]?.playSound()
        }
    }
    
    var body: some View {
        VStack(spacing: 30) {
            SlotGameWinningControl()
            
            SlotGameMachineElement()
            
            SlotGameSpinButton()
        }
        .environmentObject(slotGameVM)
        .onAppear {
            viewDidLoad()
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

