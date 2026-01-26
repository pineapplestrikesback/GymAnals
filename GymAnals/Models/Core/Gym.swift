//
//  Gym.swift
//  GymAnals
//
//  Created on 26/01/2026.
//

import Foundation
import SwiftData

/// A gym location where workouts take place
/// Used for gym-specific exercise weight history
@Model
final class Gym {
    var id: UUID = UUID()
    var name: String = ""
    var location: String?
    var createdDate: Date = Date.now

    @Relationship(deleteRule: .cascade, inverse: \Workout.gym)
    var workouts: [Workout] = []

    @Relationship(deleteRule: .cascade, inverse: \ExerciseWeightHistory.gym)
    var weightHistory: [ExerciseWeightHistory] = []

    init(name: String, location: String? = nil) {
        self.name = name
        self.location = location
    }
}
