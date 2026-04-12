//
//  DayFocusView.swift
//  chronometrixt
//
//  Created by Becket Bowes on 4/12/26.
//

import SwiftUI
import SwiftData

struct DayFocusView: View {
    @Query private var allEvents: [MetricEvent]
    @Bindable var gov: Governor
    var day: MetrixtTime
    
    private var eventsByHour: [[EventSegment]] {
        var hourBuckets: [[EventSegment]] = Array(repeating: [], count: 10)
        guard !allEvents.isEmpty else { return hourBuckets }
        guard let span = gov.span else { return hourBuckets }
        
        var dayEvents: [MetricEvent] {
            return allEvents.filter { event in
                guard event.startYears == day.year else { return false }
                return span.contains(event.startSeconds)
            }
        }
        
        for event in dayEvents {
            let startInDay = event.startSeconds % 100_000
            let endInDay = min(event.endSeconds % 100_000, 99_999)
            let startHour = min(startInDay / 10_000, 9)
            let endHour = min(endInDay / 10_000, 9)
            for hour in startHour...endHour {
                guard hour >= 0 && hour < 10 else { continue }
                let topOTheHour = hour * 10_000
                let endOTheHour = (hour + 1) * 10_000
                let topOTheSegment = max(startHour, topOTheHour)
                let endOTheSegment = max(endInDay, endOTheHour - 1)
                let startPercent = CGFloat(topOTheSegment - topOTheHour) / 10_000.0
                let endPercent = CGFloat(endOTheSegment - endOTheHour + 1) / 10_000.0
                let segment = EventSegment(eventId: event.id, startPercent: startPercent, endPercent: endPercent, color: Color(hex: event.calendarColor))
                hourBuckets[hour].insert(segment, at: 0)
            }
        }
        
        return hourBuckets
    }
    private struct EventSegment: Identifiable {
        var id: String { eventId }
        let eventId: String
        let startPercent: CGFloat
        let endPercent: CGFloat
        let color: Color
    }
    
    var body: some View {
        GeometryReader { geo in
            VStack {
                
                HStack(spacing: 0) {
                    Text(day.yearTxt + "." + day.mwdTxt)
                        .font(.largeTitle).bold()
                        .foregroundColor(day.year == gov.eternalNow.time.year && day.mwd == gov.eternalNow.time.mwd ? .metricOrange : .primary)
                        .onTapGesture { gov.scale = .year }
                    Spacer()
                }
                
                Divider()
                
                VStack {
                    ForEach(0...9, id: \.self) { hour in
                        ZStack {
                            
                            RoundedRectangle(cornerRadius: 11)
                                .frame(width: geo.size.width * 0.9, height: 22)
                                .foregroundColor(.gray).opacity(0.2)
                            
                            if !eventsByHour[hour].isEmpty {
                                ForEach(eventsByHour[hour]) { segment in
                                    RoundedRectangle(cornerRadius: 11)
                                        .fill(segment.color.opacity(0.5))
                                        .frame(width: geo.size.width * 0.9 * (segment.endPercent - segment.startPercent), height: 22)
                                        .offset(x: (geo.size.width * 0.9 * (segment.startPercent + segment.endPercent - 1.0) / 2.0))
                                }
                            }
                            
                            HStack {
                                Text("\(hour)")
                                    .bold()
                                
                                Spacer()
                                
                                ForEach(0...9, id: \.self) { minutes in
                                    Text(":\(minutes)0")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                    Spacer()
                                }
                            }
                            
                            if !eventsByHour[hour].isEmpty {
                                HStack {
                                    
                                    ForEach(eventsByHour[hour]) { event in
                                        Circle().fill(event.color).frame(width: 22, height: 22)
                                            .onTapGesture { selectEvent(id: event.eventId) }
                                    }
                                    
                                    Spacer()
                                    
                                }
                                .padding(.leading)
                            }
                                
                        }
                    }
                }
            }
            .padding(.horizontal)
            .frame(width: geo.size.width, height: geo.size.width)
        }
    }
    
    private func selectEvent(id: String) {
        gov.event = allEvents.first { $0.id == id } ?? allEvents.first { $0.id == id }
        gov.sheet = .showEvent
    }

    private func selectTime(hours: Int, minutes: Int) {
        gov.finiteNotNow = metric.cal.replace(time: day, component: .hour, with: hours)
        gov.finiteNotNow = metric.cal.replace(time: gov.finiteNotNow!, component: .minute, with: minutes)
        gov.finiteNotNow = metric.cal.replace(time: gov.finiteNotNow!, component: .second, with: 0)
    }
}

#Preview {
    DayFocusView(gov: Governor(), day: MetrixtTime(date: nil))
}
