//
//  ContentView.swift
//  chronometrixt
//
//  Created by Becket Bowes on 12/30/25.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.scenePhase) private var scene
    @Query var calendars: [MetricCalendar]
    @Environment(\.modelContext) private var context
//    @Environment(\.modelContext) private var context
    @Query private var items: [MetricEvent]
    @State var gov: Governor = Governor()
    
    var body: some View {
        ZStack {
#if os(iOS)
            MobileView(gov: gov)
#endif
#if os(macOS)
            ComputerView(gov: gov)
#endif
        }
        .onChange(of: scene) { _, new in
            if new == .background || new == .inactive {
                gov.eternalNow.killTimer()
            } else {
                gov.eternalNow.restartTimer()
            }
        }
        .onAppear {
            if calendars.isEmpty { context.insert(CalInitializer.first())
            }
        }
    }
}

#Preview {
    ContentView()
//        .modelContainer(for: MetricEvent.self, inMemory: true)
}

