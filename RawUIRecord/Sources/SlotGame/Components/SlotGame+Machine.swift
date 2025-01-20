//
//  SlotGame+Machine.swift
//  RawUIRecord
//
//  Created by Phu Pham on 15/1/25.
//

import SwiftUI

struct SlotGameMachineView: View {
    @StateObject private var slotGameVM: SlotGameViewModel
    
    init(slotGamePlayConfig: GamePlayConfigModel) {
        self._slotGameVM = StateObject(wrappedValue: SlotGameViewModel(configure: slotGamePlayConfig))
    }
    
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
            Image("slot_machine")
                .resizable()
                .scaledToFit()
                .overlay(
                    GeometryReader { proxyReader in
                        SlotGameMachineColumns(proxyReader: proxyReader)
                    }
                )
        }
        .frame(height: ScreenHelper.width * 0.8, alignment: .center)
    }
}

