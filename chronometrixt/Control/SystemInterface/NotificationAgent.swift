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

@Observable final class NotificationAgent {
    static let shared = NotificationAgent()
    private let systemLimit = 64
    private var pendingQueue: [PendingNotification] = []
    private var scheduledIdentifiers: Set<String> = []
    private var audioPlayer: AVAudioPlayer?

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
        let adjustedTT = triggerTime.toGreg()
        print("🚨 Scheduling alarm for: \(adjustedTT)")
        print("Time until trigger: \(adjustedTT.timeIntervalSinceNow) seconds")
        print("triggerTime.fromUTC: \(metric.cal.fromUTC(time: triggerTime).toGreg().description)")
        print("id: \(id)")
        print("dataId: \(dataId)")
        try await scheduleNotification(
            id: id,
            dataId: dataId,
            eventId: nil,
            type: .alarm,
            triggerDate: triggerTime.toGreg(),
            title: "Alarm",
            body: "Metric time: \(triggerTime.hourMinuteSecondTxt)"
        )
        await debugPendingNotifications()
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
        
        // DEBUG: Print what we're actually scheduling
//        print("📅 Extracted components:")
//        print("   Year: \(components.year ?? 0)")
//        print("   Month: \(components.month ?? 0)")
//        print("   Day: \(components.day ?? 0)")
//        print("   Hour: \(components.hour ?? 0)")
//        print("   Minute: \(components.minute ?? 0)")
//        print("   Second: \(components.second ?? 0)")
//        print("   Calendar timezone: \(Calendar.current.timeZone.identifier)")
        
        try await UNUserNotificationCenter.current().add(request)
        scheduledIdentifiers.insert(id)
//        print("✅ Scheduled notification: \(id) for \(triggerDate)")
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
    
    func debugPendingNotifications() async {
        let pending = await UNUserNotificationCenter.current().pendingNotificationRequests()
        print("📋 Total pending notifications: \(pending.count)")
        
        for request in pending {
            print("\n   Notification ID: \(request.identifier)")
            print("   Title: \(request.content.title)")
            print("   Category: \(request.content.categoryIdentifier)")
            
            if let calendarTrigger = request.trigger as? UNCalendarNotificationTrigger {
                print("   Trigger components: \(calendarTrigger.dateComponents)")
                if let nextDate = calendarTrigger.nextTriggerDate() {
                    print("   Next trigger: \(nextDate)")
                    print("   Time until: \(nextDate.timeIntervalSinceNow) seconds")
                } else {
                    print("   ⚠️ nextTriggerDate() returned nil!")
                }
            }
        }
    }
}
