//
//  SlideshowPageIndicator.swift
//  RawUIRecord
//
//  Created by Phu Pham on 13/11/24.
//

import SwiftUI

struct SnapCarouselPageIndicatorConfig {
    var normalSize: CGFloat = 8
    var selectedSize: CGFloat = 22
    var dotColor: Color = .gray
    
    var pageIndicatorOffsetY: CGFloat = 20
}

struct SnapCarouselPageIndicatorView: View {
    @Binding var selectedIndex: Int
    
    var pageCount: Int
    var config: SnapCarouselPageIndicatorConfig = .init()
    
    var body: some View {
        // Custom pager Indicator
        HStack {
            ForEach(0..<pageCount, id: \.self) { index in
                
                Button(role: .none, action: {
                    self.selectedIndex = index
                }) {
                    Capsule()
                        .fill(config.dotColor)
                        .opacity(index == selectedIndex ? 0.6 : 0.25)
                        .frame(width: index == selectedIndex ? config.selectedSize : config.normalSize, height: config.normalSize)
                        .animation(.easeInOut, value: selectedIndex)
                }
            }
            
        }.offset(y: config.normalSize + config.pageIndicatorOffsetY)
    }
}
