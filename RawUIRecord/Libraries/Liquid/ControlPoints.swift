//
//  ControlPoints.swift
//  RawUIRecord
//
//  Created by Phu Pham on 7/10/24.
//


import CoreGraphics

/// Calculates tangents and generates Bezier control points.
/// - seealso: https://github.com/maustinstar/liquid/blob/master/Docs/Liquid%20Implementation%20Guide.md#mathematics
struct ControlPoints {
    var x1: [Double]
    var y1: [Double]
    var x2: [Double]
    var y2: [Double]

    init(x: [Double], y: [Double]) {
        assert(x.count == y.count, "Expected matching pairs for x and y, but found \(x.count) x points and \(y.count) y points.")
        
        let count = x.count
        var x1 = [Double](repeating: 0, count: count)
        var y1 = [Double](repeating: 0, count: count)
        var x2 = [Double](repeating: 0, count: count)
        var y2 = [Double](repeating: 0, count: count)
        
        // Call the standalone function
        bezierControlPoints(size: count, srcX: x, srcY: y, ctrl1X: &x1, ctrl1Y: &y1, ctrl2X: &x2, ctrl2Y: &y2)
        
        self.x1 = x1
        self.y1 = y1
        self.x2 = x2
        self.y2 = y2
    }

    init(_ points: [CGPoint]) {
        let count = points.count
        let x = points.map { Double($0.x) }
        let y = points.map { Double($0.y) }
        
        var x1 = [Double](repeating: 0, count: count)
        var y1 = [Double](repeating: 0, count: count)
        var x2 = [Double](repeating: 0, count: count)
        var y2 = [Double](repeating: 0, count: count)
        
        // Call the standalone function
        bezierControlPoints(size: count, srcX: x, srcY: y, ctrl1X: &x1, ctrl1Y: &y1, ctrl2X: &x2, ctrl2Y: &y2)
        
        self.x1 = x1
        self.y1 = y1
        self.x2 = x2
        self.y2 = y2
    }
}

func bezierControlPoints(size: Int, srcX: [Double], srcY: [Double],
                         ctrl1X: inout [Double], ctrl1Y: inout [Double],
                         ctrl2X: inout [Double], ctrl2Y: inout [Double]) {
    
    var prev = size - 1
    var next = 1
    
    for i in 0..<size {
        var dx = srcX[prev] - srcX[next]
        var dy = srcY[prev] - srcY[next]
        let m = sqrt(dx * dx + dy * dy)
        dx /= m
        dy /= m
        
        let nextDX = srcX[i] - srcX[next]
        let nextDY = srcY[i] - srcY[next]
        let nextDist = sqrt(nextDX * nextDX + nextDY * nextDY)
        ctrl1X[next] = srcX[i] - dx * nextDist / 3.0
        ctrl1Y[next] = srcY[i] - dy * nextDist / 3.0
        
        let prevDX = srcX[i] - srcX[prev]
        let prevDY = srcY[i] - srcY[prev]
        let prevDist = sqrt(prevDX * prevDX + prevDY * prevDY)
        ctrl2X[i] = srcX[i] + dx * prevDist / 3.0
        ctrl2Y[i] = srcY[i] + dy * prevDist / 3.0
        
        prev = (prev + 1) % size
        next = (next + 1) % size
    }
}
