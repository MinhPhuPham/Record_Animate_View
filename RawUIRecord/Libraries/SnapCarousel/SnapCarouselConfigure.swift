//
//  SnapCarouselConfigure.swift
//  RawUIRecord
//
//  Created by Phu Pham on 13/11/24.
//

import SwiftUI

struct SnapCarouselConfigure {
    
    ///   - spacing: default 0
    var spacing: CGFloat = 0
    ///   - headspace: default 0 -> left padding for first item
    var headspace: CGFloat = 0
    ///   - sidesScaling: sides scale, default 0.85
    var sidesScaling: CGFloat = 0.85
    ///   - isWrap: is cycle scroll, default false
    var isWrap: Bool = false
    ///   - autoScroll: is auto scroll, default .inactive -> setting for scroll
    var autoScroll: SnapCarouselAutoScroll = .inactive
    ///   - canMove: is manual scroll, default true
    var canMove: Bool = true
    ///   - anchorAnimateItem: is place for item scale animation
    var anchorAnimateItem: UnitPoint = .center
    ///
    var animationDuration: TimeInterval = 0.8
    
    var playControlOffetY: CGFloat = 0
    
    var pageIndicatorConfig: SnapCarouselPageIndicatorConfig = .init()
}

struct SnapCarouselPageIndicatorConfig {
    var normalSize: CGFloat = 8
    var selectedSize: CGFloat = 22
    var dotColor: Color = .gray
    
    var placement: Alignment = .bottom
    var pageIndicatorOffsetY: CGFloat = 20
}

enum SnapCarouselAutoScrollState {
    case active
    case temporaryDeactive
    case resetOneTime
    case unset
}
