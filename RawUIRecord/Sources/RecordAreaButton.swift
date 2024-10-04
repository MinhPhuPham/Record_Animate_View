//
//  RecordAreaButton.swift
//  RawUIRecord
//
//  Created by Phu Pham on 3/10/24.
//

import SwiftUI

struct RecordAreaButton: View {
    @StateObject private var recordControlVM = RecordControlViewModel.shared
    
    @GestureState private var dragLocation = CGPoint.zero
    @State private var selectedButtonType: RecordButtonType = .unset {
        willSet {
            recordControlVM.onChangeButtonTypeAction(newType: newValue, oldType: selectedButtonType)
        }
    }
    
    private let recordButtonSize: CGFloat = ScreenHelper.width * 0.7
    
    private func dragDetector(for name: RecordButtonType) -> some View {
        return GeometryReader { proxy in
            let frame = proxy.frame(in: .global)
            let isDragLocationInsideFrame = frame.contains(dragLocation)
            let isDragLocationInsideCircle = isDragLocationInsideFrame &&
            Circle().path(in: frame).contains(dragLocation)
            
            Color.clear
                .onDataChange(of: isDragLocationInsideCircle) { newVal in
                    // "\(newVal ? "entering" : "leaving") \(name)..."
                    if dragLocation != .zero {
                        selectedButtonType = newVal ? name : .unset
                    }
                }
        }
    }
    
    private func onFinishDragGesture() {
        if selectedButtonType == .record {
            print("Do send recording")
        } else if selectedButtonType == .cancel {
            print("Do cancel recording")
        }
        
        recordControlVM.setRecordState(.unset)
        selectedButtonType = .unset
    }
    
    private var trashIconActionView: some View {
        Group {
            if recordControlVM.isInModeRecord() {
                Image(systemName: "trash")
                    .font(.title2)
                    .foregroundColor(recordControlVM.isPreparedDiscard() ? Color.black : Color.appForeground)
                    .padding(20)
                    .background(
                        Circle().fill(recordControlVM.isPreparedDiscard() ? Color.red : Color.appBackgroundColorDim)
                    )
                    .background(dragDetector(for: .cancel))
            }
        }
        .offset(x: -(recordButtonSize/8), y: -(recordButtonSize/8 - 20)) // 20 is item size
    }
    
    var body: some View {
        ZStack {
            Circle()
                .fill(recordControlVM.isRecording() ? .appPrimary : recordControlVM.isPreparedDiscard() ? .appBackgroundColorDim : Color.gray)
            
            RecordAreaButton_Content(recordState: recordControlVM.recordState)
        }
        .frame(width: recordButtonSize, height: recordButtonSize, alignment: .center)
        .scaleEffect(recordControlVM.isConnecting() ? 0.85 : recordControlVM.isInModeRecord() ? 0.9 : 1.0, anchor: .center)
        .background(dragDetector(for: .record))
        .animation(.easeInOut(duration: 0.2), value: recordControlVM.recordState)
        .overlay(
            trashIconActionView,
            alignment: .topLeading
        )
        .overlay(
            Group {
                if recordControlVM.isInModeRecord() {
                    TimerUpView()
                        .foregroundColor(recordControlVM.isPreparedDiscard() ? .red : .appPrimary)
                        .animation(.easeInOut, value: recordControlVM.recordState)
                        .offset(y: -(recordButtonSize/10))
                }
            },
            alignment: .top
        )
        .overlay(
            Group {
                if recordControlVM.isInModeRecord() {
                    Text("Release to send")
                        .font(.system(size: 18))
                        .foregroundColor(.appForegroundColorDim)
                        .offset(y: 20)
                        .opacity(recordControlVM.isPreparedDiscard() ? 0.0 : 1.0)
                }
            },
            alignment: .bottom
        )
        .simultaneousGesture(
            DragGesture(minimumDistance: 0, coordinateSpace: .global)
                .updating($dragLocation) { val, state, trans in
                    state = val.location
                }
                .onEnded { _ in
                    self.onFinishDragGesture()
                }
        )
    }
}

private struct RecordAreaButton_Content: View {
    var recordState: RecordingState
    
    var body: some View {
        VStack(alignment: .center, spacing: 20) {
            HorizontalBarView(heights: [15, 30, 40, 30, 15])
                .stroke(.appBackground, lineWidth: 4) // Customize color and line width
                .frame(width: 60, height: 50) // Adjust size as needed
            
            Group {
                switch recordState {
                case .unset:
                    Text("Push to talk")
                case .connecting:
                    Text("Connecting")
                case .recording, .prepareDiscard:
                    EmptyView()
                }
            }
            .font(.system(size: 18, weight: .medium))
            .foregroundColor(.appBackground)
        }
    }
}

#Preview {
    RecordAreaButton()
}
