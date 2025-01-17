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
    @EnvironmentObject private var slotMachineVM: SlotMachineViewModel
    
    let index: Int
    
    var models: [ContinuousInfiniteModel] = Constant.slotGameSelections
    // Additional variables
    var configure: CongfigureContinuousInfinite
    
    func makeUIViewController(context: Context) -> ContinuousInfiniteCollectionView {
        let continousInfiniteCollectionView = ContinuousInfiniteCollectionView(
            models: models,
            configure: configure
        )
        
        slotMachineVM.references[index].object = continousInfiniteCollectionView
        
        continousInfiniteCollectionView.onScrollStopedAt = { [weak slotMachineVM] index in
            slotMachineVM?.onScrollStopedAt(index)
        }
        
        return continousInfiniteCollectionView
    }
    
    func updateUIViewController(_ container: ContinuousInfiniteCollectionView, context: Context) {
        container.setWinningState(slotMachineVM.winningState)
    }
}
