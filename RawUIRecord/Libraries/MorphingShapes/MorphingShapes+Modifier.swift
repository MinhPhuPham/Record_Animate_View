//
//  MorphingShapes+Modifier.swift
//  RawUIRecord
//
//  Created by Phu Pham on 3/10/24.
//

import SwiftUI

extension Color {
    static var greenCustomColor = Color(red: 126/255, green: 214/255, blue: 105/255)
}
struct MorphingShapesView: ViewModifier {
    var firstColor: Color
    var secondColor: Color
    var duration: Double
    var size: CGFloat
    var morphingRange: CGFloat

    func body(content: Content) -> some View {
        ZStack {
            MorphingCircle(
                size: size,
                morphingRange: morphingRange,
                gradient: RadialGradient(colors: [.clear, Color.greenCustomColor.opacity(0.5)], center: .center, startRadius: 0, endRadius: size*0.99),
                points: 8,
                duration: duration,
                secting: 3
            )
            
            MorphingCircle(
                size: size - 10,
                morphingRange: morphingRange + 6,
                gradient: RadialGradient(colors: [.clear, Color.greenCustomColor.opacity(0.5)], center: .center, startRadius: 0, endRadius: size - 10),
                points: 6,
                duration: duration,
                secting: 5
            )
            
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
        size: CGFloat = 180,
        morphingRange: CGFloat = 10
    ) -> some View {
        self.modifier(MorphingShapesView(firstColor: firstColor, secondColor: secondColor, duration: duration, size: size, morphingRange: morphingRange))
    }
}
