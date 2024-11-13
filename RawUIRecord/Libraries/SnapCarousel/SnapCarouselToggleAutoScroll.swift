//
//  SnapCarouselToggleAutoScroll.swift
//  RawUIRecord
//
//  Created by Phu Pham on 13/11/24.
//

import SwiftUI

struct SnapCarouselToggleAutoScroll: View {
    @Binding var autoScrollState: SnapCarouselAutoScrollState
    @State private var isButtonVisible: Bool = false
    
    var onClickIcon: () -> Void
    
    private let animationDuration: TimeInterval = 0.8
    
    var displayImageIcon: String {
        switch autoScrollState {
        case .active:
            "pause.fill"
        case .temporaryDeactive:
            "play.fill"
        case .resetOneTime:
            "arrow.trianglehead.counterclockwise"
        case .unset:
            ""
        }
    }
    
    var body: some View {
        VStack {
            if isButtonVisible {
                Button(action: onClickIcon) {
                    Image(systemName: displayImageIcon)
                        .resizable()
                        .foregroundColor(Color.black)
                        .frame(width: 40, height: 40)
                        .padding(20)  // Extra padding to make the circle larger
                        .background(
                            Circle()
                                .fill(Color.gray.opacity(0.2)) // Adjust color and opacity as needed
                        )
                }
                .transition(.opacity)
            }
        }
        .onChange(of: autoScrollState) { newValue in
            print("newValue", newValue)
            toggleButtonVisibility()
        }
    }
    
    private func toggleButtonVisibility() {
        withAnimation(.easeInOut(duration: animationDuration)) {
            isButtonVisible = true
        }
        
        if autoScrollState == .resetOneTime { return }
        
        // After showing the button, set it to hide after a delay
        DispatchQueue.main.asyncAfter(deadline: .now() + animationDuration) {
            withAnimation(.easeInOut(duration: animationDuration)) {
                isButtonVisible = false
            }
        }
    }
}
