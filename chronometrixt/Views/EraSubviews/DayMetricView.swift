//
//  DayMetricView.swift
//  chronometrixt
//
//  Created by Becket Bowes on 1/12/26.
//

import SwiftUI
import SwiftData

struct DayMetricView: View {
    @Query private var allEvents: [MetricEvent]
    @Bindable var gov: Governor
    var day: MetrixtTime?
    
    private var eventsByHour: [[EventSegment]] {
        var hourBuckets: [[EventSegment]] = Array(repeating: [], count: 10)
        var dayEvents: [MetricEvent] {
            guard let span = gov.span else { return [] }
            let targetYear = (day ?? gov.finiteNotNow ?? gov.eternalNow.time).year
    ///CHANGE THIS TO allEvents AFTER DEBUGGING!
    ///change back to dummyMetricEvents for debugging
            return allEvents.filter { event in
                guard event.startYears == targetYear else { return false }
                return span.contains(event.startSeconds)
            }
        }
        
        for event in dayEvents {
            // Get the time within the day (0...99,999)
            let startInDay = event.startSeconds % 100_000
            let endInDay = min(event.endSeconds % 100_000, 99_999) // Cap at end of day
            
            // Determine which hours this event spans
            let startHour = min(startInDay / 10_000, 9)
            let endHour = min(endInDay / 10_000, 9)
            
            // If event spans multiple hours, create segments for each
            for hour in startHour...endHour {
                guard hour >= 0 && hour < 10 else { continue } // Safety check
                
                let hourStart = hour * 10_000
                let hourEnd = (hour + 1) * 10_000
                
                // Calculate where within this hour the event segment starts and ends
                let segmentStart = max(startInDay, hourStart)
                let segmentEnd = min(endInDay, hourEnd - 1) // -1 to keep within hour
                
                // Convert to percentage within the hour (0.0 to 1.0)
                let startPercent = CGFloat(segmentStart - hourStart) / 10_000.0
                let endPercent = CGFloat(segmentEnd - hourStart + 1) / 10_000.0
                
                let segment = EventSegment(
                    eventId: event.id,
                    startPercent: startPercent,
                    endPercent: endPercent,
                    color: Color(hex: event.calendarColor)
                )
                
                hourBuckets[hour].insert(segment, at: 0)
            }
        }
        
        return hourBuckets
    }
    private struct EventSegment: Identifiable {
        var id: String { eventId }
        let eventId: String
        let startPercent: CGFloat  // 0.0 to 1.0 within the hour
        let endPercent: CGFloat    // 0.0 to 1.0 within the hour
        let color: Color
    }
    
    var body: some View {
        let govTime = gov.finiteNotNow ?? gov.eternalNow.time
        let someTime = day ?? govTime
        
        GeometryReader { geo in
            ZStack {
                VStack {
                    
                    HStack(spacing: 0) {
                        Text(someTime.yearTxt + "." + someTime.monthWeekDayTxt)
                            .font(.largeTitle.bold())
                            .foregroundColor(someTime.year == gov.eternalNow.time.year && someTime.mwd == gov.eternalNow.time.mwd ? .metricOrange : .primary)
                            .onTapGesture { goToYearView() }
                        Spacer()
//                        VStack(alignment: .trailing) {
//                            Text("📅 \(dayEvents.count)")
//                                .font(.caption)
//                                .foregroundColor(.secondary)
//                            if let span = gov.span {
//                                Text("span: \(span.lowerBound)...\(span.upperBound)")
//                                    .font(.caption2)
//                                    .foregroundColor(.secondary)
//                            }
//                        }
                    }
                    
                    Divider()

                    VStack {
                        ForEach(0..<10, id: \.self) { hour in
                            ZStack {
                                RoundedRectangle(cornerRadius: 12.5)
                                    .frame(width: geo.size.width * 0.9, height: 25)
                                    .foregroundColor(.gray).opacity(0.2)
                                
                                ForEach(eventsByHour[hour]) { segment in
                                    RoundedRectangle(cornerRadius: 12.5)
                                        .fill(segment.color.opacity(0.2))
                                        .frame(
                                            width: geo.size.width * 0.9 * (segment.endPercent - segment.startPercent),
                                            height: 22
                                        )
                                        .offset(x: (geo.size.width * 0.9 * (segment.startPercent + segment.endPercent - 1.0) / 2.0))
                                }
            
                                HStack {
                                    Text("\(hour)")
                                        .bold()
                                        .foregroundColor(.primary)
                                        .onTapGesture(count: 1) { selectTime(hours: hour, minutes: 0) }
                                    Spacer()
                                    
                                    ForEach(0..<10, id:\.self) { minutes in
                                        Text(":\(minutes)0")
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                            .onTapGesture(count: 1) { selectTime(hours: hour, minutes: minutes) }
                                        Spacer()
                                    }
                                }
                                
                                HStack {
                                    if !eventsByHour[hour].isEmpty {
                                        ForEach(eventsByHour[hour]) { event in
                                            Circle().fill(event.color)
                                                .onTapGesture {
                                                    selectEvent(id: event.eventId)
                                                }
                                        }
                                    }
                                    Spacer()
                                }
                                .padding(.leading)

                            }
                        }
                    }
                }
                .padding()
                .monospaced()
                .opacity(someTime.year == govTime.year && someTime.month == govTime.month && someTime.week == govTime.week && someTime.day == govTime.day ? 1 : 0.2)
            }
            .frame(width: geo.size.width, height: geo.size.width)
        }
    }
    
