//
//  EventGregDateEditorView.swift
//  chronometrixt
//
//  Created by Becket Bowes on 3/19/26.
//

import SwiftUI

struct EventGregDateEditorView: View {
    @Bindable var eg: EventGovernor
    var target: EventGovernor.EditingFields
    let enforceEntropy: () -> Void
    
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
                        enforceEntropy()
                    } else {
                        eg.metricEnd = MetrixtTime(date: eg.gregEnd)
                        enforceEntropy()
                    }
                }
            
            HStack {
                VStack(alignment: .leading) {
                    Text("metric equivalent: ")
                        .font(.caption)
                    Text(isStart ? eg.metricStart.fullDateTxt : eg.metricEnd.fullDateTxt)
                        .bold()
                }
                Spacer()
            }
            .padding(.bottom)
            
            SubmitButtonView(imageString: "checkmark", text: "adjusted", action: { eg.editField = .none } )
                .padding(.bottom)
            
            MetrixtSubdivider()
        }
    }
}

#Preview {
    EventGregDateEditorView(
        eg: EventGovernor(
            title: "sample",
            starting: MetrixtTime(years: 5056, seconds: 12345678),
            ending: MetrixtTime(years: 5056, seconds: 1234579)
            ),
        target: .startDateGreg,
        enforceEntropy: EventEditMainView(
            gov: Governor(),
            eventGov: EventGovernor(
                title: "sample",
                starting: MetrixtTime(years: 5056, seconds: 12345678),
                ending: MetrixtTime(years: 5056, seconds: 1234579)
                ),
            update: false
        ).enforceEntropy
    )
}
