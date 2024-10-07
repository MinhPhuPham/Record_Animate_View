//
//  MorphingCircleShape.swift
//  WidgetPhoto
//
//  Created by Phu Pham on 2/10/24.
//

import SwiftUI
import Foundation

public struct MorphingCircleShape: Shape {
    var pointsNum: Int = 10
    var morphing: AnimatableVector
    var tangentCoeficient: CGFloat
    
    public var animatableData: AnimatableVector {
        get { morphing }
        set { morphing = newValue }
    }
    
    func getTwoTangent(center: CGPoint, point: CGPoint) -> (CGPoint, CGPoint) {
        let a = CGVector(center - point)
        let dir = a.perpendicular() * a.len() * tangentCoeficient
        return (point - dir, point + dir)
    }
    
    public func path(in rect: CGRect) -> Path {
        var path = Path()
        let radius = min(rect.width / 2, rect.height / 2)
        let center =  CGPoint(x: rect.width / 2, y: rect.height / 2)
        var nextPoint = CGPoint.zero
        
        let ithPoint: (Int) -> CGPoint = { i in
            let point = center + CGPoint(x: radius * sin(CGFloat(i) * CGFloat.pi * CGFloat(2) / CGFloat(pointsNum)),
                                         y: radius * cos(CGFloat(i) * CGFloat.pi * CGFloat(2) / CGFloat(pointsNum)))
            var direction = CGVector(point - center)
            direction = direction / direction.len()
            return point + direction * CGFloat(morphing[i >= pointsNum ? 0 : i])
        }
        var tangentLast = getTwoTangent(center: center,
                                        point: ithPoint(pointsNum - 1))
        for i in (0...pointsNum){
            nextPoint = ithPoint(i)
            let tangentNow = getTwoTangent(center: center, point: nextPoint)
            if i != 0 {
                path.addCurve(to: nextPoint, control1: tangentLast.1, control2: tangentNow.0)
            } else {
                path.move(to: nextPoint)
            }
            tangentLast = tangentNow
        }
        path.closeSubpath()
        return path
    }
    
    
    init(_ morph: AnimatableVector) {
        pointsNum = morph.count
        morphing = morph
        tangentCoeficient = (4 / 3) * tan(CGFloat.pi / CGFloat(2 * pointsNum))
    }
}

public struct MorphingCircle: View & Identifiable & Hashable {
    public static func == (lhs: MorphingCircle, rhs: MorphingCircle) -> Bool {
        lhs.id == rhs.id
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    public let id = UUID()
    @State private var morph: AnimatableVector
    @State private var animate: Bool
    @State private var scale: CGFloat = 0.5
    
    /// Generates a new AnimatableVector with random morph values
    func morphCreator() -> AnimatableVector {
        let range = Float(-morphingRange)...Float(morphingRange)
        var morphing = Array(repeating: Float.zero, count: self.points)
        for i in 0..<morphing.count where Int.random(in: 0...1) == 0 {
            morphing[i] = Float.random(in: range)
        }
        return AnimatableVector(values: morphing)
    }
    
    /// Updates the morph value with a smooth animation
    func update(isInitView: Bool = false) {
        withAnimation(.easeInOut(
            duration: isInitView ? duration/secting : Double(duration + 1.0)
        )) {
            morph = morphCreator()
        }
    }
    
    func animatedUpdate() {
        guard animate else { return }
        
        let durationExtend = Double(duration + 0.5)
        
        if #available(iOS 17.0, *) {
            withAnimation(.easeInOut(duration: durationExtend)) {
                self.morph = morphCreator()
            } completion: {
                self.animatedUpdate()
            }
        } else {
            withAnimation(.easeInOut(duration: durationExtend)) {
                self.morph = morphCreator()
            }
            Task.delayed(by: .seconds(duration)) { @MainActor in
                self.animatedUpdate()
            }
        }
    }
    
    let duration: Double
    let points: Int
    let secting: Double
    let size: CGFloat
    var radius: CGFloat
    var color: Color?
    var gradient: RadialGradient?
    let morphingRange: CGFloat
    
    public var body: some View {
        MorphingCircleShape(morph)
            .fill(
                gradient != nil ?
                AnyShapeStyle(gradient!) :
                AnyShapeStyle(color!)
            )
            .frame(width: size, height: size, alignment: .center)
            .scaleEffect(scale)
            .onAppear {
                withAnimation(.easeInOut(duration: 0.2)) {
                    self.scale = 1.0
                }
                
                self.animatedUpdate()
            }
            .onDisappear {
                animate = false
            }
    }
    
    /// Custom initializer for MorphingCircle
    public init(size: CGFloat = 300, morphingRange: CGFloat = 30, color: Color? = .red, gradient: RadialGradient? = nil, points: Int = 4,  duration: Double = 5.0, secting: Double = 2) {
        self.animate = true
        self.points = points
        self.color = color
        self.gradient = gradient
        self.morphingRange = morphingRange
        self.duration = duration
        self.secting = secting
        self.size = morphingRange * 2 < size ? size - morphingRange * 2 : 5
        self.radius = size / 2
        
        // Initialize morph with the result of morphCreator to ensure smooth animation from start
        _morph = State(initialValue: AnimatableVector(values: Array(repeating: Float.zero, count: points)))
    }
    
    func color(_ newColor: Color) -> MorphingCircle {
        var morphNew = self
        morphNew.color = newColor
        morphNew.gradient = nil // Ensure gradient is nil if color is set
        return morphNew
    }
    
    func gradient(_ newGradient: RadialGradient) -> MorphingCircle {
        var morphNew = self
        morphNew.gradient = newGradient
        return morphNew
    }
}

struct MorphingCircle_Previews: PreviewProvider {
    struct ContainerView: View {
        @State private var isCount: Int = 0
        
        var body: some View {
            ZStack {
                Color.black.ignoresSafeArea(.all)
                
                VStack(spacing: 30) {
                    ZStack {
                        MorphingCircle(
                            size: 190,
                            morphingRange: 10,
                            color: Color.yellow.opacity(0.5),
                            points: 7,
                            duration: 0.5,
                            secting: 3
                        )
                        
                        MorphingCircle(
                            size: 180,
                            morphingRange: 16,
                            color: Color.yellow.opacity(0.5),
                            points: 6,
                            duration: 0.5,
                            secting: 4
                        )
                    }
                    .id(isCount)
                    
                    Button(action: {isCount += 1}) {
                        Text("Re-render show")
                    }
                }
            }
        }
    }
    
    static var previews: some View {
        ContainerView()
    }
}
