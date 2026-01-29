//
//  SetTimer.swift
//  GymAnals
//
//  Created on 28/01/2026.
//

import Foundation

/// A lightweight timer struct for per-set rest tracking.
/// Stores end time as Date for background persistence - remaining time is calculated on access.
struct SetTimer: Identifiable {
    let id: UUID
    let setID: UUID  // Associated WorkoutSet
    let endTime: Date  // Store end time, not countdown seconds
    let duration: TimeInterval  // Original duration for progress calculation

    /// Remaining seconds until timer expires, calculated from current time
    var remainingSeconds: Int {
        max(0, Int(endTime.timeIntervalSinceNow))
    }

    /// Progress from 1.0 (full) to 0.0 (expired)
    var progress: Double {
        guard duration > 0 else { return 0 }
        return max(0, min(1, Double(remainingSeconds) / duration))
    }

    /// Whether the timer has reached zero
    var isExpired: Bool {
        remainingSeconds == 0
    }

    init(id: UUID = UUID(), setID: UUID, duration: TimeInterval) {
        self.id = id
        self.setID = setID
        self.duration = duration
        self.endTime = Date.now.addingTimeInterval(duration)
    }

    /// Create a new timer with extended end time
    func extended(by seconds: TimeInterval) -> SetTimer {
        SetTimer(
            id: self.id,
            setID: self.setID,
            duration: self.duration + seconds,
            endTime: self.endTime.addingTimeInterval(seconds)
        )
    }

    /// Create a new timer reset to a new remaining duration from now
    func reset(remainingSeconds: TimeInterval) -> SetTimer {
        let clampedSeconds = max(0, remainingSeconds)
        return SetTimer(
            id: self.id,
            setID: self.setID,
            duration: clampedSeconds,
            endTime: Date.now.addingTimeInterval(clampedSeconds)
        )
    }

    /// Create a new timer by shifting the end time without changing duration
    func adjustedEndTime(by seconds: TimeInterval) -> SetTimer {
        SetTimer(
            id: self.id,
            setID: self.setID,
            duration: self.duration,
            endTime: self.endTime.addingTimeInterval(seconds)
        )
    }

    private init(id: UUID, setID: UUID, duration: TimeInterval, endTime: Date) {
        self.id = id
        self.setID = setID
        self.duration = duration
        self.endTime = endTime
    }
}
