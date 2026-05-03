//
//  EventEditView.swift
//  chronometrixt
//
//  Created by Becket on 3/23/26.
//

import SwiftUI

struct EventEditView: View {
    @Bindable var gov: Governor
    
    var body: some View {
        let truncatedTitl: String = gov.ec!.title.split(separator: " ", maxSplits: 2).prefix(2).joined(separator: " ")
        
        ZStack {
            VStack {
                SheetHeaderView(gov: gov, title: "edit \(truncatedTitl)", titleImage: "wrench")
                
                EventEditMainView(gov: gov, update: true)
            }
            .padding()
            
            AlertView(gov: gov)
        }
    }
}

#Preview {
    EventEditView(gov: Governor())
}
