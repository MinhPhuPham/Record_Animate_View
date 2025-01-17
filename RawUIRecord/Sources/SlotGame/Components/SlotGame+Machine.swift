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
        GeometryReader { proxyReader in
            ZStack {
                Image("slot_machine")
                    .resizable()
                    .scaledToFit()
                    .frame(width: proxyReader.size.width, height: proxyReader.size.height, alignment: .center)
                
                SlotGameMachineColumns(proxyReader: proxyReader)
                    .frame(width: proxyReader.size.width, height: proxyReader.size.height, alignment: .center)
                    .background(Color.red.opacity(0.3))
            }
            .onAppear {
                print("proxyReader", proxyReader.size, ScreenHelper.width, ScreenHelper.height)
            }
        }
        .frame(height: ScreenHelper.width * 0.7, alignment: .center)
        .background(Color.white.opacity(0.3))
    }
}

