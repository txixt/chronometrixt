//
//  SimpleClockView.swift
//  watchixt Watch App
//
//  Created by Becket Bowes on 1/8/26.
//

import SwiftUI

struct SimpleMetricIcon: View {
    var scale: CGFloat = 0.15
    private let cal: Calendar = .current
    
    var body: some View {
        TimelineView(.everyMinute) { context in
            let percentOfYear: CGFloat = CGFloat(cal.component(.dayOfYear, from: context.date)) / CGFloat(cal.range(of: .day, in: .year, for: Date())!.count)
            let metricMinutesToday: CGFloat = (CGFloat(cal.component(.hour, from: context.date) * 60) + CGFloat(cal.component(.minute, from: context.date))) / 1.44
            let hourRotation: CGFloat = (metricMinutesToday / 1000) * 360.0
            let minuteRotation: CGFloat = (metricMinutesToday.truncatingRemainder(dividingBy: 100) / 100) * 360.0
            
            VStack {
                HStack {
                    
                    ZStack(alignment: .top) {
                        RoundedRectangle(cornerRadius: 2 * scale)
                            .fill(.secondary)
                        
                        RoundedRectangle(cornerRadius: 2 * scale)
                            .fill(Color.primary)
                            .frame(height: 100 * scale * percentOfYear)
                            .mask(
                                RoundedRectangle(cornerRadius: 2 * scale)
                            )
                    }
                    .frame(width: 20 * scale, height: 100 * scale)
                    .padding(.trailing, scale > 0.3 ? 0 : -3)
                    
                    ZStack {
                        Circle().frame(width: scale * 100, height: scale * 100)
                            .foregroundColor(.secondary)
                        
                        RoundedRectangle(cornerRadius: 2 * scale)
                            .fill(Color.primary)
                            .frame(width: 8 * scale, height: 30 * scale)
                            .offset(x: 0, y: -15 * scale)
                            .rotationEffect(Angle(degrees: hourRotation))
                        
                        RoundedRectangle(cornerRadius: 2 * scale)
                            .fill(Color.primary)
                            .frame(width: 5 * scale, height: 50 * scale)
                            .offset(x: 0, y: -25 * scale)
                            .rotationEffect(Angle(degrees: minuteRotation))
                        
                        Circle().frame(width: scale * 10, height: scale * 10)
                            .foregroundColor(Color.black)
                        
                    }
                }
                .padding()
                
                SimpleMetricText()
            }
        }
    }
}

struct SimpleMetricText: View {
    var scale: CGFloat = 1.5
    let cal: Calendar = .current

    var body: some View {
        TimelineView(.everyMinute) { context in
            let metricYear: String = String(cal.component(.year, from: context.date) + 3030)
            let metricDay: String = String(format: "%03d", cal.component(.dayOfYear, from: context.date))
            let metricMinutesToday: CGFloat = (CGFloat(cal.component(.hour, from: context.date) * 60) + CGFloat(cal.component(.minute, from: context.date))) / 1.44
            let metricHour: String = String(Int(metricMinutesToday / 100))
            let metricMinute: String = String(format: "%02d", Int(metricMinutesToday) % 100)
            
            VStack {
                Text(metricYear + "•" + metricDay + "•" + metricHour + ":" + metricMinute)
                    .monospaced()
                    .bold()
                    .font(.system(size: 10 * scale))
            }
        }
    }
}

#Preview {
    SimpleMetricIcon()
}
