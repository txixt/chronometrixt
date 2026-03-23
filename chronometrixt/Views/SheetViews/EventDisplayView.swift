//
//  EventDisplayView.swift
//  chronometrixt
//
//  Created by Becket Bowes on 3/22/26.
//

import SwiftUI

struct EventDisplayView: View {
    @Bindable var gov: Governor
    @Bindable var eg: EventGovernor
    
    var body: some View {
        let truncatedTitle: String = eg.title.split(separator: " ", maxSplits: 2).prefix(2).joined(separator: " ")
        
        VStack {
            
            SheetHeaderView(gov: gov, title: truncatedTitle, titleImage: "fleuron")
            
            HStack {
                VStack(alignment: .leading) {
                    Text(eg.title)
                        .tint(Color(hex: eg.calendarColor))
                        .font(.title)
                        .padding(.bottom)
                    
                    Text("starts: ")
                        .font(.caption)
                    Text(eg.metricStart.fullDateTxt)
                        .font(.title2)
                    Text(eg.gregStart.formatted())
                        .padding(.bottom)
                    
                    VStack(alignment: .leading) {
                        Text("ends: ")
                            .font(.caption)
                        Text(eg.isAllDay ? "all day" : eg.metricEnd.fullDateTxt)
                            .font(.title2)
                        if !eg.isAllDay {
                            Text(eg.gregEnd.formatted())
                        }
                    }

                        .padding(.bottom)
                    
                    if eg.recurrence != .none {
                        Text(String(
                            "\(eg.recurrence.frequency)" +
                            (eg.recurrence.frequency == .none && eg.recurrence.count == nil ? "" :
                            (eg.recurrence.count == nil ? " x ∞" : " x \(eg.recurrence.count!)"))
                                        ))
                    } else {
                        Text("one-time event")
                    }
                    Text("alarms: \(eg.alarms.count.description)")
                    Text(eg.location.isEmpty ? "no location" : eg.location)
                    Text(eg.notes.isEmpty ? "no notes" : eg.notes)
                    Text("calendar: " + eg.calendar)
                }
                .bold()
                
                Spacer()
                

            }
            
            
            Spacer()
            
            ZStack {
                Divider()
                HStack {
                    Text("edit")
                        .font(.title3)
                        .foregroundStyle(.primary)
                        .bold()
                    Spacer()
                    Button(action: { gov.sheet = .editEvent }) {
                        Image(systemName: "wrench")
                    }
                    .tint(.primary)
                    .shadow(color: .gray, radius: 3)
                }
            }
        }
        .monospaced()
        .padding()
    }
}

#Preview {
//    let metric = MetrixtTime(date: Date.now)
//    let metricLater = MetrixtCalendar().update(time: metric, component: .minute, byAdding: 1)
    EventDisplayView(gov: Governor(), eg: EventGovernor(title: "bob dang it", starting: MetrixtTime(date: Date.now), ending: MetrixtTime(date: Date.now))
//        gov: Governor(),
//        event: MetricEvent(
//            id: UUID().uuidString,
//            title: "sample",
//            notes: "",
//            location: "california",
//            startYears: metric.years,
//            startSeconds: metric.seconds,
//            endYears: metricLater.years,
//            endSeconds: metricLater.seconds,
//            utcStart: metric.toGreg(),
//            utcEnd: metricLater.toGreg(),
//            timeZoneIdentifier: Calendar.current.timeZone.identifier,
//            isAllDay: true,
//            status: "",
//            sequence: 0,
//            recurrenceRule: "",
//            recurringParentId: "",
//            participantsJson: "",
//            alarmsJson: "",
//            calendarId: "",
//            calendarColor: "015659",
//            externalId: "metrixt"
//        )
    )
}
