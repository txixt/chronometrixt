//
//  NotificationGovernor.swift
//  chronometrixt
//
//  Created by Becket Bowes on 4/26/26.
//

import Foundation
import UserNotifications
import AVFoundation
import UIKit
import SwiftData

@Observable final class NotificationComptroller {
    private let systemLimit = 64
    private var pendingQueue: [PendingNotification] = []
    private var scheduledIdentifiers: Set<String> = []
    private var audioPlayer: AVAudioPlayer?
    
    var gov: Governor?
    var context: ModelContext?

    enum NotificationType: String {
        case event = "EVENT_ALARM"
        case alarm = "ALARM_ALARM"
        case timer = "TIMER_ALARM"
    }
    
    struct PendingNotification: Identifiable {
        let id: String
        let type: NotificationType
        let triggerDate: Date
        let title: String
        let body: String
        let soundName: String
        let eventID: String? 
    }
    
    init() {
        setupNotificationCategories()
    }
    private func setupNotificationCategories() {
        let snoozeAction = UNNotificationAction(
            identifier: "SNOOZE_ACTION",
            title: "Snooze",
            options: []
        )
        let dismissAction = UNNotificationAction(
            identifier: "DISMISS_ACTION",
            title: "Dismiss",
            options: [.destructive]
        )
        let alarmCategory = UNNotificationCategory(
            identifier: NotificationType.alarm.rawValue,
            actions: [snoozeAction, dismissAction],
            intentIdentifiers: [],
            options: [.customDismissAction]
        )
        let timerCategory = UNNotificationCategory(
            identifier: NotificationType.timer.rawValue,
            actions: [dismissAction],
            intentIdentifiers: [],
            options: [.customDismissAction]
        )
        let eventCategory = UNNotificationCategory(
            identifier: NotificationType.event.rawValue,
            actions: [dismissAction],
            intentIdentifiers: [],
            options: [.customDismissAction]
        )
        
        UNUserNotificationCenter.current().setNotificationCategories([
            alarmCategory,
            timerCategory,
            eventCategory
        ])
    }
    
    func requestAuthorization() async -> Bool {
        do {
            let granted = try await UNUserNotificationCenter.current()
                .requestAuthorization(options: [.alert, .sound, .badge])
            return granted
        } catch {
            return false
        }
    }
    func checkAuthorizationStatus() async -> UNAuthorizationStatus {
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        return settings.authorizationStatus
    }
    
    func scheduleEvent(
        id: String,
        eventID: String,  // Full event ID for lookup later
        eventTime: MetrixtTime,
        eventTitle: String,
        soundFileName: String = "satGnos5"
    ) async throws {
        try await scheduleNotification(
            id: id,
            type: .event,
            triggerDate: eventTime.toGreg(),
            title: "\(eventTitle)",
            body: "metric time: \(eventTime.hourMinuteSecondTxt)",
            soundFileName: soundFileName,
            eventID: eventID
        )
    }
    
    func scheduleAlarm(
        id: String,
        triggerTime: MetrixtTime,
        soundFileName: String = "alarm_sound"
    ) async throws {
        try await scheduleNotification(
            id: id,
            type: .alarm,
            triggerDate: triggerTime.toGreg(),
            title: "Alarm",
            body: "Metric time: \(triggerTime.hourMinuteSecondTxt)",
            soundFileName: soundFileName,
            eventID: nil
        )
    }
    
    func scheduleTimer(
        id: String,
        duration: Int, // in metric seconds
        soundFileName: String = "satGnos5"
    ) async throws {
        try await scheduleNotification(
            id: id,
            type: .timer,
            triggerDate: Date.now.addingTimeInterval(TimeInterval(duration) * 0.864),
            title: "Timer Complete",
            body: "Timer finished",
            soundFileName: soundFileName,
            eventID: nil
        )
    }
    
    private func scheduleNotification(
        id: String,
        type: NotificationType,
        triggerDate: Date,
        title: String,
        body: String,
        soundFileName: String = "satGnos5",
        eventID: String? = nil  // Optional event ID for lookups
    ) async throws {
        let pendingNotifications = await UNUserNotificationCenter.current()
            .pendingNotificationRequests()
        
        if pendingNotifications.count >= systemLimit {
            let pending = PendingNotification(
                id: id,
                type: type,
                triggerDate: triggerDate,
                title: title,
                body: body,
                soundName: soundFileName,
                eventID: eventID
            )
            pendingQueue.append(pending)
            return
        }
        
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.categoryIdentifier = type.rawValue
        content.sound = UNNotificationSound(named: UNNotificationSoundName("\(soundFileName).mp3"))
        
        // Store metadata in userInfo for later retrieval
        content.userInfo = [
            "notificationType": type.rawValue,
            "notificationID": id,
            "eventID": eventID ?? "",
            "triggerTime": body  // Store the metric time string
        ]
        
        let components = Calendar.current.dateComponents(
            [.year, .month, .day, .hour, .minute, .second],
            from: triggerDate
        )
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        let request = UNNotificationRequest(
            identifier: id,
            content: content,
            trigger: trigger
        )
        
        try await UNUserNotificationCenter.current().add(request)
        scheduledIdentifiers.insert(id)
        print("✅ Scheduled notification: \(id) for \(triggerDate)")
    }
    
