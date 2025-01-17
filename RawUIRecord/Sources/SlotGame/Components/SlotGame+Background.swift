//
//  SlotGame+Background.swift
//  RawUIRecord
//
//  Created by Phu Pham on 15/1/25.
//

import SwiftUI

struct SlotGameBackgroundView: View {
    var body: some View {
        Image("slot-background")
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
            .edgesIgnoringSafeArea(.all)
    }
}
