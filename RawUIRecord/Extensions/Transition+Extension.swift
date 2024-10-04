//
//  Transition+Extension.swift
//  RawUIRecord
//
//  Created by Phu Pham on 3/10/24.
//

import SwiftUI

extension AnyTransition {
    /// This transition will cause the view to disappear,
    /// until the last frame of the animation is reached
    static var invisible: AnyTransition {
        AnyTransition.modifier(
            active: InvisibleModifier(pct: 0),
            identity: InvisibleModifier(pct: 1)
        )
    }
    
    struct InvisibleModifier: AnimatableModifier {
        var pct: Double
        
        var animatableData: Double {
            get { pct }
            set { pct = newValue }
        }
        
        
        func body(content: Content) -> some View {
            content.opacity(pct == 1.0 ? 1 : 0)
        }
    }
}
