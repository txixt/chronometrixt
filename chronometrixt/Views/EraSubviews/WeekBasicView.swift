//
//  WeekBasicView.swift
//  chronometrixt
//
//  Created by Becket on 4/13/26.
//

import SwiftUI

struct WeekBasicView: View {
    @Bindable var gov: Governor
    var week: MetrixtTime
    
    var body: some View {
        GeometryReader { geo in
            let isThisWeek = week.year == gov.eternalNow.time.year &&
                             week.month == gov.eternalNow.time.month &&
                             week.week == gov.eternalNow.time.week
            VStack {
                
                HStack {
                    Text(week.yearTxt + "." + week.monthTxt + week.weekTxt)
                        .font(.largeTitle).bold()
                        .foregroundColor(isThisWeek ? .metricOrange : .primary)
                    Spacer()
                }
                
                Divider()
                
                HStack {
                    ForEach(0...9, id: \.self) { day in
                        let isThisDay = isThisWeek && week.day == day
                        let yearEnded = (week.month*100) + (week.week*10) + day > (metric.cal.isLeapYear(week.year) ? 365:354)
                        
                        VStack {
                            Text("\(day)")
                                .bold()
                                .foregroundColor(isThisDay ? .metricOrange : .primary)
                            
                            ZStack {
                                RoundedRectangle(cornerRadius: 15)
                                    .fill(isThisDay ? .metricOrange : .primary)
                                    .opacity(isThisDay ? 1.0 : 0.2)
                                    .frame(width: geo.size.width * 0.07)
                                VStack {
                                    ForEach(0...9, id: \.self) { hour in
                                        Text("\(hour)")
                                            .font(.caption)
                                        Spacer()
                                    }
                                }
                                .opacity(yearEnded ? 0:1)
                            }
                            .frame(height: geo.size.width * 0.7)
                        }
                        
                        if day != 9 { Spacer() }
                        
                    }

                }
                
            }
            .padding(.horizontal)
            .frame(width: geo.size.width, height: geo.size.width)
        }
    }
}

#Preview {
    WeekBasicView(gov: Governor(), week: MetrixtTime(date: nil))
}
