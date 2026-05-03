//
//  EventParticipantView.swift
//  chronometrixt
//
//  Created by Becket Bowes on 3/22/26.
//

import SwiftUI

struct EventParticipantView: View {
    @Bindable var eg: EventComptroller
    
    var body: some View {
        VStack {
            MetrixtSubdivider()
            
            ForEach(eg.participants) { partygoer in
                HStack {
                    Text(partygoer.name + " : ")
                        .bold()
                    Text("\(partygoer.status.rawValue)" + " : ")
                    Text("\(partygoer.role.rawValue)")
                }
            }
            
            SubmitButtonView(imageString: "person.3", text: "okay then", action: { eg.editField = .none })
            
            MetrixtSubdivider()
        }
    }
}

#Preview {
    EventParticipantView(eg: PreviewEG().eg())
}
