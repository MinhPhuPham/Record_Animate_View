//
//  SlotMachineAutoScrollView+Model.swift
//  RawUIRecord
//
//  Created by Phu Pham on 16/1/25.
//

import UIKit

struct SlotMachineCongfigure {
    var visibleItemsCount: Int = 3
    // Adjust this for faster scrolling
    var scrollSpeed: CGFloat = 35.0
    
    var buffer: Int {
        visibleItemsCount * 2
    }
}

struct SlotMachineItemModel {
    var imageName: String = ""
    var backgroundColor: UIColor = .clear
    var imageScaleRatioWithParent: CGFloat = 0.8
}
