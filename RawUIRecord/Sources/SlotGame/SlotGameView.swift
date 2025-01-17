//
//  SlotGameView.swift
//  RawUIRecord
//
//  Created by Phu Pham on 13/1/25.
//

import SwiftUI

struct SlotGameView: View {
    let slotGameConfigure: SlotGameConfigModel = .init()
    
    var body: some View {
        ZStack {
            SlotGameBackgroundView()
            
            VStack(alignment: .center, spacing: 30) {
                SlotGameLogoView()

                // Slot Machine
                SlotGameMachineView(slotGamePlayConfig: slotGameConfigure.gamePlayConfigure)
                
                Spacer()
            }
        }
    }
}
