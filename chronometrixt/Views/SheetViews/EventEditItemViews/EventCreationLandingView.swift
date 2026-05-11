//
//  EventCreationLandingView.swift
//  chronometrixt
//
//  Created by Becket on 3/19/26.
//

import SwiftUI
import SwiftData

struct EventCreationLandingView: View {
    @Bindable var gov: Governor
    @Binding var eventTitle: String
    @FocusState private var isFocused: Bool
    var onSubmit: () -> Void
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("event title:")
                .font(.caption)
                .padding(.bottom)
            
            TextField("event title", text: $eventTitle, prompt: Text("event title"))
                .focused($isFocused)
                .autocapitalization(.none)
                .padding()
                .background(RoundedRectangle(cornerRadius: 10).stroke(.gray))
                .onSubmit {
                    isFocused = false
                    onSubmit()
                }
                .padding(.bottom)
            
            VStack(alignment: .leading) {
                Text("metric:")
                Text(gov.finiteNotNow?.fullDateTxt ?? gov.eternalNow.time.fullDateTxt)
                    .font(.title2).bold()
            }
            
            VStack(alignment: .leading) {
                Text("gregorian:")
                Text(gov.finiteNotNow?.toGreg().formatted() ?? gov.eternalNow.time.toGreg().formatted())
                    .font(.title2).bold()
            }
        }
        .onAppear { isFocused = true }
    }
}

#Preview {
    @Previewable @Environment(\.modelContext) var context
    EventCreationLandingView(gov: Governor(context: context), eventTitle: .constant(""), onSubmit: {})
}
