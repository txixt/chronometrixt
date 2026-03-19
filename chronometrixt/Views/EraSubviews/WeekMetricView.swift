//
//  WeekMetricView.swift
//  chronometrixt
//
//  Created by Becket Bowes on 1/12/26.
//

import SwiftUI

struct WeekMetricView: View {
    @Bindable var gov: Governor
    var week: MetrixtTime?
    
    var body: some View {
        let govTime = gov.finiteNotNow ?? gov.eternalNow.time
        let someTime = week ?? govTime
        
        GeometryReader { geo in
            ZStack {
                VStack {
                    HStack(spacing: 0) {
                        Text(someTime.yearTxt + "." + someTime.monthTxt + ":" + someTime.weekTxt)
                            .font(.largeTitle).bold()
                            .foregroundColor(someTime.year == gov.eternalNow.time.year && someTime.month == gov.eternalNow.time.month && someTime.week == gov.eternalNow.time.week ? .metricOrange : .primary)
                        Spacer()
                    }
                    .onTapGesture(count: 1) { goToYearView() }
                    
                    Divider()
                    
                    HStack {
                        ForEach(0..<10, id: \.self) { day in
                            let isToday = someTime.year == gov.eternalNow.time.year && someTime.month == gov.eternalNow.time.month && someTime.week == gov.eternalNow.time.week && someTime.day == day
                            
                            VStack {
                                Text("\(day)")
                                    .bold()
                                    .foregroundColor(isToday ? .metricOrange : .primary)
                                    .onTapGesture(count: 1) { goToDayView(day: day, hour: nil) }

                                ZStack {

                                    VStack {
                                        
                                        ForEach(0..<10, id: \.self) { hour in
                                            Text("\(hour)")
                                                .font(.caption)
                                                .foregroundColor(isToday ? .primary : .gray)
                                                .onTapGesture(count: 1) { goToDayView(day: day, hour: hour)  }
                                                .padding(.vertical, 2.5)
                                        }
                                        
                                    }
                                    .padding(10)
                                    .padding(.bottom, 3)
                                    .background(RoundedRectangle(cornerRadius: 8)
                                        .foregroundColor(isToday ? .metricOrange : .primary).opacity(isToday ? 0.5 : 0.2))
                                }
                            }
                            if day != 9 { Spacer() }
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
    
    private func goToDayView(day: Int, hour: Int?) {
        gov.finiteNotNow = metric.cal.replace(time: gov.someTimes[1], component: .day, with: day)
        if hour != nil {
            gov.finiteNotNow = metric.cal.replace(time: gov.finiteNotNow!, component: .hour, with: hour!)
            gov.finiteNotNow = metric.cal.replace(time: gov.finiteNotNow!, component: .minute, with: 0)
            gov.finiteNotNow = metric.cal.replace(time: gov.finiteNotNow!, component: .second, with: 0)
        }
        gov.scale = .day
    }
}

#Preview {
    WeekMetricView(gov: Governor())
}

//let someTime = week ?? gov.finiteNotNow ?? gov.eternalNow.time
//
//GeometryReader { geo in
//    VStack {
//        Button(action: goToYearView) {
//            HStack {
//                Text(someTime.yearText + "•" + someTime.monthText + ":" + someTime.weekText)
//                    .font(.title).bold()
//                    .foregroundColor(someTime.year == gov.eternalNow.time.year && someTime.month == gov.eternalNow.time.month && someTime.week == gov.eternalNow.time.week ? .metricOrange : .primary)
//                Spacer()
//            }
//        }
//        .padding(.bottom)
//        
//        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 10)) {
//            ForEach(0..<10, id: \.self) { day in
//                VStack() {
//                    Button(action: { goToDayView(day: day, hour: nil)}) {
//                        VStack {
//                            Text("\(day)").bold().foregroundColor(someTime.year == gov.eternalNow.time.year && someTime.month == gov.eternalNow.time.month && someTime.week == gov.eternalNow.time.week && someTime.day == day ? .metricOrange : .primary)
//                            Text(MetricLogic.days[day]).bold().font(.system(size: 7))
//                                .foregroundColor(someTime.year == gov.eternalNow.time.year && someTime.month == gov.eternalNow.time.month && someTime.week == gov.eternalNow.time.week && someTime.day == day ? .metricOrange : .primary)
//                        }
//                    }
//
//                    ZStack {
//                        Rectangle().frame(height: geo.size.height * 0.5)
//                            .foregroundColor(.clear)
//                            .border(someTime.year == gov.eternalNow.time.year && someTime.month == gov.eternalNow.time.month && someTime.week == gov.eternalNow.time.week && someTime.day == day ? .metricOrange : .primary, width: someTime.year == gov.eternalNow.time.year && someTime.month == gov.eternalNow.time.month && someTime.week == gov.eternalNow.time.week && someTime.day == day ? 3.0 : 0.5).opacity(0.5)
//                        LazyHGrid(rows: Array(repeating: GridItem(.flexible()), count: 10)) {
//                            ForEach(0..<10, id: \.self) { hour in
//                                Button(action: { goToDayView(day: day, hour: hour) }) {
//                                    Text("\(hour)")
//                                        .font(.caption)
//                                        .foregroundColor(.gray)
//                                }
//                            }
//                        }
//                        .padding(.bottom)
//                        .frame(height: geo.size.height * 0.5)
//                    }
//                }
//
//            }
//            .frame(height: geo.size.height * 0.6)
//        }
//        .frame(height: geo.size.height * 0.6)
//    }
//    .padding()
//}
//.monospaced()
//}
