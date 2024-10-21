//
//  WaveFormView.swift
//  RawUIRecord
//
//  Created by Phu Pham on 18/10/24.
//

import SwiftUI

struct WaveFormView: View {
    @State var percent: CGFloat = 0.5
    @State var waveOffset = Angle(degrees: 0)
    
    private let waveRollRatio: Double = 0.02
    
    func doStartAnimationWave() {
        withAnimation(Animation.linear(duration: 1).repeatForever(autoreverses: false)) {
            self.waveOffset = Angle(degrees: 360)
        }
    }
    
    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea(.all)
            
            VStack{
                
                Spacer()
                
                // MARK: Wave Form
                GeometryReader{proxy in
                    
                    let size = proxy.size
                    
                    ZStack{
                        
                        // MARK: Water Drop
                        Image("bottle")
                            .resizable()
                            .renderingMode(.template)
                            .aspectRatio(contentMode: .fit)
                            .foregroundColor(Color(red: 120/255, green: 145/255, blue: 248/255))
                        // Streching in X Axis
                            .scaleEffect(x: 1.05,y: 1)
                            .offset(y: -1)
                        
                        ZStack {
                            // Wave Form Shape
                            WaveShape(
                                offset: Angle(degrees: -self.waveOffset.degrees),
                                percent: percent,
                                waveRollRatio: waveRollRatio,
                                waveFrequency: 2.1,
                                extendWaveHeight: 0
                            )
                            .fill(Color(red: 203/255, green: 225/255, blue: 1))
                            
                            // Wave Form Shape
                            WaveShape(
                                offset: Angle(degrees: self.waveOffset.degrees),
                                percent: percent,
                                waveRollRatio: waveRollRatio*0.9,
                                waveFrequency: 1.9,
                                extendWaveHeight: 20
                            )
                            .fill(Color(red: 146/255, green: 192/255, blue: 1))
                        }
                        // Water Drops
                        .overlay(
                            BubbleEffectView(replay: .constant(true))
                                .frame(height: size.height * (percent - waveRollRatio)),
                            alignment: .bottom
                        )
                        // Water Percentage
                        .overlay(
                            Text("\(percent*100, specifier: "%.0f")%")
                                .foregroundStyle(.appForeground)
                                .font(Font.system(size: 30, weight: .black))
                                .offset(y: -((size.height / 2) * (percent - waveRollRatio)))
                                .animation(.easeInOut, value: percent),
                            alignment: .bottom
                        )
                        // Masking into Drop Shape
                        .mask {
                            
                            Image("bottle")
                                .resizable()
                                .renderingMode(.template)
                                .aspectRatio(contentMode: .fit)
                                .scaleEffect(0.98)
                        }
                        // Add Button
                        .overlay(alignment: .bottom){
                            Button {
                                withAnimation {
                                    percent += 0.05
                                }
                                
                                DispatchQueue.main.async {
                                    self.waveOffset = Angle(degrees: 0)
                                    doStartAnimationWave()
                                }
                            } label: {
                                Image(systemName: "plus")
                                    .font(.system(size: 32, weight: .black))
                                    .foregroundColor(Color.blue)
                                    .shadow(radius: 2)
                                    .padding(25)
                                    .background(.white,in: Circle())
                            }
                            .offset(y: 80)
                        }
                    }
                    .frame(width: size.width, height: size.height, alignment: .center)
                    .onAppear {
                        doStartAnimationWave()
                    }
                }
                .frame(height: ScreenHelper.height * 0.6)
                
                Spacer()
                
                Slider(value: $percent)
                
            }
        }
    }
}

struct WaveFormView_Previews: PreviewProvider {
    static var previews: some View {
        WaveFormView()
    }
}
