//
//  PortraitView.swift
//  chronometrixt
//
//  Created by Becket Bowes on 12/31/25.
//

import SwiftUI
import SwiftData

struct PortraitView: View {
//    @Query var events: [MetricEvent]
    
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
                    case .destroyEvent: DestroyEventAlertView(gov: gov)
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
                    Button(action: { gov.sheet = .makeEvent }) {
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
            case .makeEvent: EventCreationView(gov: gov).alertHost(gov: gov)
            case .editEvent:
                if let eg {
                    EventEditView(gov: gov, eg: eg).alertHost(gov: gov)
                } else {
                    EmptyView().onAppear { gov.sheet = nil }
                }
            case .showEvent:
                if let eg {
                    EventDisplayView(gov: gov, eg: eg).alertHost(gov: gov)
                } else {
                    EmptyView().onAppear { gov.sheet = nil }
                }
            case .settings: SettingsView(gov: gov)
            default: EmptyView()
            }
        }
        .onChange(of: gov.event) { eg = gov.event != nil ? EventGovernor(event: gov.event!, context: context) : nil }
    }
}

struct AlertHost<Content: View>: View {
    @Bindable var gov: Governor
    let content: Content

    init(gov: Governor, @ViewBuilder content: () -> Content) {
        self.gov = gov
        self.content = content()
    }

    var body: some View {
        ZStack {
            content
            if let alert = gov.alert {
                switch alert {
                case .error:
                    ErrorAlertView(gov: gov)
                case .destroyEvent:
                    DestroyEventAlertView(gov: gov)
                default:
                    EmptyView()
                }
            }
        }
    }
}
extension View {
    func alertHost(gov: Governor) -> some View {
        AlertHost(gov: gov) { self }
    }
}

#Preview {
    PortraitView(gov: Governor())
}


