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

class RecordControlViewModel: ObservableObject {
    // MARK: - Shared
    private static var sharedInstance: RecordControlViewModel?
    class var shared : RecordControlViewModel {
        guard let sharedInstance = self.sharedInstance else {
            let sharedInstance = RecordControlViewModel()
            self.sharedInstance = sharedInstance
            return sharedInstance
        }
        
        return sharedInstance
    }
    
    class func destroy() {
        sharedInstance = nil
    }
    
    @Published var recordState: RecordingState = .unset
    
    var isLoadedConnect: Bool = false
    
    // MARK: Bool func check
    func isConnecting() -> Bool {
        recordState == .connecting
    }
    
    func isRecording() -> Bool {
        recordState == .recording
    }
    
    func isPreparedDiscard() -> Bool {
        recordState == .prepareDiscard
    }
    
    func isInModeRecord() -> Bool {
        [.recording, .prepareDiscard].contains(recordState)
    }
    
    func isNotUnsetMode() -> Bool {
        recordState != .unset
    }
}

// MARK: Actions
extension RecordControlViewModel {
    func setRecordState(_ state: RecordingState) {
        if state != recordState {
            recordState = state
        }
    }
    
    func onMakeRecordAction() {
        if recordState == .unset || recordState == .prepareDiscard {
            if isLoadedConnect {
                recordState = .recording
            } else {
                recordState = .connecting

                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    if self.recordState != .unset {
                        self.recordState = .recording
                        self.isLoadedConnect = true
                    }
                }
            }
        }
    }
    
    func onChangeButtonTypeAction(newType: RecordButtonType, oldType: RecordButtonType) {
        if newType == .record && recordState != .recording {
            onMakeRecordAction()
        } else if oldType == .cancel && recordState == .prepareDiscard {
            recordState = .recording
        } else if newType == .cancel && recordState == .recording {
            recordState = .prepareDiscard
        }
    }
}
