//
//  SlotGameView.swift
//  RawUIRecord
//
//  Created by Phu Pham on 13/1/25.
//

import SwiftUI

struct SlotGameView: View {
    @StateObject private var slotMachineVM = SlotMachineViewModel()
    
//    private func viewDidLoad() {
//        DispatchQueue.main.async { [weak slotMachineVM] in
//            slotMachineVM?.musicPlayer[.backgroundSound]?.playSound()
//        }
//    }
    
    var body: some View {
        ZStack {
            SlotGameBackgroundView()
            
            SlotGameContent()
        }
        .environmentObject(slotMachineVM)
//        .onAppear {
//            viewDidLoad()
//        }
    }
}

private struct SlotGameContent: View {
    var body: some View {
        VStack(alignment: .center, spacing: 5) {
            SlotGameLogoView()

            Spacer()

            // Slot Machine
            SlotGameMachineView()
            
            Spacer()
        }
    }
}
