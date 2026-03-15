//
//  CalendarView.swift
//  watchixt Watch App
//
//  Created by Becket Bowes on 1/19/26.
//

import SwiftUI

struct CalendarView: View {
    private let cal: Calendar = Calendar.current
    
    var body: some View {
        TimelineView(.everyMinute) { context in
            let year = cal.component(.year, from: context.date) + 3030
            let metricDaysOfYear: Int = cal.component(.dayOfYear, from: context.date) - 1
            let month = metricDaysOfYear / 100
            let week = (metricDaysOfYear / 10) % 10
            
            VStack {
                HStack {
                    Text("\(String(year))").bold().monospaced()
                        .font(.title2)
                        .foregroundColor(.metricOrange)
                        .padding(.bottom)
                }
                
                ForEach(0..<4, id: \.self) { monthIndex in
                    VStack {
                        if monthIndex != month {

                            RoundedRectangle(cornerRadius: 5).frame(width: monthIndex != 3 ? 160 : 104, height: 10)
                                .padding(.trailing, monthIndex == 3 ? 56 : 0)
                                .foregroundColor(.secondary)

                        } else {
                            
                            VStack {
                                ForEach(0..<10, id: \.self) { weekIndex in
                                    
                                    if weekIndex != week {
                                        RoundedRectangle(cornerRadius: 2).frame(width: monthIndex == 3 && weekIndex == 6 ? (isLeapYear(year) ? 80 : 64) : 160, height: 4)
                                            .padding(.trailing, monthIndex == 3 && weekIndex == 6 ? (isLeapYear(year) ? 80 : 96) : 0)
                                            .foregroundColor(.secondary)
                                        
                                    } else {
                                        
                                        HStack {
                                            ForEach(0..<10, id: \.self) { dayIndex in
                                                let yearDay = (monthIndex * 100) + (weekIndex * 10) + dayIndex
                                                let finalDay = isLeapYear(year) ? 365 : 364
                                                let isToday = metricDaysOfYear == yearDay
                                                
                                                RoundedRectangle(cornerRadius: 7.5).frame(width: 15, height: 15)
                                                    .foregroundColor(yearDay > finalDay ? .clear : isToday ? .metricOrange : .secondary)
                                                    .padding(-2)
                                                    .shadow(color: isToday ? .metricOrange : .clear, radius: isToday ? 5 : 0)
                                                    .shadow(color: isToday ? .metricOrange : .clear, radius: isToday ? 5 : 0)
                                                    .shadow(color: isToday ? .metricOrange : .clear, radius: isToday ? 5 : 0)
                                            }
                                        }

                                    }
                                }
                            }
                        }
                    }
                }
            }
            .padding(.bottom, 25)
        }
    }
    
    private func isLeapYear(_ someYear: Int) -> Bool {
        let y = someYear - 2
        return (y % 4 == 0 && y % 100 != 0) || (y % 400 == 0)
    }
}

#Preview {
    CalendarView()
}
