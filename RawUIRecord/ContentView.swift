//
//  ContentView.swift
//  RawUIRecord
//
//  Created by Phu Pham on 2/10/24.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea(.all)
            
            RecordLayoutWrapper()
        }
    }
}

#Preview {
    ContentView()
}


extension Color {
    static var grayDark: Color {
        Color(red: 81/255, green: 77/255, blue: 81/255)
    }
}

private struct RecordLayoutWrapper: View {
    var body: some View {
        ZStack {
            Color.black
            
            VStack(spacing: 60) {
                HorizontalSelectorList()
                
                RecordAreaWrapper()
            }
        }
    }
}

