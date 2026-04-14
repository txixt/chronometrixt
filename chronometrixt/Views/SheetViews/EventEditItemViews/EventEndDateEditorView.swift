//
//  EventEndDateView.swift
//  chronometrixt
//
//  Created by Becket on 3/19/26.
//

import SwiftUI

struct EventEndDateEditorView: View {
    @Bindable var gov: Governor
    @Bindable var eg: EventGovernor
    @State var goGranular: Bool = false
    @State var added: Int = 1
    let enforceEntropy: () -> Void
    
    var body: some View {
        if !goGranular {
            
            VStack {
                MetrixtSubdivider()
                HStack {
                    Text("make event all day or tap to add metric values to end time:")
                        .font(.caption)
                    Spacer()
                }
                .padding(.bottom)
                
                HStack {
                    AddTimeButton(eg: eg, added: $added, text: "allday", setTheEnd: { setTheEnd(0) } )
                    AddTimeButton(eg: eg, added: $added, text: "1mm", setTheEnd: { setTheEnd(1) } )
                    AddTimeButton(eg: eg, added: $added, text: "5mm", setTheEnd: { setTheEnd(5) } )
                    AddTimeButton(eg: eg, added: $added, text: "10mm", setTheEnd: { setTheEnd(10) } )
                }
                HStack {
                    AddTimeButton(eg: eg, added: $added, text: "50mm", setTheEnd: { setTheEnd(50) } )
                    AddTimeButton(eg: eg, added: $added, text: "1mh", setTheEnd: { setTheEnd(100)} )
                    AddTimeButton(eg: eg, added: $added, text: "1d", setTheEnd: { setTheEnd(1_000) } )
                    AddTimeButton(eg: eg, added: $added, text: "10d", setTheEnd: { setTheEnd(10_000) } )
                }
                .padding(.bottom)
                
                HStack {
                    VStack(alignment: .leading) {
                        Text("start date: ")
                            .font(.caption)
                        Text(eg.metricStart.fullDateTxt + (eg.isAllDay ? "" : " + \(added)mm ="))
                            .bold()
                    }
                    .foregroundStyle(.gray)
                    Spacer()
                }
                HStack {
                    VStack(alignment: .leading) {
                        Text("end date: ")
                            .font(.caption)
                        Text(eg.isAllDay ? "all day" : eg.metricEnd.fullDateTxt)
                            .bold()
                    }
                    Spacer()
                }
                .padding(.bottom)
                
                HStack {
                    SubmitButtonView(imageString: "arrow.trianglehead.counterclockwise", text: "reset", action: reset
                    )
                    .opacity(0.8)
                    SubmitButtonView(imageString: "calendar.day.timeline.left", text: "set specific end", action: { goGranular = true })
                    .opacity(0.8)
                    SubmitButtonView(imageString: "checkmark", text: "done", action: { eg.editField = .none })
                }
                .padding(.bottom)
                
                MetrixtSubdivider()
            }
            .monospaced()
            .onDisappear { goGranular = false }
            
        } else {
            EventMetricDateEditorView(gov: gov, eg: eg, target: .endDateMetric, enforceEntropy: enforceEntropy)
        }
        
    }
    
    private func reset() {
        eg.metricEnd = metric.cal.update(time: eg.metricStart, component: .second, byAdding: 1)
        eg.gregEnd = eg.metricEnd.toGreg()
        added = 1
    }
    
    private func setTheEnd(_ value: Int) {
        if value == 0 { eg.isAllDay.toggle(); return }
        if value == 10000 {
            eg.metricEnd = metric.cal.update(time: eg.metricEnd, component: .week, byAdding: 1)
            eg.gregEnd = eg.metricEnd.toGreg()
            added += value
            return
        }
        eg.metricEnd = metric.cal.update(time: eg.metricEnd, component: .minute, byAdding: value)
        eg.gregEnd = eg.metricEnd.toGreg()
                added += value
        enforceEntropy()
    }
}

struct AddTimeButton: View {
    @Bindable var eg: EventGovernor
    @Binding var added: Int
    var text: String
    let setTheEnd: () -> Void
    
    var body: some View {
        Button(action: setTheEnd) {
            Text(text)
                .font(.caption)
                .foregroundColor(.primary)
                .padding()
                .frame(width: 80, height: 30)
                .background(RoundedRectangle(cornerRadius: 10).fill(.gray).opacity(text == "allday" ? 0.2 : 0.3))
        }
    }
}


#Preview {
    let gov = Governor()
    let eg = PreviewEG().eg()
    EventEndDateGregEditorView(
        gov: gov,
        eg: eg,
        enforceEntropy: EventEditMainView(
            gov: gov,
            eventGov: eg,
            update: false
        ).enforceEntropy
    )
}
