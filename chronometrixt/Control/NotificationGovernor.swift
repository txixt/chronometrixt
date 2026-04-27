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

@Observable final class NotificationGovernor {
    private let systemLimit = 64
    private var pendingQueue: [PendingNotification] = []
    private var scheduledIdentifiers: Set<String> = []
    private var audioPlayer: AVAudioPlayer?
    
    var gov: Governor?

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
        eventTime: MetrixtTime,
        eventTitle: String,
        soundFileName: String = "satGnos5"
    ) async throws {
        let gregorianDate = eventTime.toGreg()
        
        try await scheduleNotification(
            id: id,
            type: .event,
            triggerDate: gregorianDate,
            title: "Event: \(eventTitle)",
            body: "Metric time: \(eventTime.hourMinuteSecondTxt)",
            soundFileName: soundFileName
        )
    }
    func scheduleAlarm(
        id: String,
        triggerTime: MetrixtTime,
        soundFileName: String = "alarm_sound"
    ) async throws {
        let gregorianDate = triggerTime.toGreg()
        
        try await scheduleNotification(
            id: id,
            type: .alarm,
            triggerDate: gregorianDate,
            title: "Alarm",
            body: "Metric time: \(triggerTime.hourMinuteSecondTxt)",
            soundFileName: soundFileName
        )
    }
    func scheduleTimer(
        id: String,
        duration: Int, // in metric seconds
        soundFileName: String = "satGnos5"
    ) async throws {
        let gregorianDuration = TimeInterval(duration) * 0.864
        let triggerDate = Date.now.addingTimeInterval(gregorianDuration)
        
        try await scheduleNotification(
            id: id,
            type: .timer,
            triggerDate: triggerDate,
            title: "Timer Complete",
            body: "Timer finished",
            soundFileName: soundFileName
        )
    }
    private func scheduleNotification(
        id: String,
        type: NotificationType,
        triggerDate: Date,
        title: String,
        body: String,
        soundFileName: String = "satGnos5"
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
                soundName: soundFileName
            )
            pendingQueue.append(pending)
            return
        }
        
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.categoryIdentifier = type.rawValue
        content.sound = UNNotificationSound(named: UNNotificationSoundName("\(soundFileName).mp3"))
        
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
    
    func cancelAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        scheduledIdentifiers.removeAll()
        pendingQueue.removeAll()
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
                soundFileName: next.soundName
            )
        }
    }
    
    func handleNotificationResponse(
        response: UNNotificationResponse,
        governor: Governor,
        alarmGovernor: AlarmGovernor
    ) {
        let identifier = response.notification.request.identifier
        let actionIdentifier = response.actionIdentifier
        let category = response.notification.request.content.categoryIdentifier
        
        switch actionIdentifier {
        case "SNOOZE_ACTION":
            handleSnooze(identifier: identifier, category: category)
            
        case "DISMISS_ACTION", UNNotificationDefaultActionIdentifier:
            handleDismiss(identifier: identifier, category: category, governor: governor)
            
        default:
            break
        }
        
        Task {
            await processQueue()
        }
    }
    
    private func handleSnooze(identifier: String, category: String) {
        // TODO: Reschedule notification for 10 metric minutes later
        print("🔔 Snooze requested for: \(identifier)")
    }
    
    private func handleDismiss(identifier: String, category: String, governor: Governor) {
        // TODO: Show alert in app, play sound if app is open
        print("🔕 Dismiss requested for: \(identifier)")
        
        // You can set governor.alert here to show an alert view
        // governor.alert = .error // or create a new alert type for alarms
    }
    
    // MARK: - Sound Playback (for in-app triggers)
    
    /// Play sound when app is in foreground
    func playSound(fileName: String = "satGnos5") {
        guard let soundURL = Bundle.main.url(forResource: fileName, withExtension: "caf") else {
            print("❌ Sound file not found: \(fileName).mp3")
            return
        }
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: soundURL)
            audioPlayer?.numberOfLoops = 3 // Loop 3 times
            audioPlayer?.play()
            print("🔊 Playing sound: \(fileName)")
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
