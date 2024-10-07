//
//  RecordControlViewModel.swift
//  RawUIRecord
//
//  Created by Phu Pham on 3/10/24.
//


import SwiftUI
enum RecordButtonType {
    case unset
    case cancel
    case record
}

enum RecordActionFlow: String {
    case unset
    case connectingDevice
    case holdingRecord
    case holdCancel
    case finishedRecord
    case canceledRecord
}

enum RecordingState {
    case unset
    case connecting
    case recording
    case prepareDiscard
    
    var isRecording: Bool { self == .recording }
    var isConnecting: Bool { self == .connecting }
    var isPreparedDiscard: Bool { self == .prepareDiscard }
    var isInModeRecord: Bool { [.recording, .prepareDiscard].contains(self) }
    var isNotUnsetMode: Bool { self != .unset }
}

class RecordControlViewModel: ObservableObject {
    // MARK: - Shared Instance
    private static var sharedInstance: RecordControlViewModel?

    static var shared: RecordControlViewModel {
        if let instance = sharedInstance {
            return instance
        }
        let instance = RecordControlViewModel()
        sharedInstance = instance
        return instance
    }

    static func destroy() {
        sharedInstance = nil
    }
    
    @Published var recordState: RecordingState = .unset {
        willSet {
            updateRecordActionFlow(for: newValue)
        }
    }
    
    @Published var recordActionFlow: RecordActionFlow = .unset
    var isLoadedConnect = false

    // MARK: - Private Methods
    private func updateRecordActionFlow(for newState: RecordingState) {
        switch newState {
        case .connecting:
            recordActionFlow = .connectingDevice
        case .recording:
            recordActionFlow = .holdingRecord
        case .prepareDiscard:
            recordActionFlow = .holdCancel
        case .unset:
            break
        }
    }
    
    // MARK: - Actions
    func setActionFlow(_ flow: RecordActionFlow) {
        guard flow != recordActionFlow else { return }
        recordActionFlow = flow
    }
    
    func setRecordState(_ state: RecordingState) {
        guard state != recordState else { return }
        recordState = state
    }
    
    func onMakeRecordAction() {
        guard recordState == .unset || recordState == .prepareDiscard else { return }

        if isLoadedConnect {
            recordState = .recording
        } else {
            recordState = .connecting
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                if self.recordState.isNotUnsetMode {
                    self.recordState = .recording
                    self.isLoadedConnect = true
                }
            }
        }
    }
    
    func onChangeButtonTypeAction(to newType: RecordButtonType, from oldType: RecordButtonType) {
        if newType == .record && !recordState.isRecording {
            onMakeRecordAction()
        } else if oldType == .cancel && recordState.isPreparedDiscard {
            recordState = .recording
        } else if newType == .cancel && recordState.isRecording {
            recordState = .prepareDiscard
        }
    }
    
    func onFinishRecordAction() {
        switch recordState {
        case .recording:
            setActionFlow(.finishedRecord)
        case .prepareDiscard:
            setActionFlow(.canceledRecord)
        default:
            break
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            if !self.recordState.isInModeRecord {
                self.setActionFlow(.unset)
            }
        }
        
        setRecordState(.unset)
    }
}