    private func selectEvent(id: String) {
        /// Use dummyMetricEvents for debugging, switch to allEvents when ready
        gov.event = allEvents.first { $0.id == id } ?? allEvents.first { $0.id == id }
        gov.sheet = .showEvent
    }
    
    private func goToYearView() {
        gov.scale = .year
    }
    
    private func selectTime(hours: Int, minutes: Int) {
        gov.finiteNotNow = metric.cal.replace(time: gov.someTimes[1], component: .hour, with: hours)
        gov.finiteNotNow = metric.cal.replace(time: gov.finiteNotNow!, component: .minute, with: minutes * 10)
        gov.finiteNotNow = metric.cal.replace(time: gov.finiteNotNow!, component: .second, with: 0)
    }
}

///Hex handling exists elsewhere.

let dummyMetricEvents: [MetricEvent] = {
    let now = MetrixtTime(date: nil)
    
    return [
        MetricEvent(
            id: "dummy-1",
            title: "Morning Meeting",
            notes: "Discuss project updates",
            location: "Conference Room A",
            startYears: now.year,
            startSeconds: (now.mwd * 100_000) + 20000,  // 2:00:00
            endYears: now.year,
            endSeconds: (now.mwd * 100_000) + 35000,    // 3:50:00
            utcStart: Date(),
            utcEnd: Date().addingTimeInterval(3600),
            timeZoneIdentifier: TimeZone.current.identifier,
            isAllDay: false,
            status: "CONFIRMED",
            sequence: 0,
            recurrenceRule: "NONE",
            recurringParentId: "NONE",
            participantsJson: "[]",
            alarmsJson: "[]",
            calendarId: "mextrixt",
            calendarColor: "#015659",
            externalId: "NONE"
        ),
        MetricEvent(
            id: "dummy-2",
            title: "Lunch Break",
            notes: "",
            location: "Cafeteria",
            startYears: now.year,
            startSeconds: (now.mwd * 100_000) + 50000,  // 5:00:00
            endYears: now.year,
            endSeconds: (now.mwd * 100_000) + 59999,    // 6:00:00
            utcStart: Date().addingTimeInterval(7200),
            utcEnd: Date().addingTimeInterval(10800),
            timeZoneIdentifier: TimeZone.current.identifier,
            isAllDay: false,
            status: "CONFIRMED",
            sequence: 0,
            recurrenceRule: "NONE",
            recurringParentId: "NONE",
            participantsJson: "[]",
            alarmsJson: "[]",
            calendarId: "mextrixt",
            calendarColor: "#FF6B35",
            externalId: "NONE"
        ),
        MetricEvent(
            id: "dummy-3",
            title: "Team Sync",
            notes: "Weekly team standup",
            location: "Remote",
            startYears: now.year,
            startSeconds: (now.mwd * 100_000) + 75000,  // 7:50:00
            endYears: now.year,
            endSeconds: (now.mwd * 100_000) + 80000,    // 8:00:00
            utcStart: Date().addingTimeInterval(14400),
            utcEnd: Date().addingTimeInterval(16200),
            timeZoneIdentifier: TimeZone.current.identifier,
            isAllDay: false,
            status: "CONFIRMED",
            sequence: 0,
            recurrenceRule: "NONE",
            recurringParentId: "NONE",
            participantsJson: "[]",
            alarmsJson: "[]",
            calendarId: "work",
            calendarColor: "#4ECDC4",
            externalId: "NONE"
        ),
        MetricEvent(
            id: "dummy-4",
            title: "All Day Event",
            notes: "Company retreat",
            location: "Mountain Resort",
            startYears: now.year,
            startSeconds: now.mwd * 100_000,            // Start of day
            endYears: now.year,
            endSeconds: (now.mwd * 100_000) + 99_999,   // End of day (last second)
            utcStart: Date(),
            utcEnd: Date().addingTimeInterval(86400),
            timeZoneIdentifier: TimeZone.current.identifier,
            isAllDay: true,
            status: "CONFIRMED",
            sequence: 0,
            recurrenceRule: "NONE",
            recurringParentId: "NONE",
            participantsJson: "[]",
            alarmsJson: "[]",
            calendarId: "personal",
            calendarColor: "#95E1D3",
            externalId: "NONE"
        )
    ]
}()

#Preview {
    let gov = Governor()
    gov.scale = .day
    gov.populateTimes() // This will call setSpan()
    return DayMetricView(gov: gov, day: MetrixtTime(date: nil))
}
