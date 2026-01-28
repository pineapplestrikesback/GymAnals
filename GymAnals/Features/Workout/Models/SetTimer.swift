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

    /// Remaining seconds until timer expires, calculated from current time
    var remainingSeconds: Int {
        max(0, Int(endTime.timeIntervalSinceNow))
    }

    /// Whether the timer has reached zero
    var isExpired: Bool {
        remainingSeconds == 0
    }

    init(id: UUID = UUID(), setID: UUID, duration: TimeInterval) {
        self.id = id
        self.setID = setID
        self.endTime = Date.now.addingTimeInterval(duration)
    }

    /// Create a new timer with extended end time
    func extended(by seconds: TimeInterval) -> SetTimer {
        SetTimer(
            id: self.id,
            setID: self.setID,
            endTime: self.endTime.addingTimeInterval(seconds)
        )
    }

    private init(id: UUID, setID: UUID, endTime: Date) {
        self.id = id
        self.setID = setID
        self.endTime = endTime
    }
}
