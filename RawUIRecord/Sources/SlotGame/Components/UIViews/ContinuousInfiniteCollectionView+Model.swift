//
//  ContinuousInfiniteCollectionView+Model.swift
//  RawUIRecord
//
//  Created by Phu Pham on 16/1/25.
//

import UIKit

struct CongfigureContinuousInfinite {
    let visibleItemsCount: Int = 3
    // Adjust this for faster scrolling
    var scrollSpeed: CGFloat = 35.0
    
    var buffer: Int {
        visibleItemsCount * 2
    }
}

struct ContinuousInfiniteModel {
    var imageName: String = ""
    var backgroundColor: UIColor = .clear
    var imageScaleRatioWithParent: CGFloat = 0.8
}
