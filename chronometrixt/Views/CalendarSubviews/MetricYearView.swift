//
//  MetricYearView.swift
//  chronometrixt
//
//  Created by Becket Bowes on 12/31/25.
//

import SwiftUI

struct MetricYearView: View {
    @Binding var gov: Governor
    
    var body: some View {
        let functionalTime = gov.finiteNotNow ?? gov.eternalNow.time
        VStack {
            HStack {
                Text(functionalTime.yearText)
                    .font(.largeTitle).bold()
                    .foregroundColor(.metricOrange)
                Spacer()
            }
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2)) {
                ForEach(MetricLogic.months.indices, id: \.self) { monthIndex in
                    Button(action: { openMonth(monthIndex) }) {
                        VStack {
                            HStack {
                                Text(MetricLogic.months[monthIndex])
                                    .foregroundColor(gov.finiteNotNow == nil && monthIndex == gov.eternalNow.time.month ? .metricOrange : .black)
                                    .font(.system(size: 11)).bold()
                                    Spacer()
                            }

                            LazyHGrid(rows: Array(repeating: GridItem(.flexible()), count: 10)) {
                                ForEach(MetricLogic.weeks.indices, id: \.self) { weekIndex in
                                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(minimum: 5, maximum: 15)), count: 10)) {
                                        ForEach(MetricLogic.days.indices, id: \.self) { dayIndex in
                                            let yearDay = (monthIndex * 100) + (weekIndex * 10) + dayIndex
                                            let finalDay = gov.eternalNow.time.isLeapYear() ? 365 : 364
                                            let yearDayString = String(format: "%03d", yearDay)
                                            let isToday = gov.finiteNotNow == nil && gov.eternalNow.time.yearDays == yearDay

                                            Text(yearDayString)
                                                .foregroundColor(yearDay > finalDay ? .clear : .black)
                                                .bold(isToday)
                                                .background(isToday ? .metricOrange : .clear)
                                                .font(.system(size: 05))
                                                .lineLimit(1)
                                                .padding(.bottom, -3)
                                        }
                                    }
                                }
                            }
                        }
                        .padding(.bottom)
                    }
                }
            }
        }
        .padding()
        .monospaced()
    }
    
    private func openMonth(_ month: Int) {
        print(gov.eternalNow.time.mwdText)
    }
}

#Preview {
    MetricYearView(gov: .constant(Governor()))
}
