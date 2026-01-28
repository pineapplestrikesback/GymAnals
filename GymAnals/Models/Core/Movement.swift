//
//  Movement.swift
//  GymAnals
//
//  Created on 26/01/2026.
//

import Foundation
import SwiftData

/// Base movement pattern (e.g., "Bench Press", "Squat", "Deadlift")
/// Contains default muscle weights inherited by custom exercises
@Model
final class Movement {
    // MARK: - Identification

    /// Unique identifier - snake_case for built-in (e.g., "bench_press"), UUID string for custom
    var id: String = UUID().uuidString

    /// Display name shown in UI
    var displayName: String = ""

    // MARK: - Classification

    /// Raw value storage for SwiftData predicate filtering
    var categoryRaw: String = MovementCategory.push.rawValue

    /// Subcategory for more granular classification (e.g., "horizontal_push", "vertical_pull")
    var subcategory: String = ""

    /// Raw value storage for exercise type (weight+reps, time-based, etc.)
    var exerciseTypeRaw: Int = ExerciseType.weightReps.rawValue

    // MARK: - Dimension and Equipment Constraints

    /// Valid dimension values per dimension type (e.g., {"angle": ["flat", "incline_30"]})
    var applicableDimensions: [String: [String]] = [:]

    /// Compatible equipment IDs for this movement
    var applicableEquipment: [String] = []

    // MARK: - Default Values for Custom Exercises

    /// Default muscle weights inherited when creating custom exercises
    var defaultMuscleWeights: [String: Double] = [:]

    /// Default description for the movement pattern
    var defaultDescription: String = ""

    // MARK: - Metadata

    var notes: String = ""
    var sources: [String] = []
    var isBuiltIn: Bool = true
    var isHidden: Bool = false

    // MARK: - Relationships

    /// Exercises using this movement pattern
    @Relationship(deleteRule: .cascade, inverse: \Exercise.movement)
    var exercises: [Exercise] = []

    // MARK: - Computed Properties

    /// Type-safe access to movement category
    var category: MovementCategory {
        get { MovementCategory(rawValue: categoryRaw) ?? .push }
        set { categoryRaw = newValue.rawValue }
    }

    /// Type-safe access to exercise type
    var exerciseType: ExerciseType {
        get { ExerciseType(rawValue: exerciseTypeRaw) ?? .weightReps }
        set { exerciseTypeRaw = newValue.rawValue }
    }

    // MARK: - Initialization

    init(
        id: String? = nil,
        displayName: String,
        category: MovementCategory = .push,
        subcategory: String = "",
        exerciseType: ExerciseType = .weightReps,
        isBuiltIn: Bool = true
    ) {
        self.id = id ?? UUID().uuidString
        self.displayName = displayName
        self.categoryRaw = category.rawValue
        self.subcategory = subcategory
        self.exerciseTypeRaw = exerciseType.rawValue
        self.isBuiltIn = isBuiltIn
    }

    /// Convenience initializer for backward compatibility
    convenience init(name: String, isBuiltIn: Bool = true, exerciseType: ExerciseType = .weightReps) {
        self.init(displayName: name, exerciseType: exerciseType, isBuiltIn: isBuiltIn)
    }
}
