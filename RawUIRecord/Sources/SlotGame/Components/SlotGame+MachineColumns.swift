//
//  SlotGame+SlotGameMachineColumns.swift
//  RawUIRecord
//
//  Created by Phu Pham on 15/1/25.
//

import SwiftUI

struct SlotGameMachineColumns: View {
    @Environment(\.layoutPositionConfig) var layoutPositionConfig
    var parentSize: CGSize
    
    var body: some View {
        ForEach(0..<3, id: \.self) { index in
            SlotGameColumn(
                index: index,
                parentSize: parentSize,
                columnConfig: layoutPositionConfig.columnsConfigs[index]
            )
        }
    }
}

private struct SlotGameColumn: View {
    let index: Int
    var parentSize: CGSize
    let columnConfig: SlotMachineElementPositionModel
    
    var body: some View {
        SlotColumnInfiniteUIScrollView(
            index: index,
            configure: .init(
                visibleItemsCount: 1,
                scrollSpeed: 30.0
            )
        )
        .background(Color.white)
        .frameSetting(parentSize: parentSize, elementConfigFrame: columnConfig)
    }
}

class ContinuousInfiniteReference<T: AnyObject> {
    weak var object: T?
}

private struct SlotColumnInfiniteUIScrollView: UIViewControllerRepresentable {
    @EnvironmentObject private var slotGameVM: SlotGameViewModel
    
    let index: Int
    
    var models: [SlotMachineItemModel] = Constant.slotGameSelections
    // Additional variables
    var configure: SlotMachineCongfigure
    
    func makeUIViewController(context: Context) -> SlotMachineAutoScrollView {
        let continousInfiniteCollectionView = SlotMachineAutoScrollView(
            models: models,
            configure: configure
        )
        
        slotGameVM.references[index].object = continousInfiniteCollectionView
        
        continousInfiniteCollectionView.onScrollStopedAt = { [weak slotGameVM] index in
            slotGameVM?.onScrollStopedAt(index)
        }
        
        return continousInfiniteCollectionView
    }
    
    func updateUIViewController(_ container: SlotMachineAutoScrollView, context: Context) {
        container.setWinningState(slotGameVM.winningState)
    }
}
