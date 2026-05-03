//
//  BackgroundActivityManager.swift
//  chronometrixt
//
//  Created by Becket Bowes on 5/1/26.
//

import Foundation
import SwiftData

@Observable final class BackgroundActivityManager {
    var ng: NotificationComptroller?
    var context: ModelContext?
    private var materializationTimer: Timer?
    
    init() {
        startMaterializationTimer()
    }
    
    private func startMaterializationTimer() {
        // Run every 24 hours (86,400 Gregorian seconds)
        materializationTimer = Timer.scheduledTimer(
            withTimeInterval: 86400,
            repeats: true
        ) { [weak self] _ in
            self?.checkAndMaterializeRecurrences()
        }
    }
    
    func checkAndMaterializeRecurrences() {
        guard let context else { return }
        
        Task {
            let parentPredicate = #Predicate<MetricEvent> { event in
                event.recurrenceRule != "NONE" && event.recurringParentId == "NONE"
            }
            let descriptor = FetchDescriptor<MetricEvent>(predicate: parentPredicate)
            guard let parents = try? context.fetch(descriptor) else { return }
            
            for parent in parents {
                try? EventHandler.extendRecurrences(
                    for: parent,
                    context: context,
                    lookAheadYears: 2  // Always keep 2 years ahead
                )
            }
            
            print("✅ Materialized future recurrences")
        }
    }
    
    func processNotificationQueue() {
        Task {
            await ng?.processQueue()
        }
    }

    func cleanupPastEvents(olderThan days: Int = 365) {
        guard let context else { return }
        
        Task {
            let cutoffDate = Date.now.addingTimeInterval(-TimeInterval(days * 86400))
            
            let pastPredicate = #Predicate<MetricEvent> { event in
                event.utcEnd < cutoffDate
            }
            
            let descriptor = FetchDescriptor<MetricEvent>(predicate: pastPredicate)
            
            if let oldEvents = try? context.fetch(descriptor) {
                for event in oldEvents {
                    context.delete(event)
                }
                print("🗑️ Cleaned up \(oldEvents.count) past events")
            }
        }
    }
    
    deinit {
        materializationTimer?.invalidate()
    }
}
