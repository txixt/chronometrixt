//
//  YearBasicView.swift
//  chronometrixt
//
//  Created by Becket Bowes on 4/11/26.
//

import SwiftUI
import SwiftData

struct YearBasicView: View {
    @Bindable var gov: Governor
    var year: MetrixtTime
    
    var body: some View {
        GeometryReader { geometryReader in
            let geo = gov.geoSize ?? geometryReader.size
            VStack {
                
                HStack {
                    Text(year.yearTxt)
                        .font(.largeTitle).bold()
                        .foregroundStyle(year.year == gov.eternalNow.time.year ? .metricOrange : .primary)
                    Spacer()
                }
                
                VStack {
                    ForEach(0...3, id: \.self) { month in
                        VStack {
                            Divider()
                            HStack(alignment: .top) {
                                Text("\(month)")
                                    .bold()
                                    .foregroundColor(year.year == gov.eternalNow.time.year && year.month == month ? .metricOrange : .primary)
                                Spacer()
                                
                                VStack(spacing: 3) {
                                    ForEach(0...9, id: \.self) { week in
                                        HStack {
                                            ForEach(0...9, id: \.self) { day in
                                                let thisMwd = ((month*100) + (week*10) + day)
                                                let isToday = thisMwd == gov.eternalNow.time.mwd && year.year == gov.eternalNow.time.year
                                                let isLeapYear = metric.cal.isLeapYear(year.year)
                                                let pastEndOfYear = thisMwd >= (isLeapYear ? 365 : 364)
                                                
                                                RoundedRectangle(cornerRadius: 2)
                                                    .frame(width: geo.width * 0.068, height: 4)
                                                    .foregroundColor(isToday ? .metricOrange : .primary)
                                                    .opacity(pastEndOfYear ? 0 : 1)
                                                
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                
            }
            .padding(.horizontal)
            .frame(width: geo.width, height: geo.width)
        }
    }
}

#Preview {
    @Previewable @Environment(\.modelContext) var context
    YearBasicView(gov: Governor(), year: MetrixtTime(date: nil))
}
