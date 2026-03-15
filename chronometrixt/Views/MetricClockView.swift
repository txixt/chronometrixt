//
//  MetricClockfaceView.swift
//  chronometrixt
//
//  Created by Becket Bowes on 12/30/25.
//

import SwiftUI

struct MetricClockNumeral: View {
    let hour: Int
    let clockSize: CGFloat
    
    var body: some View {
        Text("\(hour)")
            .font(.system(size: 12 * (clockSize / 100), weight: .semibold))
            .foregroundColor(.black)
            .position(
                x: clockSize/2 + sin(angleForHour) * radius,
                y: clockSize/2 - cos(angleForHour) * radius
            )
    }
    
    private var angleForHour: Double {
        Double(hour) * .pi / 5
    }
    
    private var radius: Double {
        Double(clockSize/2 - (clockSize / 6.2))
    }
}

struct ClockHand: View {
    let rotationDegrees: Double
    let width: CGFloat
    let length: CGFloat
    let color: Color
    
    var body: some View {
        RoundedRectangle(cornerRadius: 1)
            .fill(color)
            .frame(width: width, height: length)
            .offset(y: -length/2)
            .rotationEffect(.degrees(rotationDegrees))
    }
}

struct MetricClockView: View {
    @Bindable var gov: Governor
//    @Environment(\.scenePhase) var scenePhase
    var scale: CGFloat //1.0 = 100 x 100 clock
    
    var body: some View {
        let clockSize: CGFloat = 100 * scale
        let hourTickLength: CGFloat = 8 * scale
        let minuteTickLength: CGFloat = 5 * scale
        
        ZStack {
            Circle().fill(Color.white)
            Circle()
                .fill(LinearGradient(gradient: Gradient(colors: [.white, .gray]), startPoint: .top, endPoint: .bottom))
                .opacity(0.5)
            
            ForEach(0..<10) { hour in
                MetricClockNumeral(hour: hour, clockSize: clockSize)
            }
            
            ForEach(0..<10) { hour in
                Rectangle()
                    .fill(Color.black)
                    .frame(width: 2 * scale, height: hourTickLength)
                    .offset(y: (clockSize - hourTickLength) / 2)
                    .rotationEffect(.degrees(Double(hour) * 36)) // 360/10 = 36 degrees
            }
            
            ForEach(0..<100) { minute in
                Rectangle()
                    .fill(minute % 10 == 0 ? Color.white : Color.black)
                    .frame(width: 1 * scale, height: minuteTickLength)
                    .offset(y: (clockSize - minuteTickLength) / 2)
                    .rotationEffect(.degrees(Double(minute) * 3.6)) // 360/100 = 3.6 degrees
            }
            
            Circle()
                .strokeBorder(Color.black, lineWidth: 3)
                .shadow(color: .black, radius: 5)
            
            ClockHand(
                rotationDegrees: gov.eternalNow.time.hourHand, // 360/10 = 36 degrees/hour + 360/10000 = .36 minute offset
                width: 3 * scale,
                length: clockSize * 0.3,
                color: .black
            ).shadow(color: .black, radius: 1)
            
            ClockHand(
                rotationDegrees: gov.eternalNow.time.minuteHand, // 360/100 = 3.6 degrees per minute
                width: 2 * scale,
                length: clockSize * 0.4,
                color: .black
            ).shadow(color: .black, radius: 1)
            Circle()
                .fill(Color.black)
                .frame(width: 6, height: 6)

            ClockHand(
                rotationDegrees: gov.eternalNow.time.secondHand, // 360/100 = 3.6 degrees per second
                width: 1 * scale,
                length: clockSize * 0.45,
                color: .metricOrange
            ).shadow(color: .metricOrange, radius: 1)
//
//            
////            if scenePhase == .active {
////                ClockHand(
////                    rotationDegrees: Double(gov.eternalNow.time.second) * 3.6, // 360/100 = 3.6 degrees per second
////                    width: 1 * scale,
////                    length: clockSize * 0.45,
////                    color: .metricOrange
////                ).shadow(color: .metricOrange, radius: 1)
////            }
            
            Circle()
                .fill(Color.metricOrange)
                .frame(width: 4 * scale, height: 4 * scale)
            
            Circle()
                .strokeBorder(Color.gray, lineWidth: 1)

        }
        .frame(width: scale == 1.0 ? 101 : 100 * scale, height: scale == 1.0 ? 101 : 100 * scale)
        .monospaced()
    }
}

#Preview {
    MetricClockView(gov: Governor(), scale: 1.0)
}
