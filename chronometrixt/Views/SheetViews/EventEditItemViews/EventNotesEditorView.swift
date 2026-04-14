//
//  EventNotesEditorView.swift
//  chronometrixt
//
//  Created by Becket Bowes on 3/22/26.
//

import SwiftUI

struct EventNotesEditorView: View {
    @Bindable var eg: EventGovernor
    @FocusState private var focus: Bool
    
    var body: some View {
        VStack {
            MetrixtSubdivider()
            
            HStack {
                Text("notes: ")
                    .font(.caption)
                Spacer()
            }
            .padding(.bottom)
            
            TextEditor(text: $eg.notes)
                .focused($focus)
                .frame(height: 100)
                .padding()
                .background(RoundedRectangle(cornerRadius: 10).stroke(.gray))
                .padding(.bottom)
                .onSubmit { focus = false; eg.editField = .none }
                .onAppear { focus = true }
            
            SubmitButtonView(imageString: "music.note", text: "noted", action: { eg.editField = .none })
            
            MetrixtSubdivider()
        }
        .onTapGesture {
            focus.toggle()
        }
    }
}

#Preview {
    EventNotesEditorView(eg: PreviewEG().eg())
}
