//
//  WaveFormView.swift
//  RawUIRecord
//
//  Created by Phu Pham on 18/10/24.
//

import SwiftUI

struct WaveFormView: View {

    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()
            
            WaveFormEffectView()
        }
    }
}

struct WaveFormEffectView: View {
    @State private var percent: CGFloat = 0.5
    
    private let waveRollRatio: Double = 0.02
    
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
            
            Slider(value: $percent)
        }
    }
    
    @ViewBuilder
    private func waveBackgroundImage() -> some View {
        Image("bottle")
            .resizable()
            .renderingMode(.template)
            .aspectRatio(contentMode: .fit)
            .foregroundColor(Color(red: 120/255, green: 145/255, blue: 248/255))
            .scaleEffect(x: 1.05, y: 1)
            .offset(y: -1)
    }
    
    @ViewBuilder
    private func waveLayers(in size: CGSize) -> some View {
        WaveLayerView(percent: $percent, waveRollRatio: waveRollRatio)
        .overlay(
            BubbleEffectView()
                .frame(width: size.width, height: size.height * max(0, percent - waveRollRatio)),
            alignment: .bottom
        )
        .overlay(
            Text("\(percent * 100, specifier: "%.0f")%")
                .foregroundStyle(.appForeground)
                .font(.system(size: 30, weight: .black))
                .offset(y: -((size.height / 2) * (max(0.1, percent) - waveRollRatio))),
            alignment: .bottom
        )
        .mask {
            Image("bottle")
                .resizable()
                .renderingMode(.template)
                .aspectRatio(contentMode: .fit)
                .scaleEffect(0.98)
        }
    }
}

private struct WaveLayerView: View {
    @Binding var percent: CGFloat
    var waveRollRatio: Double
    
    @State private var waveOffset = Angle(degrees: 0)
    
    private func startWaveAnimation() {
        // need to delay state change a bit (until first layout/render finished)
        // this avoid effect to parent view
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            withAnimation(.linear(duration: 1.0).repeatForever(autoreverses: false)) {
                self.waveOffset = Angle(degrees: 360)
            }
        }
    }
    
    var body: some View {
        ZStack {
            WaveShape(
                offset: Angle(degrees: -waveOffset.degrees),
                percent: percent,
                waveRollRatio: waveRollRatio,
                waveFrequency: 2.1,
                extendWaveHeight: 0
            )
            .fill(Color(red: 203/255, green: 225/255, blue: 1))
            
            WaveShape(
                offset: Angle(degrees: waveOffset.degrees),
                percent: percent,
                waveRollRatio: waveRollRatio * 0.9,
                waveFrequency: 1.9,
                extendWaveHeight: 20
            )
            .fill(Color(red: 146/255, green: 192/255, blue: 1))
        }
        .onAppear(perform: startWaveAnimation)
    }
}

struct WaveFormView_Previews: PreviewProvider {
    static var previews: some View {
        WaveFormView()
    }
}
