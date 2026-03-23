//
//  EventTitleEditorView.swift
//  chronometrixt
//
//  Created by Becket Bowes on 3/19/26.
//

import SwiftUI

struct EventTitleEditorView: View {
    @Bindable var eg: EventGovernor
    @FocusState private var isFocused: Bool
    
    var body: some View {
        VStack {
            MetrixtSubdivider()
            
            VStack {
                
                HStack {
                    Text("title:")
                        .font(.caption)
                    Spacer()
                }
                .padding(.bottom)
                
                TextField("event title", text: $eg.title)
                    .focused($isFocused)
                    .autocapitalization(.none)
                    .padding()
                    .onSubmit {
                        isFocused = false
                        eg.editField = .none
                    }
                    .background(RoundedRectangle(cornerRadius: 10).stroke(.gray))
                    .padding(.bottom)
                
                SubmitButtonView(imageString: "checkmark", text: "adjusted", action: { isFocused = false; eg.editField = .none })
                
            }
            
            MetrixtSubdivider()
        }
        .onAppear { isFocused = true }
    }
}

#Preview {
    EventTitleEditorView(
        eg: EventGovernor(
            title: "sample",
            starting: MetrixtTime(years: 5056, seconds: 123456),
            ending: MetrixtTime(years: 5056, seconds: 123459))
    )
}
