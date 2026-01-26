//
//  WorkoutSet.swift
//  GymAnals
//
//  Created on 26/01/2026.
//

import Foundation
import SwiftData

/// A single set within a workout (reps + weight for an exercise)
@Model
final class WorkoutSet {
    var id: UUID = UUID()
    var reps: Int = 0
    var weight: Double = 0.0
    var weightUnit: WeightUnit = WeightUnit.kilograms
    var setNumber: Int = 1
    var completedDate: Date = Date.now
    var notes: String?

    var workout: Workout?
    var exercise: Exercise?

    init(reps: Int, weight: Double, weightUnit: WeightUnit = .kilograms, setNumber: Int = 1) {
        self.reps = reps
        self.weight = weight
        self.weightUnit = weightUnit
        self.setNumber = setNumber
    }
}
