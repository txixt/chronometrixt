//
//  ContentView.swift
//  chronometrixt
//
//  Created by Becket Bowes on 12/30/25.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDel
    @Environment(\.scenePhase) private var scene
    @Query var calendars: [MetricCalendar]
    @Environment(\.modelContext) private var context
    @Query private var items: [MetricEvent]
    @State var gov: Governor = Governor()
    @State var eg: EventGovernor?
    @State var ag: AlarmGovernor = AlarmGovernor()
    @State var ng: NotificationGovernor = NotificationGovernor()
    
    var body: some View {
        GeometryReader { geo in
            
            NavigationStack {
                
                ZStack {
#if os(iOS)
                if geo.size.width > geo.size.height {
                    LandscapeView(gov: gov)
                } else {
                    ZStack {
                        PortraitView(gov: gov, eg: $eg, ag: ag, ng: ng)
                        
                        AlertView(gov: gov, eg: $eg)
                    }
                }
#endif
#if os(macOS)
                ComputerView(gov: gov)
                    .monospaced()
#endif
                }
                .environment(gov)
                .environment(eg)
                .environment(ng)
                .environment(ag)
                .task {
                    let granted = await ng.requestAuthorization()
                    if !granted {
                        gov.errorMessage = "alarms and notifications will not work"
                        gov.alert = .error
                    }
                }
                .onChange(of: scene) { _, new in
                    if new == .background || new == .inactive { gov.eternalNow.killTimer() }
                    else { gov.eternalNow.restartTimer() }
                }
                .onChange(of: geo.size) { _, new in
                    gov.geoSize = new
                }
                .onAppear {
                    ng.gov = gov
                    ag.ng = ng
                    appDel.governor = gov
                    appDel.alarmGovernor = ag
                    appDel.notificationGovernor = ng
                    if calendars.isEmpty { context.insert(CalInitializer.first())
                }
                    
            }
                
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
                                Button(action: {}) {
                                    Image(systemName: "magnifyingglass")
                                    Text("search")
                                }
                            }
                        }
                    }
                    ToolbarSpacer(placement: .bottomBar)
                    ToolbarItem(placement: .bottomBar) {
                        Button(action: { eg = nil; gov.sheet = .makeEvent }) {
                            Image(systemName: "plus")
                        }
                        .disabled(gov.finiteNotNow == nil)
                    }
                
            }
#endif
#if os(macOS)
                ToolbarItemGroup {
                    Button(action: { gov.sheet = .settings }) {
                        Image(systemName: "gear")
                        Text("settings")
                    }
                    Button(action: { gov.sheet = .timers }) {
                        Image(systemName: "bell")
                        Text("alarms")
                    }
                    Button(action: {}) {
                        Image(systemName: "magnifyingglass")
                        Text("search")
                    }
                    Button(action: { eg = nil; gov.sheet = .makeEvent }) {
                        Image(systemName: "plus")
                    }
                }
#endif
            }
            
        }
        
    }
}

#Preview {
    ContentView()
//        .modelContainer(for: MetricEvent.self, inMemory: true)
}

