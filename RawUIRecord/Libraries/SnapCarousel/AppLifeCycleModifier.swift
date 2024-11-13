//
//  AppLifeCycleModifier.swift
//  
//
//  Created by Phu Pham on 13/11/24.
//

import SwiftUI

#if os(macOS)
import AppKit
typealias Application = NSApplication
#else
import UIKit
typealias Application = UIApplication
#endif

/// Monitor and receive application life cycles,
/// inactive or active
struct AppLifeCycleModifier: ViewModifier {
    
    let active = NotificationCenter.default.publisher(for: Application.didBecomeActiveNotification)
    
    let inactive = NotificationCenter.default.publisher(for: Application.willResignActiveNotification)
    
    private let action: (Bool) -> Void
    
    init(_ action: @escaping (Bool) -> Void) {
        self.action = action
    }
    
    func body(content: Content) -> some View {
        content
            .onAppear {
                /// `onReceive` will not work in the Modifier Without `onAppear`
            }
            .onReceive(active) { _ in
                action(true)
            }
            .onReceive(inactive) { _ in
                action(false)
            }
    }
}

extension View {
    func onReceiveAppLifeCycle(perform action: @escaping (Bool) -> Void) -> some View {
        self.modifier(AppLifeCycleModifier(action))
    }
}
