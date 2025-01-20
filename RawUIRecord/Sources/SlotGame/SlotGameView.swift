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
            slotButtonControlSize: CGSize(width: 140, height: 75),
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
                SlotMachineElementPositionModel(
                    distanceFromLeftToParent: 133,
                    distanceFromTopToParent: 880
                ),
                SlotMachineElementPositionModel(
                    distanceFromLeftToParent: 292,
                    distanceFromTopToParent: 880
                ),
                SlotMachineElementPositionModel(
                    distanceFromLeftToParent: 452,
                    distanceFromTopToParent: 880
                )
            ],
            playButtonConfig: SlotMachineElementPositionModel(
                widthRaw: 188,
                heightRaw: 74,
                distanceFromLeftToParent: 878,
                distanceFromTopToParent: 880
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
        .environment(\.gamePlayConfig, slotGameConfigure.gamePlayConfigure)
    }
}
