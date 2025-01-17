//
//  ContentView.swift
//  RawUIRecord
//
//  Created by Phu Pham on 2/10/24.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea(.all)
                
                VStack {
                    Button(action: {}) {
                        NavigationLink(destination: SlotGameView(), label: {
                            Text("Slot Game Demo")
                        })
                    }
                    .buttonStyle(PrimaryButton())
                    
                    Button(action: {}) {
                        NavigationLink(destination: CarouselTourGuide(), label: {
                            Text("Carousel Tour Guide")
                        })
                    }
                    .buttonStyle(PrimaryButton())
                    
                    Button(action: {}) {
                        NavigationLink(destination: WaveFormView(), label: {
                            Text("WaveForm View")
                        })
                    }
                    .buttonStyle(PrimaryButton())
                    

                    Button(action: {}) {
                        NavigationLink(destination: RecordLayoutWrapper(), label: {
                            Text("Record View")
                        })
                    }
                    .buttonStyle(PrimaryButton())
                }
            }
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
