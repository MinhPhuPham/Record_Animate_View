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
