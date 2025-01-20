//
//  FrameElementWithPositionModifier.swift
//  RawUIRecord
//
//  Created by Phu Pham on 20/1/25.
//

import SwiftUI

struct FrameElementWithPositionModifier: ViewModifier {
    var parentSize: CGSize
    let elementConfigFrame: SlotMachineElementPositionModel

    func body(content: Content) -> some View {
        content
            .frame(
                width: parentSize.width * elementConfigFrame.widthRatioWithParent,
                height: parentSize.height * elementConfigFrame.heightRatioWithParent,
                alignment: .center
            )
            .offset(
                x: parentSize.width * elementConfigFrame.xRatio,
                y: parentSize.height * elementConfigFrame.yRatio
            )
    }
}

extension View {
    func frameSetting(parentSize: CGSize, elementConfigFrame: SlotMachineElementPositionModel) -> some View {
        self.modifier(
            FrameElementWithPositionModifier(parentSize: parentSize, elementConfigFrame: elementConfigFrame)
        )
    }
}
