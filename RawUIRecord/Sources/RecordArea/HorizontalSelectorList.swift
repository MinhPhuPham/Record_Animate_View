//
//  HorizontalSelectorList.swift
//  RawUIRecord
//
//  Created by Phu Pham on 3/10/24.
//

import SwiftUI

func generateRandomImageURLs() -> [String] {
    (1...10).compactMap { _ in
        "https://picsum.photos/id/\(Int.random(in: 1...100))/200/300"
    }
}

struct HorizontalSelectorList: View {
    @StateObject private var recordControlVM = RecordControlViewModel.shared
    @Namespace var horizontalNS
    
    var circleSize: CGFloat = 120
    
    @State private var listItems: [String]
    @State private var selectedItem: Int = 0
    
    init() {
        self._listItems = State(initialValue: generateRandomImageURLs())
    }
    
    var body: some View {
        let localSelectedItem = listItems[selectedItem]
        
        ZStack {
            SwiftUIWheelPicker($selectedItem, items: $listItems) { imageURL in
                if imageURL == localSelectedItem && recordControlVM.recordState.isRecording {
                    Color.clear.frame(width: 90, height: 90)
                } else {
                    ImageView(imageURL: imageURL, ratio: 1, width: 90)
                        .clipShape(Circle())
                        .onTapGesture {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                recordControlVM.setRecordState(.recording)
                            }
                        }
//                        .matchedGeometryEffect(id: imageURL, in: horizontalNS)
//                        .transition(.invisible)
                }
            }
            .width(.Ratio(100/ScreenHelper.width))
            .opacity(recordControlVM.recordState.isNotUnsetMode ? 0 : 1)
            
            if recordControlVM.recordState.isNotUnsetMode {
                AvatarDetail(itemURL: localSelectedItem, horizontalNS: horizontalNS)
            }
        }
        .frame(height: 120)
    }
}

private struct AvatarDetail: View {
    var itemURL: String
    let horizontalNS: Namespace.ID
    
    var body: some View {
        // Inner image
        ImageView(
            imageURL: itemURL,
            ratio: 1,
            width: 100
        )
        .clipShape(Circle())
//        .matchedGeometryEffect(id: itemURL, in: horizontalNS) // put before morphingShapes
        .morphingShapes(duration: 0.4)
    }
}

#Preview {
    ZStack {
//        Color.black.ignoresSafeArea(.all)
//        
        HorizontalSelectorList()
    }
}
