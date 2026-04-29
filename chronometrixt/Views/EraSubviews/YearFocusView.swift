//
//  YearFocusView.swift
//  chronometrixt
//
//  Created by Becket Bowes on 4/11/26.
//

import SwiftUI
import SwiftData

struct YearFocusView: View {
//    @Query private var allEvents: [MetricEvent]
    @Bindable var gov: Governor
    var year: MetrixtTime

///TOO EXPENSIVE?
//    private var yearEvents: [Int] {
//        var days: [Int] = Array(repeating: 0, count: metric.cal.isLeapYear(year.year) ? 366 : 365)
//        guard !allEvents.isEmpty else { return days }
//        guard let span = gov.span else { return days }
//        
//        let events = allEvents.filter { event in
//            guard event.startYears == year.year else { return false }
//            return span.contains(event.startYears)
//        }
//        for event in events {
//            let eventDay = event.startSeconds / 100_000
//            if days[eventDay] < 3 { days[eventDay] += 1}
//        }
//        
//        return days
//    }
    
    var body: some View {
        GeometryReader { geometryReader in
            let geo = gov.geoSize ?? geometryReader.size
            VStack {
                
                HStack {
                    Text(year.yearTxt)
                        .font(.largeTitle).bold()
                        .foregroundStyle(year.year == gov.eternalNow.time.year ? .metricOrange : .primary)
                        .onTapGesture(count: 1) { gov.scale = .eon }
                    Spacer()
                }
                
                VStack {
                    ForEach(0...3, id: \.self) { month in
                        VStack {
                            Divider()
                            HStack(alignment: .top) {
                                Text("\(month)")
                                    .bold()
                                    .foregroundColor(year.year == gov.eternalNow.time.year && year.month == month ? .metricOrange : .primary)
                                Spacer()
                                
                                VStack(spacing: 3) {
                                    ForEach(0...9, id: \.self) { week in
                                        HStack {
                                            ForEach(0...9, id: \.self) { day in
                                                let thisMwd = ((month*100) + (week*10) + day)
                                                let isToday = thisMwd == gov.eternalNow.time.mwd && year.year == gov.eternalNow.time.year
                                                let isLeapYear = metric.cal.isLeapYear(year.year)
                                                let pastEndOfYear = thisMwd >= (isLeapYear ? 365 : 364)
                                                
                                                ZStack {
                                                    RoundedRectangle(cornerRadius: 2)
                                                        .frame(width: geo.width * 0.068, height: 4)
                                                        .foregroundColor(isToday ? .metricOrange : .primary)
                                                        .shadow(color: isToday ? .metricOrange : .clear, radius: 5)
                                                        .shadow(color: isToday ? .metricOrange : .clear, radius: 5)
                                                        .shadow(color: isToday ? .metricOrange : .clear, radius: 5)
                                                        .opacity(pastEndOfYear ? 0 : 1)
                                                    
//                                                    HStack(spacing: 0) {
//                                                        let pips = thisMwd < yearEvents.count ? yearEvents[thisMwd] : 0
//                                                        ForEach(0..<pips, id: \.self) { _ in
//                                                            Circle().fill(.background)
//                                                                .frame(width: 3, height: 3)
//                                                                .padding(.horizontal, 1)
//                                                        }
//                                                    }
                                                }
                                                
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        .onTapGesture(count: 1) { goToMonth(month) }
                    }
                }
            }
            .padding(.horizontal)
            .frame(width: geo.width, height: geo.width)
        }
    }
    
    private func goToMonth(_ month: Int) {
        gov.finiteNotNow = metric.cal.replace(time: year, component: .month, with: month)
        gov.scale = .month
    }
}

#Preview {
    YearFocusView(gov: Governor(), year: MetrixtTime(date: nil))
}
