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
        WaveFormView()
    }
}
