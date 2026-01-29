//
//  SetTimerManager.swift
//  GymAnals
//
//  Created on 28/01/2026.
//

import Foundation

/// Manages multiple independent per-set rest timers.
/// Only the header timer (most recent) triggers notifications.
@Observable
@MainActor
final class SetTimerManager {
    /// All active timers, one per completed set
    var activeTimers: [SetTimer] = []

    private let notificationService: RestTimerNotificationService
    private var hasRequestedNotificationPermission = false

    /// The most recently started timer (highest endTime), shown in header and triggers notification
    var headerTimer: SetTimer? {
        activeTimers.max(by: { $0.endTime < $1.endTime })
    }

    init(notificationService: RestTimerNotificationService = .shared) {
        self.notificationService = notificationService
    }

    /// Start a new timer for a completed set
    /// - Parameters:
    ///   - setID: The UUID of the WorkoutSet that was just completed
    ///   - duration: Rest duration in seconds
    func startTimer(for setID: UUID, duration: TimeInterval) {
        let timer = SetTimer(
            id: UUID(),
            setID: setID,
            duration: duration
        )
        activeTimers.append(timer)

        // Schedule notification only if this is the new header timer
        if timer.id == headerTimer?.id {
            requestPermissionAndScheduleNotification()
        }
    }

    /// Request notification permission on first timer, then schedule notification
    private func requestPermissionAndScheduleNotification() {
        if !hasRequestedNotificationPermission {
            Task {
                let granted = await notificationService.requestPermission()
                hasRequestedNotificationPermission = true
                if granted {
                    scheduleNotificationForHeaderTimer()
                }
            }
        } else {
            scheduleNotificationForHeaderTimer()
        }
    }

    /// Remove all expired timers from the active list
    func removeExpiredTimers() {
        activeTimers.removeAll { $0.isExpired }
    }

    /// Skip/dismiss a specific timer
    /// - Parameter timer: The timer to remove
    func skipTimer(_ timer: SetTimer) {
        let wasHeaderTimer = timer.id == headerTimer?.id
        activeTimers.removeAll { $0.id == timer.id }

        // If we removed the header timer, cancel its notification and schedule for new header
        if wasHeaderTimer {
            notificationService.cancelNotification(id: timer.id.uuidString)
            scheduleNotificationForHeaderTimer()
        }
    }

    /// Remove timer associated with a specific workout set (used when unconfirming a set)
    /// - Parameter setID: The UUID of the WorkoutSet whose timer should be removed
    func removeTimer(forSetID setID: UUID) {
        guard let timer = activeTimers.first(where: { $0.setID == setID }) else { return }
        skipTimer(timer)
    }

    /// Extend a timer by adding additional seconds
    /// - Parameters:
    ///   - timer: The timer to extend
    ///   - seconds: Additional seconds to add
    func extendTimer(_ timer: SetTimer, by seconds: TimeInterval) {
        guard let index = activeTimers.firstIndex(where: { $0.id == timer.id }) else { return }

        let wasHeaderTimer = timer.id == headerTimer?.id
        let extendedTimer = timer.extended(by: seconds)
        activeTimers[index] = extendedTimer

        // If this was the header timer, reschedule notification
        if wasHeaderTimer {
            notificationService.cancelNotification(id: timer.id.uuidString)
            scheduleNotificationForHeaderTimer()
        }
    }

    /// Update a timer to a specific remaining seconds value
    /// - Parameters:
    ///   - timer: The timer to update
    ///   - remainingSeconds: New remaining seconds value
    /// - Returns: false if the timer was skipped or not found
    func updateTimer(_ timer: SetTimer, remainingSeconds: Int) -> Bool {
        guard remainingSeconds > 0 else {
            skipTimer(timer)
            return false
        }
        guard let index = activeTimers.firstIndex(where: { $0.id == timer.id }) else { return false }

        let wasHeaderTimer = timer.id == headerTimer?.id
        let updatedTimer = timer.reset(remainingSeconds: TimeInterval(remainingSeconds))
        activeTimers[index] = updatedTimer

        if wasHeaderTimer {
            notificationService.cancelNotification(id: timer.id.uuidString)
            scheduleNotificationForHeaderTimer()
        }

        return true
    }

    /// Adjust a timer by a delta in seconds
    /// - Parameters:
    ///   - timer: The timer to update
    ///   - deltaSeconds: Delta seconds to add (can be negative)
    /// - Returns: false if the timer was skipped or not found
    func adjustTimer(_ timer: SetTimer, by deltaSeconds: Int) -> Bool {
        updateTimer(timer, remainingSeconds: timer.remainingSeconds + deltaSeconds)
    }

    /// Cancel all timers and notifications
    func cancelAllTimers() {
        activeTimers.removeAll()
        notificationService.cancelAllRestTimerNotifications()
    }

    // MARK: - Private

    private func scheduleNotificationForHeaderTimer() {
        guard let header = headerTimer else { return }
        let remaining = header.remainingSeconds
        if remaining > 0 {
            notificationService.scheduleRestTimerNotification(
                id: header.id.uuidString,
                after: TimeInterval(remaining)
            )
        }
    }
}
