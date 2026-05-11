//
//  EventEditView.swift
//  chronometrixt
//
//  Created by Becket on 3/23/26.
//

import SwiftUI
import SwiftData

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
    @Previewable @Environment(\.modelContext) var context
    EventEditView(gov: Governor(context: context))
}
