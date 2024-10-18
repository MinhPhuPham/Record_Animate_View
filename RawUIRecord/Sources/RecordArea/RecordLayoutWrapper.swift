//
//  RecordLayoutWrapper.swift
//  RawUIRecord
//
//  Created by Phu Pham on 18/10/24.
//

import SwiftUI

struct RecordLayoutWrapper: View {
    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea(.all)
            
            VStack(spacing: 60) {
                HorizontalSelectorList()
                
                RecordAreaWrapper()
            }
        }
    }
}

