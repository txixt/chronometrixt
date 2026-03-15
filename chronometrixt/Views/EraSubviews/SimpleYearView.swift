//
//  SimpleYearView.swift
//  chronometrixt
//
//  Created by Becket Bowes on 12/31/25.
//

import SwiftUI

struct SimpleYearView: View {
    @Bindable var gov: Governor
    
    var body: some View {
        VStack {
            ForEach(MetricLogic.months.indices, id: \.self) { monthIndex in
                VStack {
                    if monthIndex != gov.eternalNow.time.month {

                        RoundedRectangle(cornerRadius: 5).frame(width: monthIndex != 3 ? 338 : (219.7), height: 10)
                            .padding(.trailing, monthIndex == 3 ? 118.3 : 0)
                            .foregroundColor(.secondary)

                    } else {
                        
                        VStack {
                            ForEach(MetricLogic.weeks.indices, id: \.self) { weekIndex in
                                HStack {
                                    ForEach(MetricLogic.days.indices, id: \.self) { dayIndex in
                                        let yearDay = (monthIndex * 100) + (weekIndex * 10) + dayIndex
                                        let finalDay = metric.cal.isLeapYear(gov.eternalNow.time.year) ? 365 : 364
                                        let isToday = gov.eternalNow.time.mwd == yearDay
                                        
                                        RoundedRectangle(cornerRadius: 5).frame(width: 30, height: 10)
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
                .padding(.vertical, 3)
            }
        }
    }
}

#Preview {
    SimpleYearView(gov: Governor())
}
