//
//  NotificationResponder.swift
//  chronometrixt
//
//  Created by Becket on 5/11/26.
//

import Foundation
import UserNotifications
import AVFoundation
import UIKit
import SwiftData

@Observable final class NotificationResponder {
    private var gov: Governor
    private var audioPlayer: AVAudioPlayer?
    
    init(gov: Governor) {
        self.gov = gov
    }
    
    func handleNotificationResponse(response: UNNotificationResponse) {
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
            await NotificationAgent.shared.processQueue()
        }
    }
    
    func handleSnooze(id: String, dataId: String, category: String) {
        Task {
            try? await NotificationAgent.shared.scheduleAlarm(
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
        guard let notificationType = NotificationAgent.NotificationType(rawValue: category) else { return }
        
        switch notificationType {
        case .event: handleEventNotification(alarmId: id, dataId: dataId, eventId: eventId!)
        case .alarm: handleAlarmNotification(id: id)
        case .timer: handleTimerNotification(id: id)
        }
        playSound()
        triggerHaptic()
    }
    
    private func handleEventNotification(alarmId: String, dataId: String, eventId: String) {
        if let alarm = gov.alarmData.first(where: { $0.id == dataId }) {
            gov.context.delete(alarm)
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
        print("alarm notification received")
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
