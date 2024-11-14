//
//  View+ReceiveTimer.swift
//
//
//  Created by Phu Pham on 13/11/24.
//

import SwiftUI
import Combine

typealias TimePublisher = Publishers.Autoconnect<Timer.TimerPublisher>

extension View {
    func onReceiveTimerListener(timer: TimePublisher?, perform action: @escaping (Timer.TimerPublisher.Output) -> Void) -> some View {
        Group {
            if let timer = timer {
                self.onReceive(timer) { value in
                    action(value)
                }
            } else {
                self
            }
        }
    }
}
