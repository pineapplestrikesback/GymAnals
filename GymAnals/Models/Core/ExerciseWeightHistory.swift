//
//  ExerciseWeightHistory.swift
//  GymAnals
//
//  Created on 26/01/2026.
//

import Foundation
import SwiftData

/// Tracks weight progression for an exercise at a specific gym
/// Used for gym-specific weight suggestions and progress tracking
@Model
final class ExerciseWeightHistory {
    var id: UUID = UUID()
    var weight: Double = 0.0
    var weightUnit: WeightUnit = WeightUnit.kilograms
    var date: Date = Date.now

    var exercise: Exercise?
    var gym: Gym?

    init(weight: Double, weightUnit: WeightUnit = .kilograms, date: Date = .now, exercise: Exercise? = nil, gym: Gym? = nil) {
        self.weight = weight
        self.weightUnit = weightUnit
        self.date = date
        self.exercise = exercise
        self.gym = gym
    }
}
