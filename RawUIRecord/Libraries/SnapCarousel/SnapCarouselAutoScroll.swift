//
//  SnapCarouselAutoScroll.swift
//  
//
//  Created by Phu Pham on 13/11/24.
//

import SwiftUI

public enum SnapCarouselAutoScroll: Equatable {
    case inactive
    case active(TimeInterval)
    /// When `activeOneTime` enable mean autoScroll only happend into last item
    case activeOneTime(TimeInterval)
}

extension SnapCarouselAutoScroll {
    
    /// default active
    public static var defaultActive: Self {
        return .active(5)
    }
    
    /// Is the view auto-scrolling
    var isActive: Bool {
        switch self {
        case .inactive:
            return false
        case .active(let timeInterval), .activeOneTime(let timeInterval):
            return timeInterval > 0
        }
    }
    
    var isActiveOneTime: Bool {
        if case .activeOneTime = self {
            return true
        }
        return false
    }
    
    /// Duration of automatic scrolling
    var interval: TimeInterval {
        switch self {
        case .inactive:
            return 0
        case .active(let timeInterval), .activeOneTime(let timeInterval):
            return timeInterval
        }
    }
}
