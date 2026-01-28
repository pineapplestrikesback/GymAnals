//
//  RestTimerNotificationService.swift
//  GymAnals
//
//  Created on 28/01/2026.
//

import Foundation
import UserNotifications

/// Handles local notification scheduling for rest timer completion.
/// Notifications alert users when their rest period ends, even if app is backgrounded.
@MainActor
final class RestTimerNotificationService {
    static let shared = RestTimerNotificationService()

    private init() {}

    /// Request notification authorization from the user
    /// - Returns: Whether authorization was granted
    func requestPermission() async -> Bool {
        let center = UNUserNotificationCenter.current()
        do {
            return try await center.requestAuthorization(options: [.alert, .sound, .badge])
        } catch {
            print("Notification permission error: \(error)")
            return false
        }
    }

    /// Schedule a notification to fire after a specified interval
    /// - Parameters:
    ///   - id: Unique identifier for cancellation
    ///   - seconds: Delay before notification fires
    func scheduleRestTimerNotification(id: String, after seconds: TimeInterval) {
        guard seconds > 0 else { return }

        let content = UNMutableNotificationContent()
        content.title = "Rest Complete"
        content.body = "Time to start your next set!"
        content.sound = .default
        content.interruptionLevel = .timeSensitive

        let trigger = UNTimeIntervalNotificationTrigger(
            timeInterval: seconds,
            repeats: false
        )

        let request = UNNotificationRequest(
            identifier: id,
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Failed to schedule notification: \(error)")
            }
        }
    }

    /// Cancel a specific pending notification
    /// - Parameter id: The identifier of the notification to cancel
    func cancelNotification(id: String) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(
            withIdentifiers: [id]
        )
    }

    /// Cancel all pending rest timer notifications
    func cancelAllRestTimerNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
}
