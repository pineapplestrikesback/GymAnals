//
//  Workout.swift
//  GymAnals
//
//  Created on 26/01/2026.
//

import Foundation
import SwiftData

/// A single workout session containing multiple sets
@Model
final class Workout {
    var id: UUID = UUID()
    var startDate: Date = Date.now
    var endDate: Date?
    var notes: String?
    var isActive: Bool = true

    var gym: Gym?

    @Relationship(deleteRule: .cascade, inverse: \WorkoutSet.workout)
    var sets: [WorkoutSet] = []

    /// Duration of the workout in seconds (nil if still active)
    var duration: TimeInterval? {
        guard let endDate else { return nil }
        return endDate.timeIntervalSince(startDate)
    }

    init(startDate: Date = .now, gym: Gym? = nil) {
        self.startDate = startDate
        self.gym = gym
    }
}
