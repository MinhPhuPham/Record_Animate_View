//
//  SlotGame+SlotGameMachineColumns.swift
//  RawUIRecord
//
//  Created by Phu Pham on 15/1/25.
//

import SwiftUI

struct SlotGameMachineColumns: View {
    var body: some View {
        HStack {
            ForEach(0..<3, id: \.self) { index in
                SlotGameColumn(index: index)
            }
        }
    }
}

private struct SlotGameColumn: View {
    let index: Int
    
    var body: some View {
        SlotColumnInfiniteUIScrollView(
            index: index,
            configure: .init(
                scrollSpeed: 30.0
            )
        )
        .frame(width: 80, height: 140)
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
