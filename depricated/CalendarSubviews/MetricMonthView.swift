//
//  MetricMonthView.swift
//  chronometrixt
//
//  Created by Becket Bowes on 12/31/25.
//
//
//import SwiftUI
//
//struct MetricMonthView: View {
//    @Binding var gov: Governor
//    
//    var body: some View {
//        let functionalTime = gov.finiteNotNow ?? gov.eternalNow.time
//        VStack {
//            HStack {
//                Text(functionalTime.yearTxt + " • " + functionalTime.monthTxt)
//                    .font(.largeTitle).bold()
//                    .foregroundColor(.metricOrange)
//                Spacer()
//            }
//            .padding(.bottom)
//            VStack {
//                HStack {
//                    Text(MetricLogic.months[functionalTime.month])
//                        .foregroundColor(gov.finiteNotNow == nil && functionalTime.month == gov.eternalNow.time.month ? .metricOrange : .primary)
//                        .font(.system(size: 22)).bold()
//                        Spacer()
//                }
//                .padding(.bottom)
//
//                VStack {
//                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 10)) {
//                        ForEach(MetricLogic.days, id: \.self) { dayName in
//                            Text(dayName)
//                                .font(.system(size: 8))
//                                .foregroundColor(.gray)
//                        }
//                    }
//                    Divider()
//                    LazyHGrid(rows: Array(repeating: GridItem(.flexible()), count: 10)) {
//                        ForEach(MetricLogic.weeks.indices, id: \.self) { weekIndex in
//                            LazyVGrid(columns: Array(repeating: GridItem(.flexible(minimum: 11, maximum: 42)), count: 10)) {
//                                ForEach(MetricLogic.days.indices, id: \.self) { dayIndex in
//                                    let yearDay = (functionalTime.month * 100) + (weekIndex * 10) + dayIndex
//                                    let finalDay = metric.cal.isLeapYear(functionalTime.year) ? 365 : 364
//                                    let yearDayString = String(format: "%03d", yearDay)
//                                    let isToday = gov.finiteNotNow == nil && gov.eternalNow.time.mwd == yearDay
//
//                                    Button(action: { if yearDay <= finalDay { openDay(dayIndex) } }) {
//                                        Text(yearDayString)
//                                            .foregroundColor(yearDay > finalDay ? .clear : .primary)
//                                            .bold(isToday)
//                                            .background(isToday ? .metricOrange : .clear)
//                                            .font(.system(size: 8))
//                                            .lineLimit(1)
//                                            .padding(.vertical, 30)
//                                            .padding(.horizontal, 8)
//                                    }
//                                    
//                                }
//                            }
//                        }
//                    }
//                }
//            }
//        }
//        .padding()
//        .monospaced()
//    }
//    
//    private func openDay(_ day: Int) {
////        if gov.finiteNotNow == nil && day == gov.eternalNow.time.day {
////            gov.scale = .day
////            return
////        }
////        if gov.finiteNotNow == nil {
////            gov.finiteNotNow = gov.eternalNow.time
////        }
////        if gov.finiteNotNow!.day != day {
////            gov.finiteNotNow!.day = day
////        }
//        gov.finiteNotNow = metric.cal.replace(time: gov.someTimes[1], component: .day, with: day)
//        gov.scale = .day
//    }
//}
//
//#Preview {
//    MetricMonthView(gov: .constant(Governor()))
//}
