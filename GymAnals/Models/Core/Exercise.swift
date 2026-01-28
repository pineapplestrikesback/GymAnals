//
//  Exercise.swift
//  GymAnals
//
//  Created on 26/01/2026.
//

import Foundation
import SwiftData

/// A specific exercise combining a Variant with Equipment
/// (e.g., "Incline Bench Press" + "Barbell" = "Barbell Incline Bench Press")
@Model
final class Exercise {
    var id: UUID = UUID()
    var isUnilateral: Bool = false
    var isFavorite: Bool = false
    var lastUsedDate: Date?

    /// Rest duration in seconds between sets for this exercise
    var restDuration: TimeInterval = 120  // Default 2 minutes, adjustable per exercise

    /// Whether to auto-start timer when a set is completed
    var autoStartTimer: Bool = true

    var variant: Variant?
    var equipment: Equipment?

    @Relationship(deleteRule: .cascade, inverse: \WorkoutSet.exercise)
    var workoutSets: [WorkoutSet] = []

    @Relationship(deleteRule: .cascade, inverse: \ExerciseWeightHistory.exercise)
    var weightHistory: [ExerciseWeightHistory] = []

    /// User-friendly display name combining variant and equipment
    var displayName: String {
        let variantName = variant?.name ?? "Unknown"
        let equipmentName = equipment?.displayName ?? ""
        if equipmentName.isEmpty {
            return variantName
        }
        return "\(equipmentName) \(variantName)"
    }

    init(variant: Variant? = nil, equipment: Equipment? = nil, isUnilateral: Bool = false) {
        self.variant = variant
        self.equipment = equipment
        self.isUnilateral = isUnilateral
    }
}
