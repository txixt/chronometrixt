//
//  EventEndDateView.swift
//  chronometrixt
//
//  Created by Becket on 3/19/26.
//

import SwiftUI

struct EventEndDateView: View {
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
                    AddTimeButton(eg: eg, added: $added, text: "1min", value: 1)
                    AddTimeButton(eg: eg, added: $added, text: "5min", value: 5)
                    AddTimeButton(eg: eg, added: $added, text: "10min", value: 10)
                }
                HStack {
                    AddTimeButton(eg: eg, added: $added, text: "50min", value: 50)
                    AddTimeButton(eg: eg, added: $added, text: "1hour", value: 100)
                    AddTimeButton(eg: eg, added: $added, text: "1day", value: 1000)
                    AddTimeButton(eg: eg, added: $added, text: "1week", value: 10000)
                }
                .padding(.bottom)
                
                HStack {
                    VStack(alignment: .leading) {
                        Text("start date: ")
                            .font(.caption)
                        Text(eg.metricStart.fullDateTxt + (eg.isAllDay ? "" : " + \(added) ="))
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
                        Text(eg.isAllDay ? "all day" : eg.metricEnd.toGreg().formatted())
                            .bold()
                    }
                    Spacer()
                }
                .padding(.bottom)
                
                HStack {
                    SetValueButtons(eg: eg, added: $added, goGranular: $goGranular, imageText: "arrow.trianglehead.counterclockwise", text: "reset")
                    SetValueButtons(eg: eg, added: $added, goGranular: $goGranular, imageText: "calendar.day.timeline.left", text: "set specific end time")
                    SetValueButtons(eg: eg, added: $added, goGranular: $goGranular, imageText: "checkmark", text: "done")
                }
                .padding(.bottom)
                
                MetrixtSubdivider()
            }
        } else {
            MetricDateEditorView(gov: gov, eg: eg, target: .endDateMetric)
        }
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
                .font(.default)
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
            added += value
            return }
        eg.metricEnd = metric.cal.update(time: eg.metricEnd, component: .minute, byAdding: value)
        added += value
    }
}

struct SetValueButtons: View {
    @Bindable var eg: EventGovernor
    @Binding var added: Int
    @Binding var goGranular: Bool
    var imageText: String
    var text: String
    
    var body: some View {
        Button(action: doTheThings) {
            HStack {
                Image(systemName: imageText)
                    .foregroundColor(.secondary)
                Text(text)
                .font(.caption)
                .foregroundColor(.primary)
            }
            .padding()
            .background(RoundedRectangle(cornerRadius: 10).fill(.gray).opacity(text == "done" ? 1.0 : 0.5))
        }
    }
    
    private func doTheThings() {
        if text == "reset" {
            eg.metricEnd = metric.cal.update(time: eg.metricStart, component: .second, byAdding: 1)
            added = 1
        }
        if text == "done" {
            eg.editField = .none
        }
        if text == "set specific end time" {
            goGranular = true
        }
    }
}

#Preview {
    EventEndDateView(
        gov: Governor(),
        eg: EventGovernor(
            title: "sample",
            starting: MetrixtTime(years: 5056, seconds: 12345678),
            ending: MetrixtTime(years: 5056, seconds: 1234579)
            )
    )
}
