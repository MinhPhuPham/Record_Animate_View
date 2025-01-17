//
//  SlotGame+SlotGameMachineColumns.swift
//  RawUIRecord
//
//  Created by Phu Pham on 15/1/25.
//

import SwiftUI

struct SlotGameMachineColumns: View {
    @EnvironmentObject private var slotMachineVM: SlotMachineViewModel
    
    var body: some View {
        HStack {
            ForEach(0..<3, id: \.self) { index in
                SlotGameColumn(
                    reference: slotMachineVM.references[index],
                    onScrollStopedAt: slotMachineVM.onScrollStopedAt
                )
            }
        }
    }
}

private struct SlotGameColumn: View {
    let reference: ContinuousInfiniteReference<ContinuousInfiniteCollectionView>
    let data: [ContinuousInfiniteModel] = SlotMachineViewModel.data
    var onScrollStopedAt: (Int?) -> Void
    
    var body: some View {
        SlotColumnInfiniteUIScrollView(
            reference: reference,
            models: data,
            configure: .init(
                scrollSpeed: 30.0
            ),
            onScrollStopedAt: onScrollStopedAt
        )
        .frame(width: 80, height: 140)
    }
}

class ContinuousInfiniteReference<T: AnyObject> {
    weak var object: T?
}

private struct SlotColumnInfiniteUIScrollView: UIViewControllerRepresentable {
    let reference: ContinuousInfiniteReference<ContinuousInfiniteCollectionView>
    
    var models: [ContinuousInfiniteModel]
    // Additional variables
    var configure: CongfigureContinuousInfinite
    var onScrollStopedAt: (Int?) -> Void
    
    func makeUIViewController(context: Context) -> ContinuousInfiniteCollectionView {
        let continousInfiniteCollectionView = ContinuousInfiniteCollectionView(models: models, configure: configure)
        
        reference.object = continousInfiniteCollectionView
        continousInfiniteCollectionView.onScrollStopedAt = { index in
            onScrollStopedAt(index)
        }
        
        return continousInfiniteCollectionView
    }
    
    func updateUIViewController(_ container: ContinuousInfiniteCollectionView, context: Context) {
        
    }
}
