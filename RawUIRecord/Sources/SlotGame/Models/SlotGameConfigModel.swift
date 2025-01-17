//
//  SlotGameConfigModel.swift
//  RawUIRecord
//
//  Created by Phu Pham on 17/1/25.
//

struct SlotGameConfigModel {
    var backgroundImage: String = ""
    var headerImage: String = ""
    
    var gamePlayConfigure: GamePlayConfigModel = .init()
}

struct GamePlayConfigModel {
    var slotGameSelections: [SlotMachineItemModel] = Constant.slotGameSelections
    
    var delayBetweenStartAll: Double = 0.2
    var delayBetweenStopAll: Double = 0.2
}
