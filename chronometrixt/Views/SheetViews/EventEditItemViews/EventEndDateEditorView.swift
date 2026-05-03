//
//  EventEndDateView.swift
//  chronometrixt
//
//  Created by Becket on 3/19/26.
//

import SwiftUI

struct EventEndDateEditorView: View {
    @Bindable var gov: Governor
    @Bindable var eg: EventComptroller
    
    var body: some View {
        VStack {
            MetrixtSubdivider()
            HStack {
                Text("set duration:")
                    .font(.caption)
                Spacer()
            }
            .padding(.bottom, 5)
            HStack {
                AddTimeButton(eg: eg, text: "all day", setTheEnd: { setTheEnd(0) } )
                AddTimeButton(eg: eg, text: "1mm", setTheEnd: { setTheEnd(1) } )
                AddTimeButton(eg: eg, text: "5mm", setTheEnd: { setTheEnd(5) } )
                AddTimeButton(eg: eg, text: "10mm", setTheEnd: { setTheEnd(10) } )
                AddTimeButton(eg: eg, text: "25mm", setTheEnd: { setTheEnd(25) } )
            }
            HStack {
                AddTimeButton(eg: eg, text: "50mm", setTheEnd: { setTheEnd(50) } )
                AddTimeButton(eg: eg, text: "75mm", setTheEnd: { setTheEnd(75) } )
                AddTimeButton(eg: eg, text: "1mh", setTheEnd: { setTheEnd(100)} )
                AddTimeButton(eg: eg, text: "2mh", setTheEnd: { setTheEnd(200) } )
                AddTimeButton(eg: eg, text: "3mh", setTheEnd: { setTheEnd(300) } )
            }
            .padding(.bottom)
            
            HStack {
                Text("end time:")
                    .font(.caption)
                Spacer()
            }
            .padding(.bottom, 5)
            
            MetricDateSteppers(gov: gov, eg: eg, target: .endDateMetric)
            

            SubmitButtonView(imageString: "checkmark", text: "ended", action: { eg.editField = .none })
            .padding(.bottom)
            
            MetrixtSubdivider()
        }
        .monospaced()
    }
    
    private func setTheEnd(_ value: Int) {
        if value == 0 { eg.allDayToggle(); return }
        eg.metricEnd = metric.cal.update(time: eg.metricStart, component: .minute, byAdding: value)
        eg.gregEnd = eg.metricEnd.toGreg()
        eg.enforceEntropy()
    }
}

struct AddTimeButton: View {
    @Bindable var eg: EventComptroller
    var text: String
    let setTheEnd: () -> Void
    
    var body: some View {
        Button(action: setTheEnd) {
            Text(text)
                .font(.caption2)
                .foregroundColor(.primary)
                .frame(width: 60, height: 30)
                .background(RoundedRectangle(cornerRadius: 10).fill(.gray).opacity(text == "all day" ? 0.2 : 0.3))
        }
    }
}


#Preview {
    let gov = Governor()
    let eg = PreviewEG().eg()
    EventEndDateEditorView(gov: gov, eg: eg)
}
