//
//  CarouselTourGuide.swift
//  RawUIRecord
//
//  Created by Phu Pham on 12/11/24.
//

import SwiftUI

struct CarouselTourGuide: View {
    @State private var selectedStep: Int = 0
    
    struct Item: Identifiable {
        let id = UUID()
        let image: String
        let title: String
    }
    
    let items = [
        Item(image: "full_access_step1", title: "① Tap “Keyboard in the setting"),
        Item(image: "full_access_step2", title: "② Turn ON “Ninja Miles”"),
        Item(image: "full_access_step3", title: "③ Turn ON “Full access”")
    ]
    
    private let snapConfig = SnapCarouselConfigure(
        isWrap: false,
        autoScroll: .active(1.5),
        anchorAnimateItem: .bottom,
        animationDuration: 0.7
    )
    
    private func openSettingForApp() {
        guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
            return
        }

        if UIApplication.shared.canOpenURL(settingsUrl) {
            UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                print("Settings opened: \(success)") // Prints true
            })
        }
    }
    
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            
            Text(items[selectedStep].title)
                .font(.title3.weight(.semibold))
            
            SnapCarousel(items, index: $selectedStep, config: snapConfig) { item in
                itemView(item: item)
            }
            .frame(width: ScreenHelper.width, height: ScreenHelper.height / 2)
            
            Spacer()
            
            Button(action: openSettingForApp) {
                Text("Go to system setting")
                    .foregroundColor(.white)
                    .padding(.horizontal)
                    .padding(.vertical, 14)
            }
            .background(Color.red)
            .clipShape(Capsule())
            
            Spacer()
        }
    }
    
    @ViewBuilder
    func itemView(item: Item) -> some View {
        VStack {
            Spacer()
            
            Image(item.image)
                .resizable()
                .aspectRatio(contentMode: .fit)
        }
    }
}
