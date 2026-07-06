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
    @Environment(\.modelContext) private var context
    @Query private var items: [MetricEvent]
    @Query var calendars: [MetricCalendar]
    @Bindable var gov: Governor
    
    var body: some View {
        GeometryReader { geo in
            
            NavigationStack {
                
                ZStack {
#if os(iOS)
                    if geo.size.width > geo.size.height {
                        LandscapeView(gov: gov)
                    } else {
                        ZStack {
                            PortraitView(gov: gov)
                            
                            AlertView(gov: gov)
                        }
                    }

#endif
#if os(macOS)
                    if let gov {
                        ComputerView(gov: gov)
                            .monospaced()
                    }
#endif
                }
                .environment(gov)
//                .task { try? await authorize() }
                .onChange(of: scene) { _, new in
                    toggleEscapement(scene: new)
                }
                .onChange(of: geo.size) { _, new in
                    gov.geoSize = new
                }
                .onAppear { initialize() }
                
            }
            .toolbar {
#if os(iOS)
            if geo.size.width < geo.size.height {
                    ToolbarItem(placement: .bottomBar) {
                        Menu("settings, alarm, search", systemImage: "gear") {
                            Group {
                                Button(action: { gov.sheet = .settings }) {
                                    Image(systemName: "gear")
                                    Text("settings")
                                }
                                Button(action: { gov.sheet = .timers }) {
                                    Image(systemName: "bell")
                                    Text("alarms")
                                }
                                Button(action: { gov.sheet = .search }) {
                                    Image(systemName: "magnifyingglass")
                                    Text("search")
                                }
                            }
                        }
                    }
                    ToolbarSpacer(placement: .bottomBar)
                    ToolbarItem(placement: .bottomBar) {
                        Button(action: createEvent) {
                            Image(systemName: "plus")
                        }
                        .disabled(gov.finiteNotNow == nil)
                    }
            }
#endif
#if os(macOS)
                ToolbarItemGroup {
                    Button(action: { gov?.sheet = .settings }) {
                        Image(systemName: "gear")
                        Text("settings")
                    }
                    Button(action: { gov?.sheet = .timers }) {
                        Image(systemName: "bell")
                        Text("alarms")
                    }
                    Button(action: gov?.sheet = .search) {
                        Image(systemName: "magnifyingglass")
                        Text("search")
                    }
                    Button(action: { createEvent() }) {
                        Image(systemName: "plus")
                    }
                }
#endif
            }
            
        }
        
    }
    
    private func initialize() {
        print("starting initialize")
        gov.context = context
        if calendars.isEmpty { context.insert(CalInitializer.first()) }
        gov.eventData = items
        gov.calendarData = calendars
    }
    
    private func authorize() async throws {
        let granted = await NotificationAgent.shared.requestAuthorization()
        if !granted {
            gov.alertTxt = "alarms and notifications will not work - please allow notifications in settings for full functionality"
            gov.alert = .error
        }
    }
    
    private func toggleEscapement(scene: ScenePhase) {
        if scene == .background || scene == .inactive { gov.eternalNow.killTimer() }
        else { gov.eternalNow.restartTimer() }
    }
    
    private func createEvent() {
        gov.ec = nil
        gov.sheet = .makeEvent
    }
}

#Preview {
    ContentView(gov: Governor())
}

