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
    
    var body: some View {
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
}

#Preview {
    AlertView(gov: Governor(), eg: .constant(PreviewEG().eg()))
}
