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
            slotMachineRawSize: CGSize(width: 260, height: 320),
            columnsConfigs: [
                SlotMachineElementPositionModel(
                    widthRaw: 60,
                    heightRaw: 200,
                    distanceFromLeftToParent: 20,
                    distanceFromTopToParent: 80
                ),
                SlotMachineElementPositionModel(
                    widthRaw: 60,
                    heightRaw: 200,
                    distanceFromLeftToParent: 90,
                    distanceFromTopToParent: 80
                ),
                SlotMachineElementPositionModel(
                    widthRaw: 60,
                    heightRaw: 200,
                    distanceFromLeftToParent: 170,
                    distanceFromTopToParent: 80
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
