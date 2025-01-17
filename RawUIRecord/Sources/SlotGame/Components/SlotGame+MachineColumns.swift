//
//  SlotGame+SlotGameMachineColumns.swift
//  RawUIRecord
//
//  Created by Phu Pham on 15/1/25.
//

import SwiftUI

struct SlotGameMachineColumns: View {
    @Environment(\.layoutPositionConfig) var layoutPositionConfig
    var proxyReader: GeometryProxy
    
    var body: some View {
        Group {
            ForEach(0..<3, id: \.self) { index in
                SlotGameColumn(
                    index: index,
                    proxyReader: proxyReader,
                    columnConfig: layoutPositionConfig.columnsConfigs[index]
                )
                .onAppear {
                    print("layoutPositionConfig.columnsConfigs[index]", layoutPositionConfig.columnsConfigs[index],
                          layoutPositionConfig.columnsConfigs[index].xRatio, layoutPositionConfig.columnsConfigs[index].yRatio)
                }
            }
        }
    }
}

private struct SlotGameColumn: View {
    let index: Int
    var proxyReader: GeometryProxy
    let columnConfig: SlotMachineElementPositionModel
    
    var body: some View {
        SlotColumnInfiniteUIScrollView(
            index: index,
            configure: .init(
                scrollSpeed: 30.0
            )
        )
        .frame(
            width: proxyReader.size.width * columnConfig.widthRatioWithParent,
            height: proxyReader.size.height * columnConfig.heightRatioWithParent,
            alignment: .center
        )
        .offset(
            x: proxyReader.size.width * columnConfig.xRatio,
            y: proxyReader.size.height * columnConfig.yRatio
        )
        .background(Color.yellow.opacity(0.3))
        .onAppear {
            print("ValueY", proxyReader.size.height * columnConfig.yRatio)
        }
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
