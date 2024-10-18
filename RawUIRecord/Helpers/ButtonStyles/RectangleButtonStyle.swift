//
//  RectangleButtonStyle.swift
//  RawUIRecord
//
//  Created by Phu Pham on 18/10/24.
//

import SwiftUI

struct PrimaryButton: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .background(Color.appPrimary)
            .foregroundStyle(.appBackground)
            .font(Font.title)
            .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}
