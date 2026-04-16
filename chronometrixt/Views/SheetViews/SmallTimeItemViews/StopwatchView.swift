//
//  StopWatchView.swift
//  chronometrixt
//
//  Created by Becket Bowes on 4/15/26.
//

import SwiftUI

struct StopwatchView: View {
    @Bindable var gov: Governor
    @Bindable var ag: AlarmGovernor
    
    var body: some View {
        VStack {
            Spacer()
            
            HStack {
                let hour: Int = ag.stopwatch / 10_000
                let min: Int = (ag.stopwatch / 100) % 100
                let sec: Int = ag.stopwatch % 100
                let timeString: String = String(format: "%d:%02d:%02d", hour, min, sec)
                
                Text(timeString)
                    .font(.system(size: 80))
            }
            .onChange(of: gov.eternalNow.time) {
                if ag.isStopwatching { ag.stopwatch += 1 }
            }
            .padding(.bottom)
            
            HStack {
                let gregSecs = Int(Double(ag.stopwatch) * 0.864)
                let hours = gregSecs / 3600
                let minutes = (gregSecs / 60) % 60
                let seconds = gregSecs % 60
                let timeString = String(format: "%d:%02d:%02d", hours, minutes, seconds)
                
                Text("greorian: " + timeString)
                    .font(.title)
                    .foregroundStyle(.gray)
            }
            
            Spacer()
            
            HStack {
                Button(action: reset) {
                    Text("reset")
                        .foregroundStyle(.background)
                        .font(.title).bold()
                        .frame(width: 120, height: 80)
                        .background(RoundedRectangle(cornerRadius: 10).fill(.gray))
                }
                
                Spacer()
                
                Button(action: { ag.isStopwatching.toggle() }) {
                    Text(ag.isStopwatching ? "pause" : "start")
                        .foregroundStyle(.background)
                        .font(.title).bold()
                        .frame(width: 120, height: 80)
                        .background(RoundedRectangle(cornerRadius: 10).fill(.metricOrange))
                }
            }
            
            Spacer()
        }
        .padding()
        .monospaced()
    }
    
    private func reset() {
        ag.isStopwatching = false
        ag.stopwatch = 0
    }
}

#Preview {
    StopwatchView(gov: Governor(), ag: AlarmGovernor())
}
