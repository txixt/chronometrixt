//
//  AppDelegate.swift
//  chronometrixt
//
//  Created by Becket Bowes on 4/26/26.
//

import Foundation
import UIKit
import UserNotifications

@Observable class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
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
        print("notification received")
        if gov != nil { print("got gov") } else { print("no gov") }
        gov?.nr.handleNotification(notification: notification) ?? print("no gov")
        completionHandler([])
    }
    
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        print("notification response received")
        gov?.nr.handleNotificationResponse(response: response) ?? print("no gov")
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
