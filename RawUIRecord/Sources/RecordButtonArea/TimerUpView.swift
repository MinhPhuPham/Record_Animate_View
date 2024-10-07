//
//  TimerUpView.swift
//  RawUIRecord
//
//  Created by Phu Pham on 3/10/24.
//

import SwiftUI
import Combine

class TimerViewModel: ObservableObject {
    @Published var timeString: String = "0:00"
    
    private var timerSubscription: AnyCancellable?
    private var startTime: Date?
    
    init() {
        startTimer()
    }
    
    private func startTimer() {
        startTime = Date()
        timerSubscription = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .map { _ in
                self.calculateTimeElapsed()
            }
            .assign(to: \.timeString, on: self)
    }
    
    private func calculateTimeElapsed() -> String {
        guard let startTime = startTime else { return "0:00" }
        
        let elapsedTime = Date().timeIntervalSince(startTime)
        let minutes = Int(elapsedTime) / 60
        let seconds = Int(elapsedTime) % 60
        
        return String(format: "%d:%02d", minutes, seconds)
    }
    
    deinit {
        timerSubscription?.cancel()
    }
}

struct TimerUpView: View {
    @StateObject private var timerVM = TimerViewModel()
    
    var body: some View {
        Text(timerVM.timeString)
            .font(.system(size: 16, weight: .medium))
            .padding()
    }
}
