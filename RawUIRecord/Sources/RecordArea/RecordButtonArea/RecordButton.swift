//
//  RecordAreaButton.swift
//  RawUIRecord
//
//  Created by Phu Pham on 3/10/24.
//

import SwiftUI

struct RecordButton: View {
    var recordState: RecordingState
    
    var body: some View {
        VStack(alignment: .center, spacing: 20) {
            HorizontalBarIcon(heights: [15, 30, 40, 30, 15])
                .stroke(.appBackground, lineWidth: 4) // Customize color and line width
                .frame(width: 60, height: 50) // Adjust size as needed
            
            Group {
                if !recordState.isNotUnsetMode {
                    Text("Push to talk")
                } else if recordState.isConnecting {
                    Text("Connecting")
                }
            }
            .font(.system(size: 18, weight: .medium))
            .foregroundColor(.appBackground)
        }
    }
}
