//
//  StopWatchView.swift
//  chronometrixt
//
//  Created by Becket Bowes on 4/15/26.
//

import SwiftUI
import SwiftData

struct StopwatchView: View {
    @Environment(\.modelContext) private var context
    @Query var data: [MetricAlarm]
    @Bindable var gov: Governor
    @Bindable var ag: AlarmGovernor
    
    var body: some View {
        if let stopwatch = ag.stopwatch {
            VStack {
                
                Spacer()
                
                HStack {
                    TimelineView(.animation(minimumInterval: 0.01, paused: !stopwatch.isStopwatching)) { timeline in
                        let baseSeconds = stopwatch.metricSeconds
                        
                        // Fake smooth microsecond animation - cycles 00-99
                        let animatedMicroseconds = stopwatch.isStopwatching
                            ? Int(timeline.date.timeIntervalSince1970 * 100) % 100
                            : baseSeconds % 100
                        
                        let hour: Int = baseSeconds / 10_000
                        let min: Int = (baseSeconds / 100) % 100
                        let sec: Int = baseSeconds % 100
                        let timeString: String = String(format: "%d:%02d:%02d.%02d", hour, min, sec, animatedMicroseconds)
                        
                        Text(timeString)
                            .font(.system(size: 50))
                            .contentTransition(.numericText())
                    }
                }
                .padding(.bottom)
                
                HStack {
                    let gregSecs = Int(Double(stopwatch.metricSeconds) * 0.864)
                    let hours = gregSecs / 3600
                    let minutes = (gregSecs / 60) % 60
                    let seconds = gregSecs % 60
                    let timeString = String(format: "%d:%02d:%02d", hours, minutes, seconds)
                    
                    Text("gregorian: " + timeString)
                }
                
                Spacer()
            
                HStack {
                    SmallTimeButtonView(imageString: "restart", text: "reset", action: reset, color: .gray)
                
                    Spacer()
                    
                    SmallTimeButtonView(imageString: stopwatch.isStopwatching ? "pause" : "play", text: stopwatch.isStopwatching ? "pause" : "start", action: playPause, color: .metricOrange)
                }
                
                Spacer()
            }
            .padding()
            .monospaced()
        }

    }
    
    private func playPause() {
        ag.toggleStopwatch(data: data, context: context)
    }
    
    private func reset() {
        ag.resetStopwatch(data: data, context: context)
    }
}

#Preview {
    StopwatchView(gov: Governor(), ag: AlarmGovernor())
}
