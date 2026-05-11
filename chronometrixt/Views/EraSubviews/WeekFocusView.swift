//
//  WeekFocusView.swift
//  chronometrixt
//
//  Created by Becket on 4/13/26.
//

import SwiftUI
import SwiftData

struct WeekFocusView: View {
    @Query private var allEvents: [MetricEvent]
    @Bindable var gov: Governor
    var week: MetrixtTime
    
    private var weekEvents: [[EventMarker]] {
        var eventMarkers: [[EventMarker]] = Array(repeating: [], count: 10)
        guard !allEvents.isEmpty else { return eventMarkers }
        guard let span = gov.span else { return eventMarkers }
        
        let theseEvents = allEvents.filter { event in
            guard event.startYears == week.year else { return false }
            return span.contains(event.startSeconds)
        }
        
        for event in theseEvents {
            let eventDay = (event.startSeconds / 100_000) % 10
            let offset: CGFloat = CGFloat(event.startSeconds % 100_000) / 100_000.0
            let em = EventMarker(id: event.id, offset: offset, color: Color(hex: event.calendarColor))
            eventMarkers[eventDay].insert(em, at: 0)
        }
        
        return eventMarkers
    }
    private struct EventMarker: Identifiable {
        let id: String
        var offset: CGFloat
        var color: Color
    }
    
    var body: some View {
        GeometryReader { geometryReader in
            let geo = gov.geoSize ?? geometryReader.size
            let isThisWeek = week.year == gov.eternalNow.time.year &&
                             week.month == gov.eternalNow.time.month &&
                             week.week == gov.eternalNow.time.week
            VStack {
                
                HStack {
                    Text(week.yearTxt + "." + week.monthTxt + week.weekTxt)
                        .font(.largeTitle).bold()
                        .foregroundColor(isThisWeek ? .metricOrange : .primary)
                        .onTapGesture(count: 1) { gov.scale = .year }
                    Spacer()
                }
                
                Divider()
                
                HStack {
                    ForEach(0...9, id: \.self) { day in
                        let isThisDay = isThisWeek && week.day == day
                        let yearEnded = (week.month*100) + (week.week*10) + day > (metric.cal.isLeapYear(week.year) ? 365:354)
                        
                        VStack {
                            Text("\(day)")
                                .bold()
                                .foregroundColor(isThisDay ? .metricOrange : .primary)
                                .onTapGesture(count: 1) { goToDayView(day: day, hour: nil) }
                            
                            ZStack {
                                RoundedRectangle(cornerRadius: 15)
                                    .fill(isThisDay ? .metricOrange : .primary)
                                    .opacity(isThisDay ? 1.0 : 0.2)
                                    .frame(width: geo.width * 0.07)
                                VStack {
                                    ForEach(0...9, id: \.self) { hour in
                                        Text("\(hour)")
                                            .font(.caption)
                                            .onTapGesture(count: 1) { goToDayView(day: day, hour: hour) }
                                        Spacer()
                                    }
                                }
                                .opacity(yearEnded ? 0:1)
                                
                                if !weekEvents.isEmpty {
                                    VStack {
                                        ZStack {
                                            ForEach(weekEvents[day]) { em in
                                                Circle()
                                                    .fill(em.color).opacity(0.8)
                                                    .shadow(color: em.color, radius: 3)
                                                    .frame(width: geo.width * 0.07, height: geo.width * 0.07)
                                                    .offset(y: geo.height * 0.63 * em.offset) //0.7 - 0.07
                                                    .onTapGesture(count: 1) { viewEvent(id: em.id) }
                                            }
                                        }
                                        Spacer()
                                    }
                                }
                            }
                            .frame(height: geo.width * 0.7)
                        }
                        
                        if day != 9 { Spacer() }
                        
                    }

                }
                
            }
            .padding(.horizontal)
            .frame(width: geo.width, height: geo.width)
        }
    }
    
    private func viewEvent(id: String) {
        gov.event = allEvents.first { $0.id == id }
        gov.sheet = .showEvent
    }
    
    private func goToDayView(day: Int, hour: Int?) {
        gov.finiteNotNow = metric.cal.replace(time: week, component: .day, with: day)
        if hour != nil {
            gov.finiteNotNow = metric.cal.replace(time: gov.finiteNotNow!, component: .hour, with: hour!)
            gov.finiteNotNow = metric.cal.replace(time: gov.finiteNotNow!, component: .minute, with: 0)
            gov.finiteNotNow = metric.cal.replace(time: gov.finiteNotNow!, component: .second, with: 0)
        }
        gov.scale = .day
    }
    
}

#Preview {
    @Previewable @Environment(\.modelContext) var context
    WeekFocusView(gov: Governor(context: context), week: MetrixtTime(date: nil))
}
