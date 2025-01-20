//
//  SlotGameView.swift
//  RawUIRecord
//
//  Created by Phu Pham on 13/1/25.
//

import SwiftUI

struct SlotGameView: View {
    let slotGameConfigure = SlotGameConfigModel(
        layoutPositionConfig: GameLayoutPositionConfigModel(
            slotMachineRawSize: CGSize(width: 1200, height: 1100),
            slotColumnRawSize: CGSize(width: 155, height: 219),
            columnsConfigs: [
                SlotMachineElementPositionModel(
                    distanceFromLeftToParent: 292,
                    distanceFromTopToParent: 466
                ),
                SlotMachineElementPositionModel(
                    distanceFromLeftToParent: 521,
                    distanceFromTopToParent: 466
                ),
                SlotMachineElementPositionModel(
                    distanceFromLeftToParent: 750,
                    distanceFromTopToParent: 466
                )
            ],
            buttonsConfigs: [
                
            ],
            playButtonConfig: SlotMachineElementPositionModel(
                widthRaw: 50,
                heightRaw: 50,
                distanceFromLeftToParent: 190,
                distanceFromTopToParent: 300
            )
        )
    )
    
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
        .environment(\.layoutPositionConfig, slotGameConfigure.layoutPositionConfig)
    }
}
