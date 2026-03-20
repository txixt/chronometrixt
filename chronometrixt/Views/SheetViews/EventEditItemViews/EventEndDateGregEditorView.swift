//
//  EventEndDateGregEditorView.swift
//  chronometrixt
//
//  Created by Becket on 3/20/26.
//

import SwiftUI

struct EventEndDateGregEditorView: View {
    @Bindable var gov: Governor
    @Bindable var eg: EventGovernor
    @State var goGranular: Bool = false
    @State var added: Int = 0
    
    var body: some View {
        if !goGranular {
            MetrixtSubdivider()
            
            VStack {
                HStack {
                    Text("make event all-day or tap to add gregorian seconds to end time:")
                        .font(.caption)
                    Spacer()
                }
                .padding(.bottom)
                
                HStack {
                    AddGregTimeButton(text: "allday", value: 0, action: { basta(0) })
                    AddGregTimeButton(text: "1m", value: 1, action: { basta(1) })
                    AddGregTimeButton(text: "5m", value: 5, action: { basta(5) })
                    AddGregTimeButton(text: "10m", value: 10, action: { basta(10) })
                }
                HStack {
                    AddGregTimeButton(text: "30m", value: 30, action: { basta(30) })
                    AddGregTimeButton(text: "1h", value: 60, action: { basta(60) })
                    AddGregTimeButton(text: "1d", value: 1440, action: { basta(1440) })
                    AddGregTimeButton(text: "7d", value: 10_080, action: { basta(10_080) })
                }
                    
                HStack {
                    VStack(alignment: .leading) {
                        Text("start date: ")
                            .font(.caption)
                        Text(eg.gregStart.formatted() + (eg.isAllDay ? "" : " + \(added) minutes ="))
                            .bold()
                    }
                    .foregroundStyle(.gray)
                    Spacer()
                }
                HStack {
                    VStack(alignment: .leading) {
                        Text("end date: ")
                            .font(.caption)
                        Text(eg.isAllDay ? "all day" : eg.gregEnd.formatted())
                            .bold()
                    }
                    Spacer()
                }
                .padding(.bottom)
                
                HStack {
                    SubmitButtonView(imageString: "arrow.trianglehead.counterclockwise", text: "reset", action: reset)
                    SubmitButtonView(imageString: "calendar.day.timeline.left", text: "set specific end", action: { goGranular = true })
                    SubmitButtonView(imageString: "checkmark", text: "done", action: { eg.editField = .none })
                }
                
                MetrixtSubdivider()
            }
            .monospaced()
            .onDisappear { goGranular = false }
            
        } else {
            EventGregDateEditorView(eg: eg, target: .endDateGreg)
        }
    }
    
    private func basta(_ value: Int) {
        if value == 0 { eg.isAllDay.toggle(); return }
        eg.gregEnd = eg.gregEnd.addingTimeInterval(TimeInterval(value * 60))
        eg.metricEnd = MetrixtTime(date: eg.gregEnd)
        added += value
    }
    
    private func reset() {
        eg.gregEnd = eg.gregStart.addingTimeInterval(TimeInterval(1))
        eg.metricEnd = MetrixtTime(date: eg.gregEnd)
        added = 0
    }
}

struct AddGregTimeButton: View {
    var text: String
    var value: Int
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
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
    EventEndDateGregEditorView(
        gov: Governor(),
        eg: EventGovernor(
            title: "sample",
            starting: MetrixtTime(years: 5056, seconds: 12345678),
            ending: MetrixtTime(years: 5056, seconds: 1234579)
            )
    )
}
