//
//  WeekMetricView.swift
//  chronometrixt
//
//  Created by Becket Bowes on 1/12/26.
//

import SwiftUI
import SwiftData

struct WeekMetricView: View {
    @Query private var allEvents: [MetricEvent]
    @Bindable var gov: Governor
    var week: MetrixtTime?
    
    
    private var weekEvents: [MetricEvent] {
        guard !allEvents.isEmpty else { return [] }
        guard let span = gov.span else { return [] }
        let govTime = gov.finiteNotNow ?? gov.eternalNow.time
        let targetYear = (week ?? govTime).year
///DEV SWITCH WITH allEvents.filter / dummyMetricEvents
        return allEvents.filter { event in
            guard event.startYears == targetYear else { return false }
            return span.contains(event.startSeconds)
        }
    }
    private var eventMarkers: [[EventMarker]] {
        var dayBuckets: [[EventMarker]] = Array(repeating: [], count: 10)
        for event in weekEvents {
            let eventDay = (event.startSeconds / 100_000) % 10
            let eventOffset: CGFloat = CGFloat(event.startSeconds % 100_000) / 100_000.0
            let em = EventMarker(id: event.id, offset: eventOffset, color: Color(hex: event.calendarColor))
            dayBuckets[eventDay].insert(em, at: 0)
        }
        print(dayBuckets.description)
        return dayBuckets
    }
    private struct EventMarker: Identifiable {
        let id: String
        var offset: CGFloat
        var color: Color
    }
    
    var body: some View {
        let govTime = gov.finiteNotNow ?? gov.eternalNow.time
        let someTime = week ?? govTime
        
        GeometryReader { geo in
            ZStack {
                VStack {
                    HStack(spacing: 0) {
                        Text(someTime.yearTxt + "." + someTime.monthTxt + ":" + someTime.weekTxt)
                            .font(.largeTitle).bold()
                            .foregroundColor(someTime.year == gov.eternalNow.time.year && someTime.month == gov.eternalNow.time.month && someTime.week == gov.eternalNow.time.week ? .metricOrange : .primary)
                        Spacer()
                    }
                    .onTapGesture(count: 1) { goToYearView() }
                    
                    Divider()
                    
                    HStack {
                        ForEach(0..<10, id: \.self) { day in
                            let isToday = someTime.year == gov.eternalNow.time.year && someTime.month == gov.eternalNow.time.month && someTime.week == gov.eternalNow.time.week && someTime.day == day
                            let beforeYearEnd = (someTime.month * 100) + (someTime.week * 10) + day < (metric.cal.isLeapYear(someTime.year) ? 366 : 365)
                            
                            VStack {
                                Text("\(day)")
                                    .bold()
                                    .foregroundColor(isToday ? .metricOrange : .primary)
                                    .onTapGesture(count: 1) { goToDayView(day: day, hour: nil) }

                                ZStack {
                                    
                                    VStack {
                                        ForEach(0..<10, id: \.self) { hour in
                                            Text("\(hour)")
                                                .font(.caption)
                                                .foregroundColor(isToday ? .primary : .gray)
                                                .onTapGesture(count: 1) { goToDayView(day: day, hour: hour)  }
                                                .padding(.vertical, 2.5)
                                            }
                                        }
                                        .padding(10)
                                        .padding(.bottom, 3)
                                        .background(RoundedRectangle(cornerRadius: 15)
                                        .foregroundColor(isToday ? .metricOrange : .primary).opacity(isToday ? 0.5 : 0.2))
                                    
                                    
                                    VStack {
                                        ZStack{
                                            if gov.finiteNotNow != nil && gov.finiteNotNow == week && !eventMarkers[day].isEmpty {
                                                ForEach(eventMarkers[day]) { em in
                                                    Circle().fill(em.color).frame(width: 25, height: 25)
                                                        .offset(y: (em.offset * 250) + 15)
                                                        .opacity(0.5)
                                                        .onTapGesture {
                                                            viewEvent(id: em.id)
                                                        }
                                                }
                                            }
                                        }
                                        Spacer()
                                    }
                                    
                                }
                                .frame(height: 250)
                            }
                            .opacity(beforeYearEnd ? 1 : 0)
                            if day != 9 { Spacer() }
                        }
                    }
                }
                .padding()
                .monospaced()
                
            }
            .frame(width: geo.size.width, height: geo.size.width)
        }
    }
    
