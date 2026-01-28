//
//  Variant.swift
//  GymAnals
//
//  Created on 26/01/2026.
//

import Foundation
import SwiftData

/// A specific variation of a movement with defined muscle targeting
/// (e.g., "Incline" variant of "Bench Press" targets upper chest more)
@Model
final class Variant {
    var id: UUID = UUID()
    var name: String = ""
    var isBuiltIn: Bool = true

    /// Raw value storage for SwiftData predicate filtering
    /// nil = not set, will derive from first muscle weight's group
    /// Use `primaryMuscleGroup` computed property for type-safe access
    var primaryMuscleGroupRaw: String? = nil

    var movement: Movement?

    @Relationship(deleteRule: .cascade, inverse: \VariantMuscle.variant)
    var muscleWeights: [VariantMuscle] = []

    /// NOTE: Exercise.variant removed in 05-05 refactor. Exercises now reference Movement directly.
    // @Relationship(deleteRule: .cascade, inverse: \Exercise.variant)
    // var exercises: [Exercise] = []

    /// Type-safe access to primary muscle group for filtering
    /// Falls back to first muscle weight's group if not explicitly set
    var primaryMuscleGroup: MuscleGroup? {
        get {
            if let raw = primaryMuscleGroupRaw {
                return MuscleGroup(rawValue: raw)
            }
            // Fallback: derive from first muscle weight
            return muscleWeights.first?.muscle.group
        }
        set { primaryMuscleGroupRaw = newValue?.rawValue }
    }

    init(name: String, isBuiltIn: Bool = true, primaryMuscleGroup: MuscleGroup? = nil) {
        self.name = name
        self.isBuiltIn = isBuiltIn
        self.primaryMuscleGroupRaw = primaryMuscleGroup?.rawValue
    }
}
