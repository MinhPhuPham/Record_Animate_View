//
//  HorizontalBarIcon.swift
//  RawUIRecord
//
//  Created by Phu Pham on 3/10/24.
//

import SwiftUI

struct HorizontalBarIcon: Shape {
    // Define the heights of the lines
    var heights: [CGFloat] = []
    var spacing: CGFloat = 10
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        // Total width account for spacing between bars
        let totalWidth = CGFloat(heights.count - 1) * spacing
        
        // Calculate starting X position to center the shape
        let startX = (rect.width - totalWidth) / 2
        
        for (index, height) in heights.enumerated() {
            let xPos = startX + CGFloat(index) * spacing
            
            // Move to the start of the vertical line
            path.move(to: CGPoint(x: xPos, y: rect.midY - height / 2))
            // Add a line to create the vertical bar
            path.addLine(to: CGPoint(x: xPos, y: rect.midY + height / 2))
        }
        
        return path
    }
}
