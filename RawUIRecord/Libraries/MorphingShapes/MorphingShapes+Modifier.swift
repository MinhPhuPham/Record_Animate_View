//
//  MorphingShapes+Modifier.swift
//  RawUIRecord
//
//  Created by Phu Pham on 3/10/24.
//

import SwiftUI

struct MorphingShapesView: ViewModifier {
    var firstColor: Color
    var secondColor: Color
    var duration: Double
    var size: CGFloat
    var morphingRange: CGFloat

    func body(content: Content) -> some View {
        ZStack {
            // Background morphing circles
            MorphingCircle(size: size + 20, morphingRange: morphingRange, color: firstColor, duration: duration)
            MorphingCircle(size: size, morphingRange: morphingRange * 1.3, color: secondColor, duration: duration)
            
            // Content view
            content
        }
    }
}

extension View {
    func morphingShapes(
        firstColor: Color = .orange.opacity(0.4),
        secondColor: Color = .yellow.opacity(0.2),
        duration: Double = 0.8,
        size: CGFloat = 160,
        morphingRange: CGFloat = 14
    ) -> some View {
        self.modifier(MorphingShapesView(firstColor: firstColor, secondColor: secondColor, duration: duration, size: size, morphingRange: morphingRange))
    }
}
