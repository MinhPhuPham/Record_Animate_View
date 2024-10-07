//
//  LiquidCircleView.swift
//  RawUIRecord
//
//  Created by Phu Pham on 7/10/24.
//

import SwiftUI
import Combine

struct LiquidCircleView: View {
    @State var samples: Int
    @State var radians: AnimatableArray
    @State var animate: Bool
    let period: TimeInterval

    init(samples: Int = 8, period: TimeInterval = 6, animate: Bool = true) {
        self._samples = .init(initialValue: samples)
        self._radians = .init(initialValue: AnimatableArray(LiquidCircleView.generateRadial(samples)))
        self.period = period
        self._animate = .init(initialValue: animate)
    }

    var body: some View {
        LiquidCircle(radians: radians)
            .fill(
                AnyShapeStyle(
                    RadialGradient(colors: [.clear, Color.greenCustomColor.opacity(0.6)], center: .center, startRadius: 0, endRadius: 240*0.99)
                )
            )
            .onAppear {
                animatedRadianUpdate()
            }
            .onDisappear {
                animate = false
            }
    }

    static func generateRadial(_ count: Int = 6) -> [Double] {
        var radians: [Double] = []
        let offset = Double.random(in: 0...(.pi / Double(count)))
        for i in 0..<count {
            let min = Double(i) / Double(count) * 2 * .pi
            let max = Double(i + 1) / Double(count) * 2 * .pi
            radians.append(Double.random(in: min...max) + offset)
        }

        return radians
    }

    func animatedRadianUpdate() {
        guard animate else { return }
        
        if #available(iOS 17.0, *) {
            withAnimation(.linear(duration: period)) {
                radians = AnimatableArray(LiquidCircleView.generateRadial(samples))
            } completion: {
                self.animatedRadianUpdate()
            }
        } else {
            withAnimation(.linear(duration: period)) {
                radians = AnimatableArray(LiquidCircleView.generateRadial(samples))
            }
            Task.delayed(by: .seconds(period)) { @MainActor in
                self.animatedRadianUpdate()
            }
        }
    }
}

struct LiquidCircle_PreViews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.black.ignoresSafeArea(.all)
            
            LiquidCircleView(period: 1)
                .frame(width: 240, height: 240)

                .opacity(0.3)

            LiquidCircleView(period: 3)
                .frame(width: 220, height: 220)
                .foregroundColor(.blue)
                .opacity(0.6)

            LiquidCircleView(samples: 5, period: 2)
                .frame(width: 200, height: 200)
                .foregroundColor(.blue)
            
            ImageView(
                imageURL: "https://avatars.githubusercontent.com/u/51711158?v=4",
                width: 100
            )
            .mask(LiquidCircleView())
        }
    }
}
