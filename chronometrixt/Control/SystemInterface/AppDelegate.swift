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
    var gov: Governor?
    
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
        guard let gov = gov else {
            print("⚠️ AppDelegate.gov is nil in willPresent")
            completionHandler([])
            return
        }
        gov.nr.handleNotification(notification: notification)
        completionHandler([])

    }
    
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        guard let gov = gov else {
            print("⚠️ AppDelegate.gov is nil in didReceive")
            completionHandler()
            return
        }
        gov.nr.handleNotificationResponse(response: response)
        completionHandler()
    }
}


//        print("🔔 Notification received in FOREGROUND: \(notification.request.identifier)")
//        completionHandler([.banner, .sound])
//        gov?.nr.playSound()
//        gov?.nr.triggerHaptic()

//        print("Received notification response: \(response)")
//        DispatchQueue.main.async {
//            self.gov?.nr.handleNotificationResponse(response: response)
//            completionHandler()
//        }