    func cancelNotification(id: String) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [id])
        scheduledIdentifiers.remove(id)
        pendingQueue.removeAll { $0.id == id }
        print("❌ Cancelled notification: \(id)")
    }
    
    func cancelAllNotifications(ofType type: NotificationType) async {
        let pending = await UNUserNotificationCenter.current().pendingNotificationRequests()
        let idsToCancel = pending
            .filter { $0.content.categoryIdentifier == type.rawValue }
            .map { $0.identifier }
        
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: idsToCancel)
        idsToCancel.forEach { scheduledIdentifiers.remove($0) }
        pendingQueue.removeAll { $0.type == type }
        print("❌ Cancelled all \(type.rawValue) notifications")
    }
    
    func clearBadgeAndDelivered() {
        let center = UNUserNotificationCenter.current()
        center.removeAllDeliveredNotifications()
        
        Task { @MainActor in
            UNUserNotificationCenter.current().setBadgeCount(0)
            print("cleared")
        }
    }
    
    func cancelAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        scheduledIdentifiers.removeAll()
        pendingQueue.removeAll()
        
        Task { @MainActor in
            UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
            UNUserNotificationCenter.current().setBadgeCount(0)
        }
        print("❌ Cancelled all notifications")
    }
    
    func processQueue() async {
        guard !pendingQueue.isEmpty else { return }
        
        let pending = await UNUserNotificationCenter.current().pendingNotificationRequests()
        guard pending.count < systemLimit else { return }
        
        // Sort queue by trigger date (earliest first)
        pendingQueue.sort { $0.triggerDate < $1.triggerDate }
        
        // Schedule the next one
        if let next = pendingQueue.first {
            pendingQueue.removeFirst()
            
            try? await scheduleNotification(
                id: next.id,
                type: next.type,
                triggerDate: next.triggerDate,
                title: next.title,
                body: next.body,
                soundFileName: next.soundName,
                eventID: next.eventID
            )
        }
    }
    
    func handleNotificationResponse(
        response: UNNotificationResponse,
        governor: Governor
    ) {
        let identifier = response.notification.request.identifier
        let actionIdentifier = response.actionIdentifier
        let category = response.notification.request.content.categoryIdentifier
        let userInfo = response.notification.request.content.userInfo
        let eventID = userInfo["eventID"] as? String ?? ""
        let triggerTime = userInfo["triggerTime"] as? String ?? ""
        
        switch actionIdentifier {
        case "SNOOZE_ACTION": 
            handleSnooze(identifier: identifier, category: category) 
            
        case "DISMISS_ACTION", UNNotificationDefaultActionIdentifier:
            handleDismiss(
                identifier: identifier,
                category: category,
                governor: governor,
                eventID: eventID,
                triggerTime: triggerTime
            )
            
        default:
            break
        }
        
        Task {
            await processQueue()
        }
    }
    
    func handleSnooze(identifier: String, category: String) {
        Task {
            try? await scheduleAlarm(
                id: identifier, 
                triggerTime: metric.cal.update(
                    time: MetrixtTime(date: nil), 
                    component: .minute, 
                    byAdding: 5
                )
            )
        }
    }
    
    private func handleDismiss(
        identifier: String,
        category: String,
        governor: Governor,
        eventID: String,
        triggerTime: String
    ) {
        guard let notificationType = NotificationType(rawValue: category) else { return }
        
        Task { @MainActor in
            switch notificationType {
            case .event: handleEventNotification(eventID: eventID, governor: governor)
            case .alarm: handleAlarmNotification(triggerTime: triggerTime, gov: governor, id: identifier)
            case .timer: handleTimerNotification(gov: governor, id: identifier)
            }

            playSound()
            triggerHaptic()
        }
    }
    
    private func handleEventNotification(eventID: String, governor: Governor) {
        guard let context = context, !eventID.isEmpty else {
            governor.alertTxt = ""
            governor.alert = .event
            return
        }
        
        let descriptor = FetchDescriptor<MetricEvent>(
            predicate: #Predicate { event in
                event.id == eventID
            }
        )
        
        do {
            let events = try context.fetch(descriptor)
            if let event = events.first {
                governor.event = event
                governor.alertTxt = event.title
                governor.alert = .event
            } else {
                // Event not found (might have been deleted)
                governor.alertTxt = "Event Debug: Event Missing"
                governor.alert = .event
            }
        } catch {
            print("❌ Error fetching event: \(error)")
            governor.alertTxt = "Event notification"
            governor.alert = .event
        }
    }
    
    private func handleAlarmNotification(
        triggerTime: String,
        gov: Governor,
        id: String
    ) {
        gov.alertTxt = triggerTime
        gov.alert = .alarm
    
    }
    
    private func handleTimerNotification(gov: Governor, id: String) {
        playSound()

        gov.alertTxt = "Timer complete"
        gov.alert = .timer
        
    }
    
    func playSound(fileName: String = "satGnos5") {
        guard let soundURL = Bundle.main.url(forResource: fileName, withExtension: "caf") else {
            print("❌ Sound file not found: \(fileName).mp3")
            return
        }
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: soundURL)
            audioPlayer?.numberOfLoops = 3 // Loop 3 times
            audioPlayer?.play()
        } catch {
            print("❌ Error playing sound: \(error)")
        }
    }
    
    func stopSound() {
        audioPlayer?.stop()
        audioPlayer = nil
    }
    
    func triggerHaptic(style: UINotificationFeedbackGenerator.FeedbackType = .warning) {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(style)
    }
}
