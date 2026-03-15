//
//  MetricYearView.swift
//  chronometrixt
//
//  Created by Becket Bowes on 12/31/25.
//
//
//import SwiftUI
//
//struct MetricYearView: View {
//    @Binding var gov: Governor
//    var year: MetrixtTime?
//    
//    var body: some View {
//        let functionalTime = year ?? gov.finiteNotNow ?? gov.eternalNow.time
//        VStack {
//            Button(action: openEon) {
//                HStack {
//                    Text(functionalTime.yearTxt)
//                        .font(.largeTitle).bold()
//                        .foregroundColor(gov.finiteNotNow == nil ? .metricOrange : .primary)
//                    Spacer()
//                }
//            }
//
//            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2)) {
//                ForEach(MetricLogic.months.indices, id: \.self) { monthIndex in
//                    Button(action: { openMonth(monthIndex) }) {
//                        VStack {
//                            HStack {
//                                Text(MetricLogic.months[monthIndex])
//                                    .foregroundColor(gov.finiteNotNow == nil && monthIndex == gov.eternalNow.time.month ? .metricOrange : .primary)
//                                    .font(.system(size: 11)).bold()
//                                    Spacer()
//                            }
//
//                            LazyHGrid(rows: Array(repeating: GridItem(.flexible()), count: 10)) {
//                                ForEach(MetricLogic.weeks.indices, id: \.self) { weekIndex in
//                                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(minimum: 5, maximum: 15)), count: 10)) {
//                                        ForEach(MetricLogic.days.indices, id: \.self) { dayIndex in
//                                            
//                                            let yearDay = (monthIndex * 100) + (weekIndex * 10) + dayIndex
//                                            let finalDay = metric.cal.isLeapYear(functionalTime.year) ? 365 : 364
//                                            let yearDayString = String(format: "%03d", yearDay)
//                                            let isToday = gov.finiteNotNow == nil && gov.eternalNow.time.mwd == yearDay
//
//                                            Text(yearDayString)
//                                                .foregroundColor(yearDay > finalDay ? .clear : .primary)
//                                                .bold(isToday)
//                                                .background(isToday ? .metricOrange : .clear)
//                                                .font(.system(size: 05))
//                                                .lineLimit(1)
//                                                .padding(.bottom, -3)
//                                        }
//                                    }
//                                }
//                            }
//                        }
//                        .padding(.bottom)
//                    }
//                }
//            }
//        }
//        .padding()
//        .monospaced()
//    }
//    
//    private func openEon() {
//        gov.scale = .eon
//    }
//    
//    private func openMonth(_ month: Int) {
//        gov.finiteNotNow = metric.cal.replace(time: gov.someTimes[0], component: .month, with: month)
//        gov.scale = .month
//    }
//}
//
//#Preview {
//    MetricYearView(gov: .constant(Governor()))
//}
