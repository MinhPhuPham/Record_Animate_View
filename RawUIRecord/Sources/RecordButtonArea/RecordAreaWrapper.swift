//
//  RecordAreaWrapper.swift
//  RawUIRecord
//
//  Created by Phu Pham on 7/10/24.
//

import SwiftUI

struct RecordAreaWrapper: View {
    @StateObject private var recordControlVM = RecordControlViewModel.shared
    @GestureState private var dragLocation = CGPoint.zero
    @State private var selectedButtonType: RecordButtonType = .unset {
        willSet {
            recordControlVM.onChangeButtonTypeAction(to: newValue, from: selectedButtonType)
        }
    }

    private let recordButtonSize: CGFloat = ScreenHelper.width * 0.7

    // Gesture detector for specific buttons
    private func dragDetector(for buttonType: RecordButtonType) -> some View {
        GeometryReader { proxy in
            let frame = proxy.frame(in: .global)
            let isInsideFrame = frame.contains(dragLocation)
            let isInsideCircle = isInsideFrame && Circle().path(in: frame).contains(dragLocation)

            Color.clear
                .onChange(of: isInsideCircle) { isInside in
                    if dragLocation != .zero {
                        selectedButtonType = isInside ? buttonType : .unset
                    }
                }
        }
    }

    // Handle the end of the drag gesture
    private func onFinishDragGesture() {
        recordControlVM.onFinishRecordAction()
        selectedButtonType = .unset
    }
    
    private var trashIconActionView: some View {
        Group {
            if recordControlVM.recordState.isInModeRecord {
                Image(systemName: "trash")
                    .font(.title2)
                    .foregroundColor(recordControlVM.recordState.isPreparedDiscard ? Color.black : Color.appForeground)
                    .padding(20)
                    .background(Circle()
                        .fill(recordControlVM.recordState.isPreparedDiscard ? Color.red : Color.appBackgroundColorDim)
                    )
                    .background(dragDetector(for: .cancel))
            }
        }
    }
    
    var body: some View {
        ZStack {
            Circle()
                .fill(mainCircleColor)
            
            RecordButton(recordState: recordControlVM.recordState)
        }
        .frame(width: recordButtonSize, height: recordButtonSize)
        .scaleEffect(scaleEffectValue)
        .background(dragDetector(for: .record))
        .animation(.easeInOut(duration: 0.2), value: recordControlVM.recordState)
        .overlay(
            trashIconActionView.offset(x: -(recordButtonSize / 8), y: -(recordButtonSize / 8 - 20)),
            alignment: .topLeading
        )
        .overlay(
            timerView.offset(y: -(recordButtonSize / 10)),
            alignment: .top
        )
        .overlay(
            instructionTextView.offset(y: 20),
            alignment: .bottom
        )
        .overlay(
            recordActionTextView.offset(y: 45),
            alignment: .bottom
        )
        .simultaneousGesture(dragGesture)
    }
    
    private var mainCircleColor: Color {
        if recordControlVM.recordState.isRecording {
            return Color.appPrimary
        } else if recordControlVM.recordState.isPreparedDiscard {
            return Color.appBackgroundColorDim
        } else {
            return Color.gray
        }
    }
    
    private var scaleEffectValue: CGFloat {
        if recordControlVM.recordState.isConnecting {
            return 0.85
        } else if recordControlVM.recordState.isInModeRecord {
            return 0.9
        } else {
            return 1.0
        }
    }
    
    private var timerView: some View {
        Group {
            if recordControlVM.recordState.isInModeRecord {
                TimerUpView()
                    .foregroundColor(recordControlVM.recordState.isPreparedDiscard ? .red : .appPrimary)
            }
        }
    }
    
    private var instructionTextView: some View {
        Group {
            if recordControlVM.recordState.isInModeRecord {
                Text("Release to send")
                    .font(.system(size: 18))
                    .foregroundColor(.appForegroundColorDim)
                    .opacity(recordControlVM.recordState.isPreparedDiscard ? 0.0 : 1.0)
            }
        }
    }
    
    private var recordActionTextView: some View {
        Text("\(recordControlVM.recordActionFlow.rawValue)")
            .font(.system(size: 16))
            .foregroundColor(.appForeground)
    }
    
    private var dragGesture: some Gesture {
        DragGesture(minimumDistance: 0, coordinateSpace: .global)
            .updating($dragLocation) { value, state, _ in
                state = value.location
            }
            .onEnded { _ in
                self.onFinishDragGesture()
            }
    }
}


#Preview {
    RecordAreaWrapper()
}
