//
//  chronometrixtApp.swift
//  chronometrixt
//
//  Created by Becket Bowes on 12/30/25.
//

import SwiftUI
import SwiftData

@main struct chronometrixtApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @State private var gov: Governor = Governor()
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            MetricEvent.self,
            MetricCalendar.self,
            MetricAlarm.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            let container = try ModelContainer(for: schema, configurations: [modelConfiguration])
            return container
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView(gov: gov)
                .onAppear { appDelegate.gov = gov }
        }
        .modelContainer(sharedModelContainer)
    }
}
