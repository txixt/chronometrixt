//
//  LiveActivityManager.swift
//  chronometrixt
//
//  Created by Becket Bowes on 4/26/26.
//

import Foundation
import ActivityKit
import SwiftUI

@Observable final class LiveActivityManager {
    private var activeActivities: [String: Activity<TimerActivityAttributes>] = [:]
    
    func startTimerActivity(
        timerID: String,
        duration: Int, // in metric seconds
        endTime: Date
    ) async {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else {
            print("⚠️ Live Activities not enabled")
            return
        }
        
        let initialState = TimerActivityAttributes.ContentState(
            countdown: duration,
            endTime: endTime,
            isPaused: false
        )
        
        let attributes = TimerActivityAttributes(
            timerID: timerID,
            totalDuration: duration
        )
        
        do {
            let activity = try Activity.request(
                attributes: attributes,
                content: .init(state: initialState, staleDate: endTime),
                pushType: nil
            )
            
            activeActivities[timerID] = activity
            print("✅ Started Live Activity for timer: \(timerID)")
            
            Task {
                await updateTimerActivity(timerID: timerID, endTime: endTime)
            }
            
        } catch {
            print("❌ Error starting Live Activity: \(error)")
        }
    }

    private func updateTimerActivity(timerID: String, endTime: Date) async {
        guard let activity = activeActivities[timerID] else { return }
        
        while Date.now < endTime {
            let remaining = Int(endTime.timeIntervalSinceNow / 0.864) // Convert to metric seconds
            
            let newState = TimerActivityAttributes.ContentState(
                countdown: max(0, remaining),
                endTime: endTime,
                isPaused: false
            )
            
            await activity.update(.init(state: newState, staleDate: endTime))
            
            try? await Task.sleep(nanoseconds: 864_000_000) // 0.864 seconds in nanoseconds
        }
        
        await endTimerActivity(timerID: timerID)
    }
    
    func pauseTimerActivity(timerID: String) async {
        guard let activity = activeActivities[timerID] else { return }
        
        var currentState = activity.content.state
        currentState.isPaused = true
        
        await activity.update(.init(state: currentState, staleDate: nil))
        print("⏸️ Paused Live Activity: \(timerID)")
    }
    
    func resumeTimerActivity(timerID: String, endTime: Date) async {
        guard let activity = activeActivities[timerID] else { return }
        
        var currentState = activity.content.state
        currentState.isPaused = false
        currentState.endTime = endTime
        
        await activity.update(.init(state: currentState, staleDate: endTime))
        print("▶️ Resumed Live Activity: \(timerID)")
        
        // Restart update loop
        Task {
            await updateTimerActivity(timerID: timerID, endTime: endTime)
        }
    }
    
    func endTimerActivity(timerID: String) async {
        guard let activity = activeActivities[timerID] else { return }
        
        let finalState = TimerActivityAttributes.ContentState(
            countdown: 0,
            endTime: Date.now,
            isPaused: false
        )
        
        await activity.end(
            .init(state: finalState, staleDate: nil),
            dismissalPolicy: .default
        )
        
        activeActivities.removeValue(forKey: timerID)
    }
    
    /// Cancel all active timer activities
    func cancelAllActivities() async {
        for (timerID, _) in activeActivities {
            await endTimerActivity(timerID: timerID)
        }
    }
}

// MARK: - Activity Attributes

/// Attributes for timer Live Activity
struct TimerActivityAttributes: ActivityAttributes {
    /// Static data that doesn't change
    let timerID: String
    let totalDuration: Int // in metric seconds
    
    /// Dynamic state that updates
    struct ContentState: Codable, Hashable {
        var countdown: Int       // Remaining metric seconds
        var endTime: Date        // When timer completes
        var isPaused: Bool
        
        // Computed properties for display
        var countdownFormatted: String {
            let h = (countdown / 10_000) % 10
            let m = (countdown / 100) % 100
            let s = countdown % 100
            return String(format: "%d:%02d:%02d", h, m, s)
        }
        
        var progressPercentage: Double {
            // Calculate based on total duration if available
            return 0.5 // Placeholder
        }
    }
}
