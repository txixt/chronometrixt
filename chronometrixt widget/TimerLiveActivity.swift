//
//  TimerLiveActivity.swift
//  chronometrixt
//
//  Created by Becket Bowes on 4/26/26.
//

import Foundation
import ActivityKit
import WidgetKit
import SwiftUI

struct TimerLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: TimerActivityAttributes.self) { context in
            TimerLiveActivityView(context: context)
                .activityBackgroundTint(Color.black.opacity(0.3))
                .activitySystemActionForegroundColor(Color.white)
            
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    Label("Timer", systemImage: "timer")
                        .font(.caption)
                }
                
                DynamicIslandExpandedRegion(.trailing) {
                    Text(context.state.countdownFormatted)
                        .font(.title2)
                        .fontWeight(.semibold)
                        .monospacedDigit()
                }
                
                DynamicIslandExpandedRegion(.center) {
                    ProgressView(value: Double(context.state.countdown),
                               total: Double(context.attributes.totalDuration))
                        .tint(.orange)
                }
                
                DynamicIslandExpandedRegion(.bottom) {
                    HStack {
                        if context.state.isPaused {
                            Image(systemName: "pause.circle.fill")
                                .foregroundStyle(.orange)
                        }
                        Spacer()
                        Text("Metric Time")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
                
            } compactLeading: {
                Image(systemName: "timer")
                    .foregroundStyle(.orange)
                
            } compactTrailing: {
                Text(timerText(for: context.state.countdown))
                    .monospacedDigit()
                    .font(.caption2)
                
            } minimal: {
                Image(systemName: "timer")
                    .foregroundStyle(.orange)
            }
        }
    }
    
    func timerText(for countdown: Int) -> String {
        let minutes = (countdown / 100) % 100
        let seconds = countdown % 100
        
        if countdown >= 10_000 {
            // Show hours if > 1 hour
            let hours = (countdown / 10_000) % 10
            return "\(hours):\(String(format: "%02d", minutes))"
        } else {
            // Show minutes:seconds
            return "\(minutes):\(String(format: "%02d", seconds))"
        }
    }
}

struct TimerLiveActivityView: View {
    let context: ActivityViewContext<TimerActivityAttributes>
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Metric Timer")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                Text(context.state.countdownFormatted)
                    .font(.title2)
                    .fontWeight(.bold)
                    .monospacedDigit()
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                if context.state.isPaused {
                    HStack(spacing: 4) {
                        Image(systemName: "pause.fill")
                        Text("Paused")
                    }
                    .font(.caption)
                    .foregroundStyle(.orange)
                }
                
                Text(context.state.endTime, style: .timer)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
    }
}

#Preview("Live Activity", as: .content, using: TimerActivityAttributes(timerID: "preview", totalDuration: 5000)) {
    TimerLiveActivity()
} contentStates: {
    TimerActivityAttributes.ContentState(
        countdown: 5000,
        endTime: Date.now.addingTimeInterval(4320), // 5000 metric seconds
        isPaused: false
    )
    TimerActivityAttributes.ContentState(
        countdown: 2500,
        endTime: Date.now.addingTimeInterval(2160),
        isPaused: false
    )
    TimerActivityAttributes.ContentState(
        countdown: 100,
        endTime: Date.now.addingTimeInterval(86.4),
        isPaused: true
    )
}
