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
    @Binding var eg: EventGovernor?
    @Bindable var ag: AlarmGovernor
    @Bindable var ng: NotificationGovernor
    
    var body: some View {
        NavigationStack {
            
            ZStack {
                
                CalendarScrollView(gov: gov)
                    .ignoresSafeArea()
                
                TimeControlView(gov: gov)
                
            }
            .onChange(of: gov.event) { eg = gov.event != nil ? EventGovernor(event: gov.event!, context: context, gov: gov) : nil }
            .sheet(item: $gov.sheet) { sheet in
                switch sheet {
                case .makeEvent: EventCreationView(gov: gov, eventGov: $eg, ag: ag, ng: ng)
                case .editEvent:
                    if eg != nil {
                        EventEditView(gov: gov, eg: $eg, ag: ag, ng: ng)
                    } else {
                        EmptyView().onAppear { gov.sheet = nil }
                    }
                case .showEvent:
                    if eg != nil  {
                        EventDisplayView(gov: gov, eg: $eg, ag: ag, ng: ng)
                    } else {
                        EmptyView().onAppear { gov.sheet = nil }
                    }
                case .settings: SettingsView(gov: gov, eg: $eg, ag: ag, ng: ng)
                case .timers: SmallTimesView(gov: gov, eg: $eg, ag: ag, ng: ng)
                default: EmptyView()
//                case .makeEvent: EventCreationView(gov: gov, eventGov: $eg).alertHost(gov: gov, eg: eg)
//                case .editEvent:
//                    if let eg {
//                        EventEditView(gov: gov, eg: eg).alertHost(gov: gov, eg: eg)
//                    } else {
//                        EmptyView().onAppear { gov.sheet = nil }
//                    }
//                case .showEvent:
//                    if let eg {
//                        EventDisplayView(gov: gov, eg: eg).alertHost(gov: gov, eg: eg)
//                    } else {
//                        EmptyView().onAppear { gov.sheet = nil }
//                    }
//                case .settings: SettingsView(gov: gov)
//                case .timers: SmallTimesView(gov: gov)
//                default: EmptyView()
                }
            }
        }

    }
}

//struct AlertHost<Content: View>: View {
//    @Bindable var gov: Governor
//    var eg: EventGovernor?
//    let content: Content
//
//    init(gov: Governor, eg: EventGovernor? = nil, @ViewBuilder content: () -> Content) {
//        self.gov = gov
//        self.eg = eg
//        self.content = content()
//    }
//
//    var body: some View {
//        ZStack {
//            content
//            if let alert = gov.alert {
//                switch alert {
//                case .error: ErrorAlertView(gov: gov)
//                case .destroyEvent:
//                    if let eg {
//                        DestroyEventAlertView(gov: gov, eg: eg)
//                    }
//                default: EmptyView().onAppear { gov.alert = nil }
//                }
//            }
//        }
//    }
//}
//extension View {
//    func alertHost(gov: Governor, eg: EventGovernor? = nil) -> some View {
//        AlertHost(gov: gov, eg: eg) { self }
//    }
//}

#Preview {
    PortraitView(gov: Governor(), eg: .constant(PreviewEG().eg()), ag: AlarmGovernor(), ng: NotificationGovernor())
}
