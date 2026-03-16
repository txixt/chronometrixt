//
//  CalendarView.swift
//  watchixt Watch App
//
//  Created by Becket Bowes on 1/19/26.
//

import SwiftUI

struct CalendarView: View {
    @Environment(\.isLuminanceReduced) var dimmed
    private let cal: Calendar = Calendar.current
    
    var body: some View {
        TimelineView(.everyMinute) { context in
            let year = cal.component(.year, from: context.date) + 3030
            let second: Int = Int(Float(cal.ordinality(of: .second, in: .day, for: context.date)!) / 0.864)
            let metricDaysOfYear: Int = cal.component(.dayOfYear, from: context.date) - 1
            let month = metricDaysOfYear / 100
            let week = (metricDaysOfYear / 10) % 10
            let day = metricDaysOfYear % 10
            
            VStack {
                HStack(spacing: 0) {
                    Spacer()
                    Text("\(String(year)).\(month)\(week)\(day)").bold().monospaced()
                        .font(.caption)
                        .monospaced()
                        .foregroundColor(.metricOrange)
                        .opacity(0.6)
                    if !dimmed {
                        TimeView(seconds: second)
                    }
                }
                .padding()
                .background(RoundedRectangle(cornerRadius: 8).fill(.gray).opacity(0.2))
                .padding()
                
                VStack {
                    ForEach(0..<4, id: \.self) { monthIndex in
                        VStack {
                            if monthIndex != month {

                                RoundedRectangle(cornerRadius: 2).frame(width: monthIndex != 3 ? 170 : 109, height: 4)
                                    .padding(.trailing, monthIndex == 3 ? 61 : 0)
                                    .foregroundColor(.secondary)

                            } else {
                                
                                VStack {
                                    ForEach(0..<10, id: \.self) { weekIndex in
                                        
                                        if weekIndex != week {
                                            RoundedRectangle(cornerRadius: 3).frame(width: monthIndex == 3 && weekIndex == 6 ? (isLeapYear(year) ? 85 : 69) : 170, height: 6)
                                                .padding(.trailing, monthIndex == 3 && weekIndex == 6 ? (isLeapYear(year) ? 85 : 101) : 0)
                                                .foregroundColor(.primary)
                                            
                                        } else {
                                            
                                            HStack {
                                                ForEach(0..<10, id: \.self) { dayIndex in
                                                    let yearDay = (monthIndex * 100) + (weekIndex * 10) + dayIndex
                                                    let finalDay = isLeapYear(year) ? 365 : 364
                                                    let isToday = metricDaysOfYear == yearDay
                                                    
                                                    RoundedRectangle(cornerRadius: 5).frame(width: 10, height: 10)
                                                        .foregroundColor(yearDay > finalDay ? .clear : isToday ? .metricOrange : .primary)
                                                        .padding(-2)
                                                        .shadow(color: isToday ? .metricOrange : .clear, radius: isToday ? 5 : 0)
                                                        .shadow(color: isToday ? .metricOrange : .clear, radius: isToday ? 5 : 0)
                                                        .shadow(color: isToday ? .metricOrange : .clear, radius: isToday ? 5 : 0)
                                                    if dayIndex != 9 { Spacer() }
                                                }
                                            }
                                            .frame(width: 160)

                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                .padding()
                .background(RoundedRectangle(cornerRadius: 8).fill(.gray).opacity(0.5))
                

            }
            .padding(.bottom, 25)
        }
    }
    
    private func isLeapYear(_ someYear: Int) -> Bool {
        let y = someYear - 2
        return (y % 4 == 0 && y % 100 != 0) || (y % 400 == 0)
    }
}

struct TimeView: View {
    @State var seconds: Int
    var body: some View {
        HStack(spacing: 0) {
            Text(".\(seconds / 10000):\(String(format: "%02d", (seconds / 100) % 100)):\(String(format: "%02d", seconds % 100))")
        }
        .font(.caption)
        .monospaced()
        .foregroundColor(.metricOrange)
        .shadow(color: .metricOrange, radius: 3)
        .onAppear { tickTock() }
    }
    
    private func tickTock() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.864) {
            seconds += 1
            self.tickTock()
        }
    }
}

#Preview {
    CalendarView()
}
