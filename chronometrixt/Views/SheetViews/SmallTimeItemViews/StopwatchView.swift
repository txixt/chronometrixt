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
                
                Text("gregorian: " + timeString)
                    .font(.title)
                    .foregroundStyle(.gray)
            }
            
            Spacer()
        
            HStack {
                SmallTimeButtonView(imageString: "restart", text: "reset", action: reset, color: .gray)
            
                Spacer()
                
                SmallTimeButtonView(imageString: ag.isStopwatching ? "pause" : "play", text: ag.isStopwatching ? "pause" : "start", action: playPause, color: .metricOrange)
            }
            
            Spacer()
        }
        .padding()
        .monospaced()
    }
    
    private func playPause() { ag.isStopwatching.toggle() }
    
    private func reset() {
        ag.isStopwatching = false
        ag.stopwatch = 0
    }
}

#Preview {
    StopwatchView(gov: Governor(), ag: AlarmGovernor())
}
