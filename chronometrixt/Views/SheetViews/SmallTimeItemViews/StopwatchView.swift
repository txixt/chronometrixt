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
                let hour: Int = ag.stopwatch.metricMicroseconds / 1_000_000
                let min: Int = (ag.stopwatch.metricMicroseconds / 10_000) % 100
                let sec: Int = (ag.stopwatch.metricMicroseconds / 100) % 100
                let msec: Int = ag.stopwatch.metricMicroseconds % 100
                let timeString: String = String(format: "%d:%02d:%02d.%02d", hour, min, sec, msec)
                
                Text(timeString)
                    .font(.system(size: 55))
            }
            .padding(.bottom)
            
            HStack {
                let gregSecs = Int(Double(ag.stopwatch.metricMicroseconds) * 0.864)
                let hours = gregSecs / 360000
                let minutes = (gregSecs / 6000) % 60
                let seconds = (gregSecs / 100) % 60
                let msecs = gregSecs % 100
                let timeString = String(format: "%d:%02d:%02d.%02d", hours, minutes, seconds, msecs)
                
                Text("gregorian: " + timeString)
            }
            
            Spacer()
        
            HStack {
                SmallTimeButtonView(imageString: "restart", text: "reset", action: reset, color: .gray)
            
                Spacer()
                
                SmallTimeButtonView(imageString: ag.stopwatch.isStopwatching ? "pause" : "play", text: ag.stopwatch.isStopwatching ? "pause" : "start", action: playPause, color: .metricOrange)
            }
            
            Spacer()
        }
        .padding()
        .monospaced()
    }
    
    private func playPause() {
        if ag.stopwatch.isStopwatching {
            ag.stopwatch.pause()
        } else {
            ag.stopwatch.resume()
        }
    }
    
    private func reset() {
        ag.stopwatch.reset()
    }
}

#Preview {
    StopwatchView(gov: Governor(), ag: AlarmGovernor())
}
