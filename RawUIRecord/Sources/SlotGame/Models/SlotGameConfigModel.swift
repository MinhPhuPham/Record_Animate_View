//
//  SlotGameConfigModel.swift
//  RawUIRecord
//
//  Created by Phu Pham on 17/1/25.
//
 
import SwiftUI

struct SlotGameConfigModel {
    var backgroundImage: String = ""
    var headerImage: String = ""
    
    var layoutPositionConfig: GameLayoutPositionConfigModel
    
    var gamePlayConfigure: GamePlayConfigModel = .init()
}

struct GamePlayConfigModel {
    var slotGameSelections: [SlotMachineItemModel] = Constant.slotGameSelections
    
    var delayBetweenStartAll: Double = 0.2
    var delayBetweenStopAll: Double = 0.2
}

struct GameLayoutPositionConfigModel {
    var slotMachineRawSize: CGSize = .zero
    var columnsConfigs: [SlotMachineElementPositionModel]
    var buttonsConfigs: [SlotMachineElementPositionModel]
    var playButtonConfig: SlotMachineElementPositionModel
    
    init(
        slotMachineRawSize: CGSize,
        slotColumnRawSize: CGSize,
        columnsConfigs: [SlotMachineElementPositionModel],
        buttonsConfigs: [SlotMachineElementPositionModel],
        playButtonConfig: SlotMachineElementPositionModel
    ) {
        self.slotMachineRawSize = slotMachineRawSize
        
        self.columnsConfigs = columnsConfigs.map { column in
            var updatedColumn = column
            updatedColumn.widthRaw = slotColumnRawSize.width
            updatedColumn.heightRaw = slotColumnRawSize.height
            updatedColumn.slotMachineRawSize = slotMachineRawSize
            
            return updatedColumn
        }
        
        self.buttonsConfigs = columnsConfigs.map { column in
            var updatedColumn = column
            updatedColumn.slotMachineRawSize = slotMachineRawSize
            return updatedColumn
        }
        
        self.playButtonConfig = playButtonConfig
        self.playButtonConfig.slotMachineRawSize = slotMachineRawSize
    }
}

struct SlotMachineElementPositionModel {
    var slotMachineRawSize: CGSize = .zero
    
    var widthRaw: CGFloat = 0
    var heightRaw: CGFloat = 0
    
    var widthRatioWithParent: Double {
        return  widthRaw / slotMachineRawSize.width
    }
    
    var heightRatioWithParent: Double {
        heightRaw / slotMachineRawSize.height
    }
    
    // From left image to left parent image
    var distanceFromLeftToParent: Double
    // From top image to top parent image
    var distanceFromTopToParent: Double
    
    var xRatio: Double {
        distanceFromLeftToParent / slotMachineRawSize.width
    }
    
    var yRatio: Double {
        distanceFromTopToParent / slotMachineRawSize.height
    }
}
