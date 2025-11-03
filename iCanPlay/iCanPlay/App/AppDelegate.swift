//
//  AppDelegate.swift
//  iCanPlay
//
//  Created by Cynthia Wang on 10/25/25.
//


import UIKit
import FirebaseCore
import FirebaseMessaging
import FirebaseAuth
import UserNotifications

final class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        FirebaseApp.configure()
        UNUserNotificationCenter.current().delegate = self
        Messaging.messaging().delegate = self

        // Quick auth for dev: anonymous sign-in to have a uid
        Task {
            await AuthViewModel.shared.signInAnonymouslyIfNeeded()
        }
        return true
    }

    // MARK: - APNs registration
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        // Set APNs token for Firebase Messaging
        Messaging.messaging().apnsToken = deviceToken
        // Optionally convert deviceToken to string for debugging
        let tokenString = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        print("APNs device token: \(tokenString)")
    }

    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register for remote notifications: \(error)")
    }
}

// MARK: - UNUserNotificationCenterDelegate
extension AppDelegate: UNUserNotificationCenterDelegate {
    // App is in foreground - decide how to show
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler:
                                @escaping (UNNotificationPresentationOptions) -> Void) {
        // Show banner + sound while app is foreground
        completionHandler([.banner, .sound])
    }

    // User tapped the notification
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        // Route to a match detail if matchId present
        if let matchId = userInfo["matchId"] as? String {
            // Post notification or use other app routing method to open match
            NotificationCenter.default.post(name: .openMatch, object: nil, userInfo: ["matchId": matchId])
        }
        completionHandler()
    }
}

// MARK: - MessagingDelegate
extension AppDelegate: MessagingDelegate {
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        guard let token = fcmToken else { return }
        print("FCM token: \(token)")
        Task {
            await FirestoreService.shared.saveFCMToken(token)
        }
    }
}

// MARK: - Helper notifications
extension Notification.Name {
    static let openMatch = Notification.Name("OpenMatchNotification")
}