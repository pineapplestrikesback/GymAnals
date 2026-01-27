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
    var createdDate: Date = Date.now

    /// Marks system default gym that cannot be deleted
    var isDefault: Bool = false

    /// Raw value storage for color tag (SwiftData predicate filtering)
    /// Use `colorTag` computed property for type-safe access
    var colorTagRaw: String = GymColor.blue.rawValue

    /// Date this gym was last used for a workout
    var lastUsedDate: Date?

    @Relationship(deleteRule: .cascade, inverse: \Workout.gym)
    var workouts: [Workout] = []

    @Relationship(deleteRule: .cascade, inverse: \ExerciseWeightHistory.gym)
    var weightHistory: [ExerciseWeightHistory] = []

    /// Type-safe access to gym color tag
    var colorTag: GymColor {
        get { GymColor(rawValue: colorTagRaw) ?? .blue }
        set { colorTagRaw = newValue.rawValue }
    }

    init(name: String, colorTag: GymColor = .blue, isDefault: Bool = false) {
        self.name = name
        self.colorTagRaw = colorTag.rawValue
        self.isDefault = isDefault
    }
}
