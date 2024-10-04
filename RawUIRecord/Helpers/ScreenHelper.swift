//
//  ScreenHelper.swift
//  RawUIRecord
//
//  Created by Phu Pham on 3/10/24.
//

import SwiftUI

struct ScreenHelper {
    static let width: CGFloat = UIScreen.main.bounds.width
    static let height: CGFloat = UIScreen.main.bounds.height
    
    static let standardWidth: CGFloat = 1080
    static let standardHeight: CGFloat = 1920
    
    static let timelineImageSize = width
    
    static func ratioToHeight(_ width: CGFloat, _ ratio: CGFloat) -> CGFloat {
        return CGFloat(Int(width * ratio))
    }
}
