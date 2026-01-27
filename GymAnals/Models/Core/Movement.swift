//
//  Movement.swift
//  GymAnals
//
//  Created on 26/01/2026.
//

import Foundation
import SwiftData

/// Base movement pattern (e.g., "Bench Press", "Squat", "Deadlift")
/// Contains multiple variants with different muscle targeting
@Model
final class Movement {
    var id: UUID = UUID()
    var name: String = ""
    var isBuiltIn: Bool = true
    var isHidden: Bool = false

    /// Raw value storage for SwiftData predicate filtering
    /// Use `exerciseType` computed property for type-safe access
    var exerciseTypeRaw: Int = ExerciseType.weightReps.rawValue

    @Relationship(deleteRule: .cascade, inverse: \Variant.movement)
    var variants: [Variant] = []

    /// Type-safe access to exercise type
    /// Determines which fields are shown during workout logging
    var exerciseType: ExerciseType {
        get { ExerciseType(rawValue: exerciseTypeRaw) ?? .weightReps }
        set { exerciseTypeRaw = newValue.rawValue }
    }

    init(name: String, isBuiltIn: Bool = true, exerciseType: ExerciseType = .weightReps) {
        self.name = name
        self.isBuiltIn = isBuiltIn
        self.exerciseTypeRaw = exerciseType.rawValue
    }
}
