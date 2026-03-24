//
//  PortraitView.swift
//  chronometrixt
//
//  Created by Becket Bowes on 12/31/25.
//

import SwiftUI
import SwiftData

struct PortraitView: View {
    
    @Environment(\.modelContext) private var context
    @Bindable var gov: Governor
    @State var eg: EventGovernor?
    
    var body: some View {
        NavigationStack {
            ZStack {
                
                CalendarScrollView(gov: gov)
                
                TimeControlView(gov: gov)
                
                if gov.alert != nil {
                    switch gov.alert {
                    case .error: ErrorAlertView(gov: gov)
                    case .destroyEvent:
                        if let eg {
                            DestroyEventAlertView(gov: gov, eg: eg)
                        }
                    default: EmptyView()
                    }
                }
                
            }
            .monospaced()
        }
        .toolbar {
            ToolbarItemGroup(placement: .bottomBar) {
                Menu("settings, alarm, search", systemImage: "gear") {
                    Group {
                        Button(action: { gov.sheet = .settings }) {
                            Image(systemName: "gear")
                            Text("settings")
                        }
                        Button(action: {}) {
                            Image(systemName: "bell")
                            Text("alarms")
                        }
                        Button(action: {}) {
                            Image(systemName: "magnifyingglass")
                            Text("search")
                        }
                    }
                }
                Spacer()
                if gov.finiteNotNow != nil {
                    Button(action: { eg = nil; gov.sheet = .makeEvent }) {
                        Image(systemName: "plus")
                    }
                } else {
                    Image(systemName: "plus")
                        .opacity(0.5)
                }
            }
        }
        .sheet(item: $gov.sheet) { sheet in
            switch sheet {
            case .makeEvent: EventCreationView(gov: gov, eventGov: $eg).alertHost(gov: gov, eg: eg)
            case .editEvent:
                if let eg {
                    EventEditView(gov: gov, eg: eg).alertHost(gov: gov, eg: eg)
                } else {
                    EmptyView().onAppear { gov.sheet = nil }
                }
            case .showEvent:
                if let eg {
                    EventDisplayView(gov: gov, eg: eg).alertHost(gov: gov, eg: eg)
                } else {
                    EmptyView().onAppear { gov.sheet = nil }
                }
            case .settings: SettingsView(gov: gov)
            default: EmptyView()
            }
        }
        .onChange(of: gov.event) { eg = gov.event != nil ? EventGovernor(event: gov.event!, context: context, gov: gov) : nil }
    }
}

struct AlertHost<Content: View>: View {
    @Bindable var gov: Governor
    var eg: EventGovernor?
    let content: Content

    init(gov: Governor, eg: EventGovernor? = nil, @ViewBuilder content: () -> Content) {
        self.gov = gov
        self.eg = eg
        self.content = content()
    }

    var body: some View {
        ZStack {
            content
            if let alert = gov.alert {
                switch alert {
                case .error: ErrorAlertView(gov: gov)
                case .destroyEvent:
                    if let eg {
                        DestroyEventAlertView(gov: gov, eg: eg)
                    }
                default: EmptyView().onAppear { gov.alert = nil }
                }
            }
        }
    }
}
extension View {
    func alertHost(gov: Governor, eg: EventGovernor? = nil) -> some View {
        AlertHost(gov: gov, eg: eg) { self }
    }
}

#Preview {
    PortraitView(gov: Governor())
}
