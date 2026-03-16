//
//  GlassWatchView.swift
//  watchixt Watch App
//
//  Created by Becket Bowes on 1/15/26.
//

import SwiftUI

struct GlassWatchView: View {
    var scale: CGFloat
    private let cal: Calendar = Calendar.current
    @Environment(\.isLuminanceReduced) private var dimmed

        var body: some View {
            let clockSize: CGFloat = 100 * scale
            let hourTickLength: CGFloat = 10 * scale
            let minuteTickLength: CGFloat = 5 * scale
            
            TimelineView(.everyMinute) { context in
                let metricMinutesToday: CGFloat = (CGFloat(cal.component(.hour, from: context.date) * 60) + CGFloat(cal.component(.minute, from: context.date))) / 1.44
                let hourRotation: CGFloat = (metricMinutesToday / 1000) * 360.0
                let minuteRotation: CGFloat = (metricMinutesToday.truncatingRemainder(dividingBy: 100) / 100) * 360.0
                
                ZStack {
                    
                    Circle()
                        .frame(width: 92 * scale, height: 92 * scale)
                        .glassEffect(.clear)
                    
                    
                    ForEach(0..<10) { hour in
                        GlassMetricClockNumeral(hour: hour, clockSize: clockSize)
                    }
                    
                    ForEach(0..<10) { hour in
                        RoundedRectangle(cornerRadius: scale * 1.5)
                            .fill(Color.black)
                            .frame(width: 3 * scale, height: hourTickLength * 2)
                            .offset(y: (clockSize - (hourTickLength * 3) ) / 2)
                            .rotationEffect(.degrees(Double(hour) * 36)) // 360/10
                    }
                    
                    ForEach(0..<100) { minute in
                        RoundedRectangle(cornerRadius: scale * 0.5)
                            .fill(minute % 10 == 0 ? Color.secondary : Color.black)
                            .frame(width: 1 * scale, height: minuteTickLength)
                            .offset(y: (clockSize - (minute % 10 == 0 ? (hourTickLength * 3) : (minuteTickLength * 3))) / 2)
                            .rotationEffect(.degrees(Double(minute) * 3.6)) // 360/100
                    }
                    
                    
                    Circle()
                        .fill(Color.black)
                        .frame(width: 5 * scale, height: 5 * scale)

                    if !dimmed {
                        GlassActiveHands(scale: scale, clockSize: clockSize)
                    } else {
                        GlassDimmedHands(scale: scale, clockSize: clockSize, hourRotation: hourRotation, minuteRotation: minuteRotation)
                    }
                }
                .frame(width: scale == 1.0 ? 101 : 100 * scale, height: scale == 1.0 ? 101 : 100 * scale)
                .monospaced()
                .padding(.bottom)
            }
        }
    }

struct GlassClockHand: View {
    let rotationDegrees: CGFloat
    let width: CGFloat
    let length: CGFloat
    let color: Color
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: (width * 0.5))
                .fill(.white)
                .frame(width: width, height: length)
            
            RoundedRectangle(cornerRadius: (width * 0.2))
                .fill(.black)
                .frame(width: width * 0.2, height: length * 0.9)
        }
        .offset(y: -length / 2)
        .rotationEffect(.degrees(rotationDegrees))
    }
}

struct GlassClockSecondHand: View {
    let rotationDegrees: CGFloat
    let width: CGFloat
    let length: CGFloat
    let color: Color
    
    @State private var rotation: CGFloat = 0
    
    var body: some View {
        VStack(spacing: 0) {
            Circle()
                .fill(color)
                .frame(width: length * 0.1, height: length * 0.1)
            RoundedRectangle(cornerRadius: (width * 0.5))
                .fill(color)
                .frame(width: width, height: length * 0.95)
        }
        .offset(y: -length / 2)
        .rotationEffect(.degrees(rotation))
        .onAppear {
            rotation = rotationDegrees
            withAnimation(.linear(duration: 86.4).repeatForever(autoreverses: false)) {
                rotation = rotationDegrees + 360
            }
        }
    }
}

struct GlassMetricClockNumeral: View {
    let hour: Int
    let clockSize: CGFloat
    
    var body: some View {
        Text("\(hour)")
            .font(.system(size: 8 * (clockSize / 100), weight: .semibold))
            .foregroundColor(.black)
            .offset(
                x: sin(angleForHour) * radius,
                y: -cos(angleForHour) * radius
            )
    }
    
    private var angleForHour: Double {
        Double(hour) * .pi / 5
    }
    
    private var radius: Double {
        Double(clockSize/4 - (clockSize / 22))
    }
}

private struct GlassActiveHands: View {
    let scale: CGFloat
    let clockSize: CGFloat
    private let cal: Calendar = Calendar.current
    
    var body: some View {
        TimelineView(.animation) { animation in
            let gregorianSecondsToday = CGFloat(cal.ordinality(of: .second, in: .day, for: animation.date) ?? 0)
            let metricSecondsToday = gregorianSecondsToday / 0.864
            let hourRot = (metricSecondsToday / 10_000) * 36.0
            let minRot = (metricSecondsToday / 100) * 360.0 / 100
            let secondRotation = (metricSecondsToday / 100) * 360.0
            
            ZStack {
                GlassClockHand(
                    rotationDegrees: hourRot,
                    width: 4 * scale,
                    length: clockSize * 0.25,
                    color: .black
                )
                
                GlassClockHand(
                    rotationDegrees: minRot,
                    width: 2 * scale,
                    length: clockSize * 0.4,
                    color: .black
                )
                
                GlassClockSecondHand(
                    rotationDegrees: secondRotation,
                    width: 0.5 * scale,
                    length: clockSize * 0.5,
                    color: .metricOrange
                )
                
                Circle()
                    .fill(Color.metricOrange)
                    .frame(width: 4 * scale, height: 6 * scale)
                Circle()
                    .fill(Color.black)
                    .frame(width: 2 * scale, height: 2 * scale)
            }
        }
    }
}

private struct GlassDimmedHands: View {
    let scale: CGFloat
    let clockSize: CGFloat
    let hourRotation: CGFloat
    let minuteRotation: CGFloat
    
    var body: some View {
        ZStack {
            GlassClockHand(
                rotationDegrees: hourRotation,
                width: 4 * scale,
                length: clockSize * 0.25,
                color: .black
            )
            
            GlassClockHand(
                rotationDegrees: minuteRotation,
                width: 2 * scale,
                length: clockSize * 0.4,
                color: .black
            )
        }
    }
}

#Preview {
    GlassWatchView(scale: 1.6)
}
