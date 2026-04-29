//
//  MonthFocusView.swift
//  chronometrixt
//
//  Created by Becket Bowes on 4/12/26.
//

import SwiftUI
import SwiftData

struct MonthFocusView: View {
    @Query private var allEvents: [MetricEvent]
    @Bindable var gov: Governor
    var month: MetrixtTime
    
    private var monthEvents: [Int] {
        var days: [Int] = Array(repeating: 0, count: 100)
        guard !allEvents.isEmpty else { return days }
        guard let span = gov.span else { return days }
        
        let events = allEvents.filter { event in
            guard event.startYears == month.year else { return false }
            return span.contains(event.startSeconds)
        }
        
        for event in events {
            let eventDay = (event.startSeconds / 100_000) % 100
            if days[eventDay] < 3 { days[eventDay] += 1 }
        }
        
        return days
    }
    
    var body: some View {
        GeometryReader { geometryReader in
            let geo = gov.geoSize ?? geometryReader.size
            let isThisMonth = month.years == gov.eternalNow.time.years && month.month == gov.eternalNow.time.month
            VStack {
                
                HStack {
                    Text(month.yearTxt + "." + month.monthTxt)
                        .font(.largeTitle).bold()
                        .foregroundColor(isThisMonth ? .metricOrange : .primary)
                        .onTapGesture(count: 1) { gov.scale = .year }
                    Spacer()
                }
                
                Divider()
                
                VStack {
                    ForEach(0...9, id: \.self) { week in
                        let isThisWeek = isThisMonth && month.week == week
                        HStack {
                            Text("\(week)").bold()
                                .foregroundColor(isThisWeek ? .metricOrange : .primary)
                                .opacity(month.month == 3 && week > 6 ? 0 : 1)
                                .onTapGesture(count: 1) { goToDayWeekView(week: week, day: nil) }
                            
                            Spacer()
                            
                            HStack {
                                ForEach(0...9, id: \.self) { day in
                                    let isThisDay = isThisWeek && month.day == day
                                    let yearEnded = ((month.month*100) + (week*10) + day) > (metric.cal.isLeapYear(month.year) ? 365 : 364)

                                    ZStack {
                                        RoundedRectangle(cornerRadius: 11)
                                            .foregroundColor(isThisDay ? .metricOrange : .primary)
                                            .opacity(isThisDay ? 1.0 : 0.2)
                                        
                                        Text("\(day)")
                                            .font(.caption).bold()
                                        
                                        if !monthEvents.isEmpty {
                                            let pipNo = monthEvents[(week*10) + day]
                                            VStack {
                                                Spacer()
                                                HStack(spacing: 0) {
                                                    ForEach(0..<pipNo, id: \.self) { _ in
                                                        Circle()
                                                            .frame(width: 3, height: 3)
                                                            .padding(.horizontal, 2)
                                                    }
                                                }
                                            }
                                        }
                                    }
                                    .frame(width: geo.width * 0.068, height: 22)
                                    .opacity(yearEnded ? 0 : 1)
                                    .onTapGesture(count: 1) { goToDayWeekView(week: week, day: day) }
                                }
                            }
                        }
                    }
                }
                
            }
            .padding(.horizontal)
            .frame(width: geo.width, height: geo.width)
        }
    }
    
    private func goToDayWeekView(week: Int, day: Int?) {
        gov.finiteNotNow = metric.cal.replace(time: month, component: .week, with: week)
        if day != nil { gov.finiteNotNow = metric.cal.replace(time: gov.finiteNotNow!, component: .day, with: day!) }
        gov.scale = day != nil ? .day : .week
    }
}

#Preview {
    MonthFocusView(gov: Governor(), month: MetrixtTime(date: nil))
}
