//
//  MonthBasicView.swift
//  chronometrixt
//
//  Created by Becket Bowes on 4/12/26.
//

import SwiftUI

struct MonthBasicView: View {
    @Bindable var gov: Governor
    var month: MetrixtTime
    
    var body: some View {
        GeometryReader { geo in
            let isThisMonth = month.years == gov.eternalNow.time.years && month.month == gov.eternalNow.time.month
            VStack {
                
                HStack {
                    Text(month.yearTxt + "." + month.monthTxt)
                        .font(.largeTitle).bold()
                        .foregroundColor(isThisMonth ? .metricOrange : .primary)
                    Spacer()
                }
                
                Divider()
                
                VStack {
                    ForEach(0...9, id: \.self) { week in
                        let isThisWeek = isThisMonth && month.week == week
                        HStack {
                            Text("\(week)").bold()
                                .foregroundColor(isThisWeek ? .metricOrange : .primary)
                                .opacity(month.month == 3 && week > 6 ? 0 : 1)
                            
                            Spacer()
                            
                            HStack {
                                ForEach(0...9, id: \.self) { day in
                                    let isThisDay = isThisWeek && month.day == day
                                    let yearEnded = ((month.month*100) + (week*10) + day) > (metric.cal.isLeapYear(month.year) ? 365 : 354)

                                    ZStack {
                                        RoundedRectangle(cornerRadius: 11)
                                            .foregroundColor(isThisDay ? .metricOrange : .primary)
                                            .opacity(isThisDay ? 1.0 : 0.2)
                                        
                                        Text("\(day)")
                                            .font(.caption).bold()
                                    }
                                    .frame(width: geo.size.width * 0.068, height: 22)
                                    .opacity(yearEnded ? 0 : 1)
                                }
                            }
                        }
                    }
                }
                
            }
            .padding(.horizontal)
            .frame(width: geo.size.width, height: geo.size.width)
        }
    }
}

#Preview {
    MonthBasicView(gov: Governor(), month: MetrixtTime(date: nil))
}
