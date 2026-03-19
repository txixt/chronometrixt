//
//  PortraitView.swift
//  chronometrixt
//
//  Created by Becket Bowes on 12/31/25.
//

import SwiftUI

struct PortraitView: View {
    @Bindable var gov: Governor
    var body: some View {
        NavigationView {
            ZStack {
                
                CalendarScrollView(gov: gov)
                
                TimeControlView(gov: gov)
                
                if gov.alert != nil {
                    switch gov.alert {
                    case .error: ErrorAlertView(gov: gov)
                    default: EmptyView()
                    }
                }
                
            }
            .monospaced()
        }
        .toolbar {
            ToolbarItemGroup(placement: .bottomBar) {
                Menu("settings", systemImage: "gear") {
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
            case .makeEvent: EventCreationView(gov: gov)
            case .settings: SettingsView(gov: gov)
            default: EmptyView()
            }
        }
    }
}

#Preview {
    PortraitView(gov: Governor())
}
