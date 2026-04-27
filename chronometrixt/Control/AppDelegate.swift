//
//  AppDelegate.swift
//  chronometrixt
//
//  Created by Becket Bowes on 4/26/26.
//

import Foundation
import UIKit
import UserNotifications

class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    var governor: Governor?
    var eventGovernor: EventGovernor?
    var alarmGovernor: AlarmGovernor?
    var notificationGovernor: NotificationGovernor?
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
    ) -> Bool {
        UNUserNotificationCenter.current().delegate = self
        return true
    }
    
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .sound])
        notificationGovernor?.playSound()
        notificationGovernor?.triggerHaptic()
    }
    
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        guard let gov = governor,
              let ag = alarmGovernor,
              let ng = notificationGovernor
        else {
            completionHandler()
            return
        }
        
        ng.handleNotificationResponse(
            response: response,
            governor: gov,
            alarmGovernor: ag
        )
        
        completionHandler()
    }
}
