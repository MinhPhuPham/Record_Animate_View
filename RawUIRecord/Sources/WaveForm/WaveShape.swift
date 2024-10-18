//
//  WaveShape.swift
//  RawUIRecord
//
//  Created by Phu Pham on 18/10/24.
//

import SwiftUI

struct WaveShape: Shape {
    var offset: Angle
    var percent: Double
    var waveRollRatio: Double = 0.02
    var waveFrequency: Double = 1.0
    var extendWaveHeight: CGFloat = 0 // New parameter to increase overall height

    var animatableData: AnimatablePair<Double, Double> {
        get {
            AnimatablePair(offset.degrees, percent)
        }
        set {
            offset = Angle(degrees: newValue.first)
            percent = newValue.second
        }
    }
    
    func path(in rect: CGRect) -> Path {
        var p = Path()
        
        let lowfudge = 0.02
        let highfudge = 0.98
        
        // Total height adjustment
        let totalHeight = rect.height + extendWaveHeight
        
        let newpercent = lowfudge + (highfudge - lowfudge) * percent
        let waveHeight = waveRollRatio * totalHeight
        let yoffset = CGFloat(1 - newpercent) * (totalHeight - 4 * waveHeight) + 2 * waveHeight
        let startAngle = offset
        let endAngle = offset + Angle(degrees: 360 * waveFrequency)
        
        p.move(to: CGPoint(x: 0, y: yoffset + waveHeight * CGFloat(sin(offset.radians))))
        
        for angle in stride(from: startAngle.degrees, through: endAngle.degrees, by: 2) {
            let x = CGFloat((angle - startAngle.degrees) / (360 * waveFrequency)) * rect.width
            let y = yoffset + waveHeight * CGFloat(sin(Angle(degrees: angle).radians))
            p.addLine(to: CGPoint(x: x, y: y))
        }
        
        p.addLine(to: CGPoint(x: rect.width, y: totalHeight))
        p.addLine(to: CGPoint(x: 0, y: totalHeight))
        p.closeSubpath()
        
        return p
    }
}
