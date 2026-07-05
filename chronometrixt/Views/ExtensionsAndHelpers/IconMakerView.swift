//
//  IconMakerView.swift
//  chronometrixt
//
//  Created by Becket Bowes on 6/15/26.
//

import SwiftUI

struct IconMakerView: View {
    var clockSize: CGFloat = 1.0
    var radius: Double { Double(clockSize/2 - (clockSize / 6.2)) }
    
    var body: some View {
        HStack {
            
            VStack {
                ForEach(0...9, id: \.self) { _ in
                    RoundedRectangle(cornerRadius: 10)
                        .fill(.primary)
                        .frame(width: clockSize * 42, height: clockSize * 10)
                }
            }
            .frame(height: clockSize * 100)
            .padding()
            
            ZStack {
                Circle().fill(.background)
                Circle()
                    .fill(LinearGradient(gradient: Gradient(colors: [.white, .gray]), startPoint: .top, endPoint: .bottom))
                    .opacity(0.5)
                
                ForEach(0...9, id: \.self) { hour in
                    MetricClockNumeral(hour: hour, clockSize: clockSize * 180).monospaced().bold()
                }
                
                Circle()
                    .strokeBorder(.primary, lineWidth: 11)

                RoundedRectangle(cornerRadius: 5)
                    .fill(.primary)
                    .frame(width: 10, height: clockSize * 50)
                    .offset(y: clockSize * 25)
                    .rotationEffect(Angle(degrees: 60))
                
                RoundedRectangle(cornerRadius: 4)
                    .fill(.primary)
                    .frame(width: 8, height: clockSize * 70)
                    .offset(y: clockSize * 35)
                    .rotationEffect(Angle(degrees: -60))
                
                RoundedRectangle(cornerRadius: 2)
                    .fill(.metricOrange)
                    .offset(y: clockSize * 40)
                    .frame(width: 4, height: clockSize * 80)
                    .rotationEffect(Angle(degrees: 180))
                
                Circle()
                    .fill(.metricOrange)
                    .frame(width: 16, height: 16)
            }
            .frame(width: clockSize * 180, height: clockSize * 180)
            
            
        }
        .padding()
    }
    
    private func angleForHour(_ hour: Int) -> Double {
        Double(hour) * .pi / 5
    }
}

#Preview {
    IconMakerView()
}
