//
//  SlotMachineAutoScrollView+Model.swift
//  RawUIRecord
//
//  Created by Phu Pham on 16/1/25.
//

import UIKit

struct SlotMachineConfigure {
    var visibleItemsCount: Int = 1
    // Adjust this for faster scrolling
    var scrollSpeed: CGFloat = 30.0
    
    var buffer: Int {
        visibleItemsCount * 2
    }
}

struct SlotMachineItemModel {
    var imageName: String = ""
    var backgroundColor: UIColor = .clear
    var imageScaleRatioWithParent: CGFloat = 0.8
}
