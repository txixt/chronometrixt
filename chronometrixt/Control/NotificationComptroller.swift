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
        let dataId: String
        let eventId: String?
        let type: NotificationType
        let triggerDate: Date
        let title: String
        let body: String
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
        dataId: String,
        eventId: String,
        eventTime: MetrixtTime,
        eventTitle: String,
        soundFileName: String = "satGnos5"
    ) async throws {
        try await scheduleNotification(
            id: id,
            dataId: dataId,
            eventId: eventId,
            type: .event,
            triggerDate: eventTime.toGreg(),
            title: "\(eventTitle)",
            body: "metric time: \(eventTime.hourMinuteSecondTxt)"
        )
    }
    
    func scheduleAlarm(
        id: String,
        dataId: String,
        triggerTime: MetrixtTime,
    ) async throws {
        try await scheduleNotification(
            id: id,
            dataId: dataId,
            eventId: nil,
            type: .alarm,
            triggerDate: triggerTime.toGreg(),
            title: "Alarm",
            body: "Metric time: \(triggerTime.hourMinuteSecondTxt)"
        )
    }
    
    func scheduleTimer(
        id: String,
        dataId: String,
        duration: Int,
    ) async throws {
        try await scheduleNotification(
            id: id,
            dataId: dataId,
            eventId: nil,
            type: .timer,
            triggerDate: Date.now.addingTimeInterval(TimeInterval(duration) * 0.864),
            title: "Timer Complete",
            body: "Timer finished"
        )
    }
    
    private func scheduleNotification(
        id: String,
        dataId: String,
        eventId: String?,
        type: NotificationType,
        triggerDate: Date,
        title: String,
        body: String
    ) async throws {
        let pendingNotifications = await UNUserNotificationCenter.current()
            .pendingNotificationRequests()
        
        if pendingNotifications.count >= systemLimit {
            let pending = PendingNotification(
                id: id,
                dataId: dataId,
                eventId: eventId,
                type: type,
                triggerDate: triggerDate,
                title: title,
                body: body
            )
            pendingQueue.append(pending)
            return
        }
        
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.categoryIdentifier = type.rawValue
        content.sound = UNNotificationSound(named: UNNotificationSoundName("satGnos5.mp3"))
        content.userInfo = [
            "notificationType": type.rawValue,
            "notificationID": id,
            "dataID": dataId,
            "eventID": eventId ?? "NONE",
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
        pendingQueue.sort { $0.triggerDate < $1.triggerDate }
        
        if let next = pendingQueue.first {
            pendingQueue.removeFirst()
            try? await scheduleNotification(
                id: next.id,
                dataId: next.dataId,
                eventId: next.eventId,
                type: next.type,
                triggerDate: next.triggerDate,
                title: next.title,
                body: next.body
            )
        }
    }
    
    func handleNotificationResponse(response: UNNotificationResponse) {
        guard let gov else { print("handleNotificationResponse has no gov"); return }
        let id = response.notification.request.identifier
        let dataId = response.notification.request.identifier
        let eventId = response.notification.request.identifier
        let actionIdentifier = response.actionIdentifier
        let category = response.notification.request.content.categoryIdentifier
        let userInfo = response.notification.request.content.userInfo
        let triggerTime = userInfo["triggerTime"] as? String ?? ""
        
        switch actionIdentifier {
        case "SNOOZE_ACTION": 
            handleSnooze(id: id, dataId: dataId, category: category)
            
        case "DISMISS_ACTION", UNNotificationDefaultActionIdentifier:
            handleDismiss(
                id: id,
                dataId: dataId,
                eventId: eventId == "NONE" ? nil : eventId,
                category: category,
                gov: gov,
                triggerTime: triggerTime
            )
            
        default:
            break
        }
        
        Task {
            await processQueue()
        }
    }
    
    func handleSnooze(id: String, dataId: String, category: String) {
        Task {
            try? await scheduleAlarm(
                id: id,
                dataId: dataId,
                triggerTime: metric.cal.update(time: MetrixtTime(date: nil), component: .minute, byAdding: 5)
            )
        }
    }
    
    private func handleDismiss(
        id: String,
        dataId: String,
        eventId: String?,
        category: String,
        gov: Governor,
        triggerTime: String
    ) {
        guard let notificationType = NotificationType(rawValue: category) else { return }
        
        switch notificationType {
        case .event: handleEventNotification(alarmId: id, dataId: dataId, eventId: eventId!)
        case .alarm: handleAlarmNotification(id: id)
        case .timer: handleTimerNotification(id: id)
        }
        playSound()
        triggerHaptic()
    }
    
    private func handleEventNotification(alarmId: String, dataId: String, eventId: String) {
        guard let gov, let context = gov.context else {
            print("gov context or event id not handled correctly at ~334 in NotificationComptroller")
            return
        }
        
        if let alarm = gov.alarmData.first(where: { $0.id == dataId }) {
            context.delete(alarm)
        } else {
            print("handleEventNotification error deleting alarm")
        }
        
        if let event = gov.eventData.first(where: { $0.id == eventId }) {
            gov.event = event
            gov.alertTxt = event.title
            gov.alert = .event
        } else {
            print("handleEventNotification error calling event")
        }
    }
    
    private func handleAlarmNotification(id: String) {
        guard let gov else { print("error at handleAlarmNotification in NotificationComptroller"); return }
        if let thisAlarmData = gov.alarmData.first(where: { $0.id == id }) {
            let seconds = thisAlarmData.metricSeconds % 100_000
            let hour = (seconds / 10_000) % 10
            let minute = (seconds / 100) % 100
            let second = seconds % 100
            gov.alertTxt = String(format: "%01d:%02d:%02d", hour, minute, second)
            gov.alert = .alarm
            gov.ac.dismissAlarm(id: id)
        } else {
            print("data retieval error in handleAlarmNotification in NotificationComptroller")
        }
    }
    
    private func handleTimerNotification(id: String) {
        guard let gov else { print("error at handleTimerNotification in NotificationComptroller"); return }
        if let thisTimerData = gov.alarmData.first(where: { $0.id == id }) {
            let seconds = thisTimerData.metricSeconds % 100_000
            let hour = (seconds / 10_000) % 10
            let minute = (seconds / 100) % 100
            let second = seconds % 100
            gov.alertTxt = String(format: "%01d:%02d:%02d", hour, minute, second)
            gov.alert = .timer
            gov.ac.retireTimer(id: id)
        } else {
            print("data retrieval error in handleTimerNotification in NotificationComptroller")
        }

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
