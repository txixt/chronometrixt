//
//  AlertView.swift
//  chronometrixt
//
//  Created by Becket Bowes on 4/26/26.
//

import SwiftUI

struct AlertView: View {
    @Bindable var gov: Governor
    @Binding var eg: EventGovernor?
    @Bindable var ag: AlarmGovernor
    @Bindable var ng: NotificationGovernor
    
    var body: some View {
        if gov.alert != nil {
            switch gov.alert {
            case .event: EventAlertView(gov: gov)
            case .alarm: AlarmAlertView(gov: gov, ag: ag , ng: ng)
            case .timer: TimerAlertView(gov: gov, ag: ag)
            case .error: ErrorAlertView(gov: gov)
            case .destroyEvent:
                if let eg {
                    DestroyEventAlertView(gov: gov, eg: eg)
                }
            default: EmptyView()
            }
        }
    }
}

#Preview {
    AlertView(gov: Governor(), eg: .constant(PreviewEG().eg()), ag: AlarmGovernor(), ng: NotificationGovernor())
}
