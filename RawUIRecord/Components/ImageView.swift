//
//  ImageView.swift
//  RawUIRecord
//
//  Created by Phu Pham on 3/10/24.
//

import SwiftUI
import NukeUI

struct ImageView: View {
    let imageURL: String
    var ratio: CGFloat = 1.0
    var width: CGFloat = .infinity
    
    var onSuccess: (() -> Void)? = nil
    var onFailure: (() -> Void)? = nil
    
    var body: some View {
        return VStack {
            LazyImage(url: URL(string: imageURL))
                .onCompletion{ response in
                    switch response {
                    case .success(let success):
                        if let onSuccessFunc = onSuccess {
                            onSuccessFunc()
                        }
                    case .failure(let failure):
                        if let onFailure = onFailure {
                            onFailure()
                        }
                    }
 
                }
        }
        // Convert height to INT to make save photo don't have white border at bottom.
        .frame(width: width, height: CGFloat(Int(ratio * width)))
    }
}

struct RadiusConstants {
    static let CornerRadiusSM: CGFloat = 8
    static let CornerRadiusMD: CGFloat = 10
    static let CornerRadiusLG: CGFloat = 20
}

struct InAppImageView: View {
    var name: String
    var contentMode: ContentMode = .fit

    var body: some View {
        Image(name)
            .resizable()
            .aspectRatio(contentMode: contentMode)
    }
}

extension View {
    var radiusShapeSM: some View {
        self.clipShape(RoundedRectangle(cornerRadius: RadiusConstants.CornerRadiusSM, style: .continuous))
    }
    
    var radiusShapeMD: some View {
        self.clipShape(RoundedRectangle(cornerRadius: RadiusConstants.CornerRadiusMD, style: .continuous))
    }
    
    var radiusShapeLG: some View {
        self.clipShape(RoundedRectangle(cornerRadius: RadiusConstants.CornerRadiusLG, style: .continuous))
    }
}
