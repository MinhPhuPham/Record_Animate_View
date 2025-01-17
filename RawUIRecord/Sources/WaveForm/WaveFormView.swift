//
//  WaveFormView.swift
//  RawUIRecord
//
//  Created by Phu Pham on 18/10/24.
//

import SwiftUI

struct WaveFormView: View {
    @State private var percent: CGFloat = 0.5
    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()
            
            WaveFormEffectView(percent: $percent, waveFormConfig: .init())
        }
    }
}

struct WaveFormConfigProps {
    var mainImage: String = "bottle"
    var maskImage: String = "bottle"
    
    var waveFirstColor: Color = Color(red: 203/255, green: 225/255, blue: 1)
    var waveSecondColor: Color = Color(red: 146/255, green: 192/255, blue: 1)
    
    var waveExtendWaveHeight: CGFloat = 20
    var waveRollRatio: Double = 0.02
    var waveFrequency: Double = 1.9
    var waveSpeed: Double = 1.0

    var bubbleConfig: BubbleConfigProps = .init()
}

struct WaveFormEffectView: View {
    @Binding var percent: CGFloat
    let waveFormConfig: WaveFormConfigProps

    var body: some View {
        VStack {
            Spacer()

            GeometryReader { proxy in
                let size = proxy.size
                
                ZStack {
                    waveBackgroundImage()
                    
                    waveLayers(in: size)
                }
                .frame(width: size.width, height: size.height)
            }
            .frame(height: ScreenHelper.height * 0.6)
            
            Spacer()
            
            Slider(value: $percent, in: 0...1)
        }
    }
    
    @ViewBuilder
    private func waveBackgroundImage() -> some View {
        Image(waveFormConfig.mainImage)
            .resizable()
            .renderingMode(.template)
            .aspectRatio(contentMode: .fit)
            .foregroundColor(Color(red: 120/255, green: 145/255, blue: 248/255))
            .scaleEffect(x: 1.05, y: 1)
            .offset(y: -1)
    }
    
    @ViewBuilder
    private func waveLayers(in size: CGSize) -> some View {
        WaveLayerView(percent: $percent, waveFormConfig: waveFormConfig)
            .overlay(
                BubbleEffectView(config: waveFormConfig.bubbleConfig)
                    .frame(width: size.width, height: size.height * max(0, percent - waveFormConfig.waveRollRatio)), // Adjusted for default waveRollRatio
                alignment: .bottom
            )
            .overlay(
                Text("\(percent * 100, specifier: "%.0f")%")
                    .foregroundColor(.blue)
                    .font(.system(size: 30, weight: .black))
                    .offset(y: -((size.height / 2) * (max(0.1, percent) - waveFormConfig.waveRollRatio))), // Adjusted for default waveRollRatio
                alignment: .bottom
            )
            .mask {
                Image(waveFormConfig.maskImage)
                    .resizable()
                    .renderingMode(.template)
                    .aspectRatio(contentMode: .fit)
                    .scaleEffect(0.98)
            }
    }
}

private struct WaveLayerView: View {
    @Binding var percent: CGFloat
    var waveFormConfig: WaveFormConfigProps
    
    @State private var waveOffset = Angle(degrees: 0)
    
    private func startWaveAnimation() {
        // need to delay state change a bit (until first layout/render finished)
        // this avoid effect to parent view
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation(.linear(duration: waveFormConfig.waveSpeed).repeatForever(autoreverses: false)) {
                self.waveOffset = Angle(degrees: 360)
            }
        }
    }
    
    var body: some View {
        ZStack {
            WaveShape(
                offset: Angle(degrees: -waveOffset.degrees),
                percent: percent,
                waveRollRatio: waveFormConfig.waveRollRatio,
                waveFrequency: waveFormConfig.waveFrequency + 0.2,
                extendWaveHeight: 0
            )
            .fill(waveFormConfig.waveFirstColor)
            
            WaveShape(
                offset: Angle(degrees: waveOffset.degrees),
                percent: percent,
                waveRollRatio: waveFormConfig.waveRollRatio * 0.9,
                waveFrequency: waveFormConfig.waveFrequency,
                extendWaveHeight: waveFormConfig.waveExtendWaveHeight
            )
            .fill(waveFormConfig.waveSecondColor)
        }
        .onAppear(perform: startWaveAnimation)
    }
}

struct WaveFormView_Previews: PreviewProvider {
    static var previews: some View {
        MyParentView()
    }
}

import SwiftUI
struct MyParentView: View {
    @State var replay: Bool = false
    var body: some View {
        ZStack{
            Color.blue.opacity(0.8)
            
            BubbleEffectView2(replay: $replay)
            
            VStack{
                Spacer()
                Button(action: {
                    replay.toggle()
                }, label: {Text("replay")}).foregroundColor(.red)
            }
        }
    }
}
struct BubbleEffectView2: View {
    @StateObject var viewModel: BubbleEffectViewModel2 = BubbleEffectViewModel2()
    @Binding var replay: Bool
    var body: some View {
        GeometryReader{ geo in
            ZStack{
                //Show bubble views for each bubble
                ForEach(viewModel.bubbles){bubble in
                    BubbleView2(bubble: bubble)
                }
            }.onChange(of: replay, perform: { _ in
                viewModel.addBubbles(frameSize: geo.size)
            })
            
            .onAppear(){
                //Set the initial position from frame size
                viewModel.viewBottom = geo.size.height
                viewModel.addBubbles(frameSize: geo.size)
            }
        }
    }
}
class BubbleEffectViewModel2: ObservableObject{
    @Published var viewBottom: CGFloat = CGFloat.zero
    @Published var bubbles: [BubbleViewModel3] = []
    private var timer: Timer?
    private var timerCount: Int = 0
    @Published var bubbleCount: Int = 50
    
    func addBubbles(frameSize: CGSize){
        let lifetime: TimeInterval = 2
        //Start timer
        timerCount = 0
        if timer != nil{
            timer?.invalidate()
        }
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { (timer) in
            let bubble = BubbleViewModel3(height: 10, width: 10, x: frameSize.width/2, y: self.viewBottom, color: .white, lifetime: lifetime)
            //Add to array
            self.bubbles.append(bubble)
            //Get rid if the bubble at the end of its lifetime
            Timer.scheduledTimer(withTimeInterval: bubble.lifetime, repeats: false, block: {_ in
                self.bubbles.removeAll(where: {
                    $0.id == bubble.id
                })
            })
            if self.timerCount >= self.bubbleCount {
                //Stop when the bubbles will get cut off by screen
                timer.invalidate()
                self.timer = nil
            }else{
                self.timerCount += 1
            }
        }
    }
}
struct BubbleView2: View {
    //If you want to change the bubble's variables you need to observe it
    @ObservedObject var bubble: BubbleViewModel3
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
                    self.bubble.x += bubble.xFinalValue()
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
                DispatchQueue.main.asyncAfter(deadline: .now()) {
                    withAnimation(Animation.linear(duration: bubble.lifetime/4).repeatForever()) {
                        //Go sideways
                        //bubble.x += bubble.xFinalValue()
                    }
                }
            }
    }
}
class BubbleViewModel3: Identifiable, ObservableObject{
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
        return CGFloat.random(in:-width*CGFloat(lifetime*2.5)...width*CGFloat(lifetime*2.5))
    }
    func yFinalValue() -> CGFloat {
        return CGFloat.random(in:0...width*CGFloat(lifetime*2.5))
    }
    
}
struct MyParentView_Previews: PreviewProvider {
    static var previews: some View {
        MyParentView()
    }
}
