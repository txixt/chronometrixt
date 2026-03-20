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
                    AddTimeButton(eg: eg, added: $added, text: "allday", value: 0)
                    AddTimeButton(eg: eg, added: $added, text: "1mm", value: 1)
                    AddTimeButton(eg: eg, added: $added, text: "5mm", value: 5)
                    AddTimeButton(eg: eg, added: $added, text: "10mm", value: 10)
                }
                HStack {
                    AddTimeButton(eg: eg, added: $added, text: "50mm", value: 50)
                    AddTimeButton(eg: eg, added: $added, text: "1mh", value: 100)
                    AddTimeButton(eg: eg, added: $added, text: "1d", value: 1000)
                    AddTimeButton(eg: eg, added: $added, text: "10d", value: 10000)
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
                HStack {
                    VStack(alignment: .leading) {
                        Text("gregorian equivalent: ")
                            .font(.caption)
                        Text(eg.isAllDay ? "all day" : eg.gregEnd.formatted())
                            .bold()
                    }
                    Spacer()
                }
                .padding(.bottom)
                
                HStack {
                    SubmitButtonView(imageString: "arrow.trianglehead.counterclockwise", text: "reset", action: reset
                    )
                    .opacity(0.8)
                    SubmitButtonView(imageString: "calendar.day.timeline.left", text: "set specific end", action: { eg.editField = .none })
                    .opacity(0.8)
                    SubmitButtonView(imageString: "checkmark", text: "done", action: { goGranular = true })
                }
                .padding(.bottom)
                
                MetrixtSubdivider()
            }
            .monospaced()
        } else {
            EventMetricDateEditorView(gov: gov, eg: eg, target: .endDateMetric)
        }
        
    }
    
    private func reset() {
        eg.metricEnd = metric.cal.update(time: eg.metricStart, component: .second, byAdding: 1)
        added = 1
    }
}

struct AddTimeButton: View {
    @Bindable var eg: EventGovernor
    @Binding var added: Int
    var text: String
    var value: Int
    
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
    
    private func setTheEnd() {
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
    }
}

#Preview {
    EventEndDateEditorView(
        gov: Governor(),
        eg: EventGovernor(
            title: "sample",
            starting: MetrixtTime(years: 5056, seconds: 12345678),
            ending: MetrixtTime(years: 5056, seconds: 1234579)
            )
    )
}
