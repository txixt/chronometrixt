//
//  YearMetricView.swift
//  chronometrixt
//
//  Created by Becket Bowes on 1/12/26.
//

import SwiftUI

struct YearMetricView: View {
    @Bindable var gov: Governor
    var year: MetrixtTime?
    
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
                                                    let pastEndOfYear = ((month * 100) + (week * 10) + day) > (isLeapYear ? 364 : 365)
                                                    RoundedRectangle(cornerRadius: 2)
                                                        .foregroundColor(isToday ? .metricOrange : .primary)
                                                        .frame(width: geo.size.width * 0.07, height: 4)
                                                        .shadow(color: isToday ? .metricOrange : .clear, radius: 5)
                                                        .shadow(color: isToday ? .metricOrange : .clear, radius: 5)
                                                        .shadow(color: isToday ? .metricOrange : .clear, radius: 5)
                                                        .opacity(pastEndOfYear ? 0 : 1)

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
    YearMetricView(gov: Governor())
}
