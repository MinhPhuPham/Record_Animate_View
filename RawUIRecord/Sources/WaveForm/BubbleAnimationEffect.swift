//
//  BubbleAnimationEffect.swift
//  RawUIRecord
//
//  Created by Phu Pham on 18/10/24.
//

import SwiftUI

struct BubbleEffectView: View {
    @StateObject var viewModel: BubbleEffectViewModel = BubbleEffectViewModel()
    
    var body: some View {
        ZStack{
            // Show bubble views for each bubble
            ForEach(viewModel.bubbles) { bubble in
                BubbleView(bubble: bubble)
            }
        }
        .background(
            GeometryReader { geo in
                Color.clear
                    .onAppear {
                        // Set the initial position from frame size
                        viewModel.addBubbles()
                    }
                    .onChange(of: geo.size) { newSize in
                        viewModel.onFrameSizeChange(newSize)
                    }
            }
        )
        .onDisappear {
            viewModel.clearTimer()
        }
    }
}
class BubbleEffectViewModel: ObservableObject {
    @Published var bubbles: [BubbleViewModel] = []
    private var frameSize: CGSize = .zero
    private var timer: Timer?
    private var timerCount: Int = 0
    private var bubbleCount: Int = 10
    private var waveRollsHeight: CGFloat = 20
    private let lifetimeRange: (min: Double, max: Double) = (min: 1.6, max: 2.2)
    
    func onFrameSizeChange(_ size: CGSize){
        if self.frameSize != size {
            self.frameSize = size
            self.addBubbles()
        }
    }
    
    func addBubbles(){
        if timer != nil{
            timer?.invalidate()
        }
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) {[weak self] (timer) in
            guard let self = self else {
                self?.clearTimer()
                return
            }
            
            let yRoadHeight: CGFloat = max(0, self.frameSize.height - waveRollsHeight)
            let randomX: CGFloat = .random(in: (self.frameSize.width * 1/3)...(self.frameSize.width * 2/3))
            let randomLifeTime: TimeInterval = .random(in: self.lifetimeRange.min...self.lifetimeRange.max)
            let bubble = BubbleViewModel(height: 10, width: 10, x: randomX, y: yRoadHeight, color: .white, lifetime: randomLifeTime)
            
            //Add to array
            self.bubbles.append(bubble)
            
            //Get rid if the bubble at the end of its lifetime
            Timer.scheduledTimer(withTimeInterval: bubble.lifetime, repeats: false, block: {[weak self] _ in
                self?.bubbles.removeAll(where: {
                    $0.id == bubble.id
                })
            })
        }
    }
    
    func clearTimer() {
        timer?.invalidate()
        timer = nil
    }
}

struct BubbleView: View {
    //If you want to change the bubble's variables you need to observe it
    @ObservedObject var bubble: BubbleViewModel
    @State var opacity: Double = 0
    var body: some View {
        Circle()
            .foregroundColor(bubble.color)
            .opacity(opacity)
            .frame(width: bubble.width, height: bubble.height)
            .position(x: bubble.x, y: bubble.y)
            .onAppear {
                
                withAnimation(.linear(duration: bubble.lifetime)){
                    //Go up
                    self.bubble.y = -bubble.height
                    //Go sideways
//                    self.bubble.x += bubble.xFinalValue()
                    //Change size
                    let width = bubble.yFinalValue()
                    self.bubble.width = width
                    self.bubble.height = width
                }
                //Change the opacity faded to full to faded
                //It is separate because it is half the duration
                DispatchQueue.main.asyncAfter(deadline: .now()) {
                    withAnimation(.linear(duration: bubble.lifetime/2).repeatForever()) {
                        self.opacity = 1
                    }
                }
            }
    }
}

class BubbleViewModel: Identifiable, ObservableObject{
    let id: UUID = UUID()
    @Published var x: CGFloat
    @Published var y: CGFloat
    @Published var color: Color
    @Published var width: CGFloat
    @Published var height: CGFloat
    @Published var lifetime: TimeInterval = 0
    
    init(height: CGFloat, width: CGFloat, x: CGFloat, y: CGFloat, color: Color, lifetime: TimeInterval){
        self.height = height
        self.width = width
        self.color = color
        self.x = x
        self.y = y
        self.lifetime = lifetime
    }
    
    func xFinalValue() -> CGFloat {
        return CGFloat.random(in:-width*CGFloat(lifetime*1.5)...width*CGFloat(lifetime*1.5))
    }
    
    func yFinalValue() -> CGFloat {
        return CGFloat.random(in:0...width*CGFloat(lifetime*1.5))
    }
}
