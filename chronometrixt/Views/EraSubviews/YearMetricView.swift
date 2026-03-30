//
//  YearMetricView.swift
//  chronometrixt
//
//  Created by Becket Bowes on 1/12/26.
//

import SwiftUI
import SwiftData

struct YearMetricView: View {
    @Query private var allEvents: [MetricEvent]
    @Bindable var gov: Governor
    var year: MetrixtTime?
    
    private var yearEvents: [Int] {
        let isLeapYear = metric.cal.isLeapYear(year?.year ?? gov.eternalNow.time.year)
        var days: [Int] = Array(repeating: 0, count: isLeapYear ? 366 : 365)
        guard !allEvents.isEmpty else { return days }
        guard let span = gov.span else { return days }
        
        let events = allEvents.filter { event in
            guard event.startYears == year?.year ?? gov.eternalNow.time.year else { return false }
            return span.contains(event.startYears)
        }
        for event in events {
            let eventDay = (event.startSeconds / 100_000)
            if days[eventDay] < 3 { days[eventDay] += 1 }
        }
        
        return days
    }
    
    var body: some View {
        let govTime = gov.finiteNotNow ?? gov.eternalNow.time
        let someTime = year ?? govTime
        
        GeometryReader { geo in
            VStack {
                HStack {
                    Text(someTime.yearTxt)
                    .font(.largeTitle).bold()
                    .foregroundColor(someTime.year == gov.eternalNow.time.year && someTime.month == gov.eternalNow.time.month ? .metricOrange : .primary)
                    .onTapGesture(count: 1) { goToEonView() }
                    Spacer()
                }
                .padding(.horizontal)
                
                VStack {
                    ForEach(0..<4, id: \.self) { month in
                        VStack {
                            
                            VStack {
                                Divider()
                                HStack(alignment: .top) {
                                    Text("\(month)")
                                    .bold()
                                    .foregroundColor(someTime.year == gov.eternalNow.time.year && someTime.month == month ? .metricOrange : .primary)
                                    
                                    Spacer()
                                    
                                    VStack(spacing: 3) {
                                        ForEach(0..<10, id: \.self) { week in
                                            HStack() {
                                                ForEach(0..<10, id: \.self) { day in
                                                    let isToday = someTime.year == gov.eternalNow.time.year && someTime.month == month && someTime.week == week && someTime.day == day
                                                    let isLeapYear = metric.cal.isLeapYear(someTime.year)
                                                    let pastEndOfYear = ((month * 100) + (week * 10) + day) >= (isLeapYear ? 365 : 364)
                                                    
                                                    ZStack {
                                              
                                                        
                                                        RoundedRectangle(cornerRadius: 2)
                                                            .foregroundColor(isToday ? .metricOrange : .primary)
                                                            .frame(width: geo.size.width * 0.07, height: 4)
                                                            .shadow(color: isToday ? .metricOrange : .clear, radius: 5)
                                                            .shadow(color: isToday ? .metricOrange : .clear, radius: 5)
                                                            .shadow(color: isToday ? .metricOrange : .clear, radius: 5)
                                                            .opacity(pastEndOfYear ? 0 : 1)
                                                        
                                                        if (gov.finiteNotNow != nil && gov.finiteNotNow == year && !yearEvents.isEmpty && !pastEndOfYear)
                                                            || (year != nil && year!.year == gov.eternalNow.time.year && !pastEndOfYear) {
                                                            
                                                            HStack(spacing: 0) {
                                                                let dayIndex = (month * 100) + (week * 10) + day
                                                                let pipNo = (dayIndex < yearEvents.count) ? yearEvents[dayIndex] : 0

                                                                ForEach(0..<pipNo, id: \.self) { _ in
                                                                    Circle().fill(.background).frame(width: 3, height: 3)
                                                                        .padding(.horizontal, 1)
                                                                        .opacity(0.5)
                                                                }
                                                            }
                                                        }
                                                        
                                                        
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                            .onTapGesture(count: 1) { goToMonthView(month: month) }
                            
                        }
                    }
                }
                .padding(.horizontal)
            }
            .frame(width: geo.size.width, height: geo.size.width)
            .monospaced()
        }
    }
    
    private func goToEonView() {
        gov.scale = .eon
    }
    
    private func goToMonthView (month: Int) {
        gov.finiteNotNow = metric.cal.replace(time: gov.someTimes[1], component: .month, with: month)
        gov.scale = .month
    }
}

#Preview {
    // Create a preview with mock data
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: MetricEvent.self, configurations: config)
    
    // Optionally insert sample events
    let context = container.mainContext
    let sampleEvents: [MetricEvent] = dummyMetricEvents
    for event in sampleEvents { context.insert(event) }

    
    return YearMetricView(gov: Governor(), year: nil)
        .modelContainer(container)
}
