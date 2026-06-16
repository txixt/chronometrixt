//
//  EventGregDateEditorView.swift
//  chronometrixt
//
//  Created by Becket Bowes on 3/19/26.
//

import SwiftUI

struct EventGregDateEditorView: View {
    @Bindable var eg: EventComptroller
    var target: EventComptroller.EditingFields
    
    var body: some View {
        let isStart = target == .startDateGreg
        
        VStack {
            MetrixtSubdivider()
            
            HStack {
                Text(isStart ? "adjust gregorian start time:" : "adjust gregorian end time:")
                    .font(.caption)
                Spacer()
            }
            .padding(.bottom)
            
            DatePicker("", selection: isStart ? $eg.gregStart : $eg.gregEnd, displayedComponents: [.date, .hourAndMinute])
                .datePickerStyle(.compact)
                .tint(.primary)
                .foregroundColor(.primary)
                .labelsHidden()
                .padding(.bottom)
                .onChange(of: isStart ? eg.gregStart : eg.gregEnd) {
                    if isStart {
                        eg.metricStart = MetrixtTime(date: eg.gregStart)
                        eg.enforceEntropy()
                    } else {
                        eg.metricEnd = MetrixtTime(date: eg.gregEnd)
                        eg.enforceEntropy()
                    }
                }
                .padding(.bottom)
            
//            HStack {
//                VStack(alignment: .leading) {
//                    Text("metric equivalent: ")
//                        .font(.caption)
//                    Text(isStart ? eg.metricStart.fullDateTxt : eg.metricEnd.fullDateTxt)
//                        .bold()
//                }
//                Spacer()
//            }
//            .padding(.bottom)
            
            SubmitButtonView(imageString: "checkmark", text: "adjusted", action: { eg.editField = .none } )
                .padding(.bottom)
            
            MetrixtSubdivider()
        }
    }
}

#Preview {
    let eg = PreviewEG().eg()
    EventGregDateEditorView(
        eg: eg,
        target: .startDateGreg
    )
}
