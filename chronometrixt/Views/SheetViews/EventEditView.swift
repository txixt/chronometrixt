//
//  EventEditView.swift
//  chronometrixt
//
//  Created by Becket on 3/23/26.
//

import SwiftUI

struct EventEditView: View {
    @Bindable var gov: Governor
    @Binding var eg: EventGovernor?
    @Bindable var ag: AlarmGovernor
    @Bindable var ng: NotificationGovernor
    
    var body: some View {
        let truncatedTitl: String = eg!.title.split(separator: " ", maxSplits: 2).prefix(2).joined(separator: " ")
        
        ZStack {
            VStack {
                SheetHeaderView(gov: gov, title: "edit \(truncatedTitl)", titleImage: "wrench")
                
                EventEditMainView(gov: gov, eventGov: eg!, update: true)
            }
            .padding()
            
            AlertView(gov: gov, eg: $eg, ag: ag, ng: ng)
        }
    }
}

#Preview {
    EventEditView(gov: Governor(), eg: .constant(PreviewEG().eg()), ag: AlarmGovernor(), ng: NotificationGovernor())
}
