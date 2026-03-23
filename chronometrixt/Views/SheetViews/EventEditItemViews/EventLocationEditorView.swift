//
//  EventLocationEditorView.swift
//  chronometrixt
//
//  Created by Becket Bowes on 3/22/26.
//

import SwiftUI

struct EventLocationEditorView: View {
    @Bindable var eg: EventGovernor
    @FocusState private var focus: Bool
    
    var body: some View {
        VStack {
            MetrixtSubdivider()
            
            HStack {
                Text("location: ")
                    .font(.caption)
                Spacer()
            }
            .padding(.bottom)
            
            TextField("location", text: $eg.location)
                .focused($focus)
                .autocapitalization(.none)
                .onSubmit {
                    focus = false
                    eg.editField = .none
                }
                .padding()
                .background(RoundedRectangle(cornerRadius: 10).stroke(.gray))
                .padding(.bottom)
            
            SubmitButtonView(imageString: "mappin", text: "located", action: { focus = false; eg.editField = .none })
            
            MetrixtSubdivider()
        }
        .onAppear { focus = true }
    }
}

#Preview {
    EventLocationEditorView(
        eg: EventGovernor(
            title: "sample",
            starting: MetrixtTime(years: 5056, seconds: 123456),
            ending: MetrixtTime(years: 5056, seconds: 123459))
    )
}
