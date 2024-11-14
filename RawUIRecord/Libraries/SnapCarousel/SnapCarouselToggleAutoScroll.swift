//
//  SnapCarouselToggleAutoScroll.swift
//  RawUIRecord
//
//  Created by Phu Pham on 13/11/24.
//

import SwiftUI

struct SnapCarouselToggleAutoScroll: View {
    @Binding var autoScrollState: SnapCarouselAutoScrollState
    var controllOffsetY: CGFloat
    
    @State private var isButtonVisible: Bool = false
    private let animationDuration: TimeInterval = 0.6
    
    var onClickIcon: () -> Void
    
    var displayImageIcon: String {
        switch autoScrollState {
        case .active: return "pause.fill"
        case .temporaryDeactive: return "play.fill"
        case .resetOneTime: return "arrow.counterclockwise"
        case .unset: return ""
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            if isButtonVisible && autoScrollState != .unset {
                Button(action: onClickIcon) {
                    Image(systemName: displayImageIcon)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 40, height: 40)
                        .foregroundColor(Color.black)
                        .padding(20)  // Extra padding to increase the clickable area
                        .background(Circle().fill(Color.gray.opacity(0.2)))
                }
                .transition(.opacity)
            }
        }
        .offset(y: controllOffsetY)
        .onChange(of: autoScrollState, perform: toggleButtonVisibility)
    }
    
    private func toggleButtonVisibility(_ scrollState: SnapCarouselAutoScrollState) {
        // If state is unset and button is visible, hide the button
        guard !(scrollState == .unset && isButtonVisible) else {
            isButtonVisible = false
            return
        }
        
        // Animate the button to become visible
        withAnimation(.easeInOut(duration: animationDuration)) {
            isButtonVisible = true
        }
        
        // If state is resetOneTime then keep the button visible
        guard scrollState != .resetOneTime else { return }
        
        // After showing the button, set it to hide after a delay
        DispatchQueue.main.asyncAfter(deadline: .now() + animationDuration) {
            withAnimation(.easeInOut(duration: animationDuration)) {
                isButtonVisible = false
            }
        }
    }
}

