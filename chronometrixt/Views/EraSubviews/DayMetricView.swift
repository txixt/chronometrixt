//
//  DayMetricView.swift
//  chronometrixt
//
//  Created by Becket Bowes on 1/12/26.
//

import SwiftUI

struct DayMetricView: View {
    @Bindable var gov: Governor
    var day: MetrixtTime?
    
    var body: some View {
        let govTime = gov.finiteNotNow ?? gov.eternalNow.time
        let someTime = day ?? govTime
        
        GeometryReader { geo in
            ZStack {
                VStack {
                    
                    Button(action: goToYearView) {
                        HStack {
                            Text(someTime.yearTxt + "." + someTime.mwdTxt)
                                .font(.largeTitle.bold())
                                .foregroundColor(someTime.year == gov.eternalNow.time.year && someTime.mwd == gov.eternalNow.time.mwd ? .metricOrange : .primary)
                            Spacer()
                        }
                    }
                    
                    Divider()

                    VStack {
                        ForEach(0..<10, id: \.self) { hour in
                            ZStack {
                                RoundedRectangle(cornerRadius: 10).frame(width: geo.size.width * 0.9, height: 25)
                                    .foregroundColor(.gray).opacity(0.2)
            
                                HStack {
                                    Button(action: { selectTime(hours: hour, minutes: 0) } ) {
                                        Text("\(hour)").bold().foregroundColor(.primary)
                                    }
                                    
                                    Spacer()
                                    
                                    ForEach(0..<10, id:\.self) { minutes in
                                        Button(action: { selectTime(hours: hour, minutes: minutes) } ) {
                                            Text(":\(minutes)0")
                                                .font(.caption)
                                                .foregroundColor(.gray)
                                            Spacer()
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                .padding()
                .monospaced()
                .opacity(someTime.year == govTime.year && someTime.month == govTime.month && someTime.week == govTime.week && someTime.day == govTime.day ? 1 : 0.2)
            }
            .frame(width: geo.size.width, height: geo.size.width)
        }
    }
    
    private func goToYearView() {
        gov.scale = .year
    }
    
    private func selectTime(hours: Int, minutes: Int) {
        gov.finiteNotNow = metric.cal.replace(time: gov.someTimes[0], component: .hour, with: hours)
        gov.finiteNotNow = metric.cal.replace(time: gov.finiteNotNow!, component: .minute, with: minutes)
    }
//    private func selectTime(timeInt: Int) {
//        if gov.finiteNotNow == nil { gov.finiteNotNow = gov.eternalNow.time }
//        gov.finiteNotNow!.hour = timeInt / 10_000
//        gov.finiteNotNow!.minute = (timeInt / 100) % 100
//        gov.finiteNotNow!.second = 0
//        gov.finiteNotNow!.updateRawFromComponents()
//    }
}

#Preview {
    DayMetricView(gov: Governor(), day: MetrixtTime(date: nil))
}
