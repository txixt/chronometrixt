//
//  EventEditView.swift
//  chronometrixt
//
//  Created by Becket on 3/23/26.
//

import SwiftUI

struct EventEditView: View {
    @Bindable var gov: Governor
    @Bindable var eg: EventGovernor
    
    var body: some View {
        let truncatedTitl: String = eg.title.split(separator: " ", maxSplits: 2).prefix(2).joined(separator: " ")
        
        VStack {
            SheetHeaderView(gov: gov, title: "edit \(truncatedTitl)", titleImage: "wrench")
            
            EventEditMainView(gov: gov, eventGov: eg, update: true)
        }
        .padding()
    }
}

#Preview {
    EventEditView(gov: Governor(), eg: PreviewEG().eg() )
}
