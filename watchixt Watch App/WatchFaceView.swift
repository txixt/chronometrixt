//
//  WatchFaceView.swift
//  watchixt Watch App
//
//  Created by Becket Bowes on 1/4/26.
//

import SwiftUI

struct WatchFaceView: View {
    @Binding var gov: WatchGovernor
    var scale: CGFloat
    @Environment(\.isLuminanceReduced) private var isLuminanceReduced

    var body: some View {
        let clockSize: CGFloat = 100 * scale
        let hourTickLength: CGFloat = 8 * scale
        let minuteTickLength: CGFloat = 5 * scale
        
        ZStack {
            
//            Rectangle().fill(LinearGradient(gradient: Gradient(colors: [.white, .gray]), startPoint: .top, endPoint: .bottom))
//                .frame(width: .infinity, height: .infinity).ignoresSafeArea()
            Circle().tint(.white)
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
                    .rotationEffect(.degrees(Double(hour) * 36)) // 360/10 
            }
            
            ForEach(0..<100) { minute in
                Rectangle()
                    .fill(minute % 10 == 0 ? Color.white : Color.black)
                    .frame(width: 1 * scale, height: minuteTickLength)
                    .offset(y: (clockSize - minuteTickLength) / 2)
                    .rotationEffect(.degrees(Double(minute) * 3.6)) // 360/100
            }
            
            Circle()
                .strokeBorder(Color.black, lineWidth: 3)
                .shadow(color: .black, radius: 5)
            
            ClockHand(
                rotationDegrees: (Double(gov.eternalNow.hour) * 36) + (Double(gov.eternalNow.minute) * 0.36), // 360/10 + 360/10000
                width: 3 * scale,
                length: clockSize * 0.3,
                color: .black
            )
            
            ClockHand(
                rotationDegrees: Double(gov.eternalNow.minute) * 3.6, // 360/100
                width: 2 * scale,
                length: clockSize * 0.4,
                color: .black
            )
            
            Circle()
                .fill(Color.black)
                .frame(width: 6, height: 6)

            if !isLuminanceReduced {
                ClockHand(
                    rotationDegrees: Double(gov.eternalNow.second) * 3.6, // 360/100
                    width: 1 * scale,
                    length: clockSize * 0.45,
                    color: .metricOrange
                )
            }
            
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

struct ClockHand: View {
    let rotationDegrees: Double
    let width: CGFloat
    let length: CGFloat
    let color: Color
    
    var body: some View {
        RoundedRectangle(cornerRadius: 1)
            .fill(color)
            .frame(width: width, height: length)
            .offset(y: -length / 2)
            .rotationEffect(.degrees(rotationDegrees))
            .shadow(color: color, radius: 1)
    }
}

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

#Preview {
    WatchFaceView(gov: .constant(WatchGovernor()), scale: 2.0)
}
