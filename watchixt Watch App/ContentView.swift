//
//  ContentView.swift
//  watchixt Watch App
//
//  Created by Becket Bowes on 1/4/26.
//

import SwiftUI
import WatchKit

struct ContentView: View {
    @Environment(\.scenePhase) private var scenePhase
    @State var display: Bool = true
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                VStack {
                    Spacer()
                    
                    if display {
                        GlassWatchView(scale: scaleForWatch(geometry.size))
                    } else {
                        CalendarView()
                    }
                    
                    Spacer()
                }
                .onTapGesture(count: 1) { display.toggle() }
            }
            .padding(.top,30)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .ignoresSafeArea()
    }
    
    private func scaleForWatch(_ size: CGSize) -> CGFloat {
        let diameter = min(size.width, size.height)
        if diameter < 170 {
            return 1.6
        } else if diameter < 195 {
            return 1.8
        } else {
            return 1.8
        }
    }
}

#Preview {
    ContentView()
}
