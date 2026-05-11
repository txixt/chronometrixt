//
//  TimerActivityAttributes.swift
//  chronometrixt
//
//  Created by Becket Bowes on 4/28/26.
//

import Foundation
import DeviceActivity
import ActivityKit

/// Attributes for timer Live Activity
#if os(iOS)
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
#endif