    private func viewEvent(id: String) {
        gov.event = allEvents.first { $0.id == id } ?? allEvents.first { $0.id == id}
        gov.sheet = .showEvent
    }
    
    private func goToYearView() {
        gov.scale = .year
    }
    
    private func goToDayView(day: Int, hour: Int?) {
        gov.finiteNotNow = metric.cal.replace(time: gov.someTimes[1], component: .day, with: day)
        if hour != nil {
            gov.finiteNotNow = metric.cal.replace(time: gov.finiteNotNow!, component: .hour, with: hour!)
            gov.finiteNotNow = metric.cal.replace(time: gov.finiteNotNow!, component: .minute, with: 0)
            gov.finiteNotNow = metric.cal.replace(time: gov.finiteNotNow!, component: .second, with: 0)
        }
        gov.scale = .day
    }
}

struct prePreview {
    let gov = Governor()
    
    init() {
        gov.scale = .week
        gov.populateTimes()
    }
}
#Preview {
    WeekMetricView(gov: prePreview().gov, week: MetrixtTime(years: 5056, seconds: 36_400_000))
}

//let someTime = week ?? gov.finiteNotNow ?? gov.eternalNow.time
//
//GeometryReader { geo in
//    VStack {
//        Button(action: goToYearView) {
//            HStack {
//                Text(someTime.yearText + "•" + someTime.monthText + ":" + someTime.weekText)
//                    .font(.title).bold()
//                    .foregroundColor(someTime.year == gov.eternalNow.time.year && someTime.month == gov.eternalNow.time.month && someTime.week == gov.eternalNow.time.week ? .metricOrange : .primary)
//                Spacer()
//            }
//        }
//        .padding(.bottom)
//        
//        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 10)) {
//            ForEach(0..<10, id: \.self) { day in
//                VStack() {
//                    Button(action: { goToDayView(day: day, hour: nil)}) {
//                        VStack {
//                            Text("\(day)").bold().foregroundColor(someTime.year == gov.eternalNow.time.year && someTime.month == gov.eternalNow.time.month && someTime.week == gov.eternalNow.time.week && someTime.day == day ? .metricOrange : .primary)
//                            Text(MetricLogic.days[day]).bold().font(.system(size: 7))
//                                .foregroundColor(someTime.year == gov.eternalNow.time.year && someTime.month == gov.eternalNow.time.month && someTime.week == gov.eternalNow.time.week && someTime.day == day ? .metricOrange : .primary)
//                        }
//                    }
//
//                    ZStack {
//                        Rectangle().frame(height: geo.size.height * 0.5)
//                            .foregroundColor(.clear)
//                            .border(someTime.year == gov.eternalNow.time.year && someTime.month == gov.eternalNow.time.month && someTime.week == gov.eternalNow.time.week && someTime.day == day ? .metricOrange : .primary, width: someTime.year == gov.eternalNow.time.year && someTime.month == gov.eternalNow.time.month && someTime.week == gov.eternalNow.time.week && someTime.day == day ? 3.0 : 0.5).opacity(0.5)
//                        LazyHGrid(rows: Array(repeating: GridItem(.flexible()), count: 10)) {
//                            ForEach(0..<10, id: \.self) { hour in
//                                Button(action: { goToDayView(day: day, hour: hour) }) {
//                                    Text("\(hour)")
//                                        .font(.caption)
//                                        .foregroundColor(.gray)
//                                }
//                            }
//                        }
//                        .padding(.bottom)
//                        .frame(height: geo.size.height * 0.5)
//                    }
//                }
//
//            }
//            .frame(height: geo.size.height * 0.6)
//        }
//        .frame(height: geo.size.height * 0.6)
//    }
//    .padding()
//}
//.monospaced()
//}
