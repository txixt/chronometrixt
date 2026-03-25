//
//  MonthMetricView.swift
//  chronometrixt
//
//  Created by Becket Bowes on 1/12/26.
//

import SwiftUI
import SwiftData

struct MonthMetricView: View {
    @Query private var allEvents: [MetricEvent]
    @Bindable var gov: Governor
    var month: MetrixtTime
    
    private var monthEvents: [Int] {
        guard !allEvents.isEmpty else { return [] }
        guard let span = gov.span else { return [] }
        let events = allEvents.filter { event in
            guard event.startYears == month.year else { return false }
            return span.contains(event.startSeconds)
        }
        var days: [Int] = Array(repeating: 0, count: 100)
        for event in events {
            let eventDay = (event.startSeconds / 100_000) % 100
            if days[eventDay] < 3 { days[eventDay] += 1 }
        }
        return days
    }
    
        var body: some View {
            GeometryReader { geo in
                ZStack {
                    VStack {
                        
                        HStack(spacing: 0) {
                            Text(month.yearTxt + "." + month.monthTxt)
                                .font(.largeTitle.bold())
                                .foregroundColor(month.years == gov.eternalNow.time.years && month.month == gov.eternalNow.time.month ? .metricOrange : .primary)
                                .onTapGesture(count: 1) { goToYearView() }
                            Spacer()
                        }
                        
                        Divider()
                        
                        VStack {
                            ForEach(0..<10, id: \.self) { week in
                                HStack {
                                    Text("\(week)").bold()
                                        .foregroundColor(month.year == gov.eternalNow.time.year && month.month == gov.eternalNow.time.month && month.week == week ? .metricOrange : .secondary)
                                        .onTapGesture(count: 1) { goToDayOrWeekView(week: week, day: nil) }
                                        .opacity(month.month == 3 && week > 6 ? 0 : 1)

                                    Spacer()
                                    
                                    HStack {
                                        ForEach(0..<10, id: \.self) { day in
                                            let isToday = month.year == gov.eternalNow.time.year && month.month == gov.eternalNow.time.month && month.week == week && month.day == day
                                            let isLeapYear = metric.cal.isLeapYear(month.year)
                                            let pastEndOfYear = ((month.month * 100) + (week * 10) + day) > (isLeapYear ? 365 : 364)
                                            
                                            ZStack {
                                                
                                                Text("\(day)")
                                                    .font(.caption)
                                                    .foregroundColor(isToday ? .metricOrange : .primary)
                                                    .bold()
                                                RoundedRectangle(cornerRadius: 8)
                                                    .foregroundColor(isToday ? .metricOrange : .secondary).opacity(isToday ? 0.5 : 0.2)
                                                
                                                if gov.finiteNotNow != nil && gov.finiteNotNow == month && !monthEvents.isEmpty {
                                                    let pipNo = monthEvents[(week * 10) + day]
                                                    VStack {
                                                        Spacer()
                                                        HStack{
                                                            ForEach (0..<pipNo, id: \.self) { _ in
                                                                Circle().fill(.primary).frame(width: 3, height: 3)
                                                                    .padding(1)
                                                            }
                                                        }
                                                    }
                                                }

                                            }
                                            .frame(width: geo.size.width * 0.068, height: 22)
                                            .onTapGesture(count: 1) { goToDayOrWeekView(week: week, day: day) }
                                            .opacity(pastEndOfYear ? 0 : 1)
                                        }
                                    }
                                }
                            }
                        }
                    }
                    .padding()
                    .monospaced()
                }
                .frame(width: geo.size.width, height: geo.size.width)
            }

        }
    
    private func goToYearView() {
        gov.scale = .year
    }
    
    private func goToDayOrWeekView(week: Int, day: Int?) {
        gov.finiteNotNow = metric.cal.replace(time: gov.someTimes[1], component: .week, with: week)
        if day != nil { gov.finiteNotNow = metric.cal.replace(time: gov.finiteNotNow!, component: .day, with: day!) }
        gov.scale = day != nil ? .day : .week
    }
    
}

#Preview {
    MonthMetricView(gov: Governor(), month: MetrixtTime(date: nil))
}
