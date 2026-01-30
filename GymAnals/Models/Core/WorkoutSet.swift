//
//  WorkoutSet.swift
//  GymAnals
//
//  Created on 26/01/2026.
//

import Foundation
import SwiftData

/// A single set within a workout supporting multiple logging types (reps, weight, duration, distance)
@Model
final class WorkoutSet {
    var id: UUID = UUID()
    var reps: Int = 0
    var weight: Double = 0.0
    var weightUnit: WeightUnit = WeightUnit.kilograms
    var setNumber: Int = 1
    var completedDate: Date = Date.now
    var notes: String?

    /// Duration in seconds (for time-based exercises like Planks, Running)
    var duration: TimeInterval = 0

    /// Distance in kilometers (for distance-based exercises like Running, Farmers Walk)
    var distance: Double = 0.0

    /// Whether the user has confirmed/completed this set (checkmark toggled on)
    var isConfirmed: Bool = false

    var workout: Workout?
    var exercise: Exercise?

    init(reps: Int = 0, weight: Double = 0.0, weightUnit: WeightUnit = .kilograms, setNumber: Int = 1, duration: TimeInterval = 0, distance: Double = 0.0) {
        self.reps = reps
        self.weight = weight
        self.weightUnit = weightUnit
        self.setNumber = setNumber
        self.duration = duration
        self.distance = distance
    }
}
