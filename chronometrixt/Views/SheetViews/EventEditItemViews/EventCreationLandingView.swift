//
//  EventCreationLandingView.swift
//  chronometrixt
//
//  Created by Becket on 3/19/26.
//

import SwiftUI

struct EventCreationLandingView: View {
    @Bindable var gov: Governor
    @Binding var eventTitle: String
    @FocusState.Binding var focus: EventCreationView.FocusField?
    var onSubmit: () -> Void
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("event title:")
                .font(.caption2)
            TextField("event title", text: $eventTitle, prompt: Text("event title"))
                .focused($focus, equals: .initialTitle)
                .onChange(of: eventTitle) { _, new in
                    if new.count > 42 { eventTitle = String(new.prefix(42)) }
                }
                .padding()
                .background(RoundedRectangle(cornerRadius: 10).fill(.gray.opacity(0.2)))
                .onSubmit {
                    focus = nil
                    onSubmit()
                }
                .padding(.bottom)
                .onAppear { focus = .initialTitle }
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
    }
}

//#Preview {
//    EventCreationLandingView(gov: Governor(), eventTitle: .constant(""), focus: EventCreationView.FocusField.initialTitle)
//}
