//
//  AlertView.swift
//  chronometrixt
//
//  Created by Becket Bowes on 4/26/26.
//

import SwiftUI

struct AlertView: View {
    @Bindable var gov: Governor
    
    var body: some View {
        if gov.alert != nil {
            switch gov.alert {
            case .event: EventAlertView(gov: gov)
            case .alarm: AlarmAlertView(gov: gov)
            case .timer: TimerAlertView(gov: gov)
            case .error: ErrorAlertView(gov: gov)
            case .destroyEvent:
                if gov.ec != nil {
                    DestroyEventAlertView(gov: gov)
                }
            default: EmptyView()
            }
        }
    }
}

#Preview {
    AlertView(gov: Governor())
}
