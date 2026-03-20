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
                
                HStack {
                    TextField("event title", text: $eg.title )
                        .padding()
                        .focused($isFocused)
                        .onSubmit { isFocused = false; eg.editField = .none }
                        .autocapitalization(.none)
                        .background(RoundedRectangle(cornerRadius: 10).fill(.gray.opacity(0.2)))
                }
                .padding(.bottom)
                
                SubmitButtonView(imageString: "checkmark", text: "adjusted", action: { isFocused = false; eg.editField = .none })
                
            }
            
            MetrixtSubdivider()
        }
    }
}

#Preview {
    EventTitleEditorView(
        eg: EventGovernor(
            title: "sample",
            starting: MetrixtTime(years: 5056, seconds: 12345678),
            ending: MetrixtTime(years: 5056, seconds: 1234579)
        )
    )
}
