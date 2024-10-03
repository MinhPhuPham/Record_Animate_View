//
//  ContentView.swift
//  RawUIRecord
//
//  Created by Phu Pham on 2/10/24.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea(.all)
            
            RecordLayoutWrapper()
        }
    }
}

#Preview {
    ContentView()
}


extension Color {
    static var grayDark: Color {
        Color(red: 81/255, green: 77/255, blue: 81/255)
    }
}

enum RecordingState {
    case unset
    case connecting
    case recording
    case prepareDiscard
}

private struct RecordLayoutWrapper: View {
    @State private var recordState: RecordingState = .unset
    
    var body: some View {
        ZStack {
            Color.black
            
            VStack(spacing: 20) {
                VerticalSelectorList()
                
                InnerPartipalSection()
                
                RecordAreaButton(recordState: $recordState)
            }
        }
    }
}

private struct VerticalSelectorList: View {
    var circleSize: CGFloat = 120
    
    var body: some View {
        ZStack {
            MorphingCircle(size: 180, morphingRange: 12, color: .orange.opacity(0.4), duration: 0.8)
            
            MorphingCircle(size: 160, morphingRange: 12, color: .yellow.opacity(0.4), duration: 0.8)
            
            // Inner image
            ImageView(
                imageURL: "https://picsum.photos/200/200",
                ratio: 1,
                width: 100
            )
            .clipShape(Circle())
            
        }
    }
}

private struct InnerPartipalSection: View {
    
    var body: some View {
        ZStack {
        }
    }
}

enum RecordButtonType {
    case unset
    case cancel
    case record
}

private struct RecordAreaButton: View {
    @Binding var recordState: RecordingState
    @GestureState private var dragLocation = CGPoint.zero
    @State private var selectedButtonType: RecordButtonType = .unset {
        willSet {
            if newValue == .record && recordState != .recording {
                onMakeRecordAction()
            } else if newValue == .cancel && recordState == .recording {
                recordState = .prepareDiscard
            }
        }
    }
    
    private let recordButtonSize: CGFloat = 300
    
    private func dragDetector(for name: RecordButtonType) -> some View {
        return GeometryReader { proxy in
            let frame = proxy.frame(in: .global)
            let isDragLocationInsideFrame = frame.contains(dragLocation)
            let isDragLocationInsideCircle = isDragLocationInsideFrame &&
            Circle().path(in: frame).contains(dragLocation)
            
            Color.clear
                .onDataChange(of: isDragLocationInsideCircle) { newVal in
                    // "\(newVal ? "entering" : "leaving") \(name)..."
                    if dragLocation != .zero {
                        selectedButtonType = newVal ? name : .unset
                    }
                }
        }
    }
    
    private func onMakeRecordAction() {
        if recordState != .unset {
            return
        }
        
        recordState = .connecting
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            recordState = .recording
        }
    }
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            VStack {
                HorizontalBarView(heights: [15, 30, 40, 30, 15])
                    .stroke(Color.black, lineWidth: 4) // Customize color and line width
                    .frame(width: 100, height: 50) // Adjust size as needed
                
                switch recordState {
                case .unset:
                    Text("Push to talk")
                case .connecting:
                    Text("Connecting")
                case .recording, .prepareDiscard:
                    Text("")
                }
                
            }
            .frame(width: recordButtonSize, height: recordButtonSize)
            .scaleEffect(recordState == .connecting ? 0.75 : (recordState == .recording || recordState == .prepareDiscard) ? 0.9 : 1.0)
            .background(
                Circle()
                    .fill(recordState == .recording ? .appPrimary : recordState == .prepareDiscard ? .appBackgroundColorDim : Color.gray)
                    .scaleEffect(recordState == .connecting ? 0.75 : (recordState == .recording || recordState == .prepareDiscard) ? 0.9 : 1.0)
            )
            .animation(.easeInOut(duration: 0.2), value: recordState)
            .background(dragDetector(for: .record))
            
            if recordState != .unset {
                Image(systemName: "trash")
                    .font(.title2)
                    .foregroundColor(recordState == .prepareDiscard ? Color.black : Color.appForeground )
                    .padding(20)
                    .background(
                        Circle().fill(recordState == .prepareDiscard ? Color.red : Color.appBackgroundColorDim)
                    )
                    .background(dragDetector(for: .cancel))
                    .offset(x: -30, y: -30)
                    .overlay(
                        Text("Release to cancel")
                            .opacity(recordState == .prepareDiscard ? 1 : 0),
                        alignment: .top
                    )
            }
        }
        .gesture(
            DragGesture(coordinateSpace: .global)
                .updating($dragLocation) { val, state, trans in
                    state = val.location
                }
                .onEnded { _ in
                    if selectedButtonType == .record {
                        print("Do send recording")
                    } else if selectedButtonType == .cancel {
                        print("Do cancel recording")
                    }
                    
                    recordState = .unset
                    selectedButtonType = .unset
                }
        )
    }
}

struct HorizontalBarView: Shape {
    // Define the heights of the lines
    var heights: [CGFloat] = []
    var spacing: CGFloat = 10
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let totalWidth = CGFloat(heights.count) * spacing
        
        // Calculate initial position to center the shape
        let startX = (rect.width - totalWidth) / 2
        
        for (index, height) in heights.enumerated() {
            let xPos = startX + CGFloat(index) * spacing
            
            path.move(to: CGPoint(x: xPos, y: rect.midY - height / 2)) // Start point
            path.addLine(to: CGPoint(x: xPos, y: rect.midY + height / 2)) // End point
        }
        
        return path
    }
}

struct RippleCircle: View {
    var size: CGFloat
    var delay: Double
    var duration: Double
    var scaleRatio: Double
    
    @State private var scale: CGFloat = 1
    @State private var opacity: Double = 1
    
    var body: some View {
        Circle()
            .stroke(Color.grayDark, lineWidth: 3)
            .frame(width: size, height: size)
            .scaleEffect(scale)
            .opacity(opacity)
            .onAppear {
                withAnimation(Animation.linear(duration: duration).repeatForever(autoreverses: false).delay(delay)) {
                    scale = scaleRatio
                    opacity = 0.98
                }
            }
    }
}

struct InfiniteRippleView: View {
    var circleSize: CGFloat
    var numberOfRipples: Int = 5
    let durationAnimation: Double = 0.8
    
    @State private var ripples: [UUID] = (0..<5).map { _ in UUID() }
    
    var body: some View {
        // Create multiple concentric ripple circles
        Circle()
            .stroke(Color.grayDark, lineWidth: 4)
            .frame(width: circleSize, height: circleSize)
        
        let childCircleSize = circleSize - 1
        
        ZStack {
            ForEach(Array(ripples.enumerated()), id: \.element) { index, ripple in
                RippleCircle(
                    size: childCircleSize - CGFloat(index*12),
                    delay: durationAnimation*(Double(index)),
                    duration: durationAnimation,
                    scaleRatio: (childCircleSize - CGFloat((index+1)*12)) / (childCircleSize - CGFloat(index*12))
                )
            }
        }
    }
}

