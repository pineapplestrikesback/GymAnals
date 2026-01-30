//
//  Exercise.swift
//  GymAnals
//
//  Created on 26/01/2026.
//

import Foundation
import SwiftData

/// A specific exercise with muscle targeting and variation dimensions
/// (e.g., "Barbell Incline Bench Press" with specific angle and grip)
@Model
final class Exercise {
    // MARK: - Identification

    /// Unique identifier - snake_case for presets (e.g., "barbell_flat_bench_press"), UUID string for custom
    var id: String = UUID().uuidString

    /// User-friendly display name (always stored, not computed)
    var displayName: String = ""

    /// Alternative names for search (e.g., ["bench press", "flat bench", "bb bench"])
    var searchTerms: [String] = []

    // MARK: - Classification

    /// Exercise variation dimensions (angle, grip, stance, etc.)
    var dimensions: Dimensions = Dimensions()

    /// Muscle activation weights (key: Muscle.rawValue, value: 0.0-1.0)
    var muscleWeights: [String: Double] = [:]

    /// Raw value storage for popularity
    var popularityRaw: String = Popularity.common.rawValue

    /// Raw value storage for exercise type (weight+reps, bodyweight reps, time-based, etc.)
    var exerciseTypeRaw: String = ExerciseType.weightReps.rawValue

    // MARK: - Metadata

    var notes: String = ""
    var sources: [String] = []
    var isBuiltIn: Bool = false

    // MARK: - App-Specific Fields

    var isFavorite: Bool = false
    var lastUsedDate: Date?

    /// Rest duration in seconds between sets for this exercise
    var restDuration: TimeInterval = 120  // Default 2 minutes

    /// Whether to auto-start timer when a set is completed
    var autoStartTimer: Bool = true

    // MARK: - Relationships

    /// The movement pattern this exercise belongs to (e.g., "Bench Press")
    var movement: Movement?

    /// Equipment used for this exercise (e.g., "Barbell")
    var equipment: Equipment?

    /// Gym where this exercise is tracked (for gym-specific weight history)
    var gym: Gym?

    @Relationship(deleteRule: .cascade, inverse: \WorkoutSet.exercise)
    var workoutSets: [WorkoutSet] = []

    @Relationship(deleteRule: .cascade, inverse: \ExerciseWeightHistory.exercise)
    var weightHistory: [ExerciseWeightHistory] = []

    // MARK: - Computed Properties

    /// Type-safe access to popularity
    var popularity: Popularity {
        get { Popularity(rawValue: popularityRaw) ?? .common }
        set { popularityRaw = newValue.rawValue }
    }

    /// Type-safe access to exercise type
    var exerciseType: ExerciseType {
        get { ExerciseType(rawValue: exerciseTypeRaw) ?? .weightReps }
        set { exerciseTypeRaw = newValue.rawValue }
    }

    /// Whether this is a unilateral exercise (derived from dimensions)
    var isUnilateral: Bool {
        dimensions.laterality == "unilateral"
    }

    /// Primary muscle group based on highest weighted muscle
    var primaryMuscleGroup: MuscleGroup? {
        guard let primaryMuscle = muscleWeights.max(by: { $0.value < $1.value }),
              let muscle = Muscle(rawValue: primaryMuscle.key) else {
            return nil
        }
        return muscle.group
    }

    /// Get weight for a specific muscle (type-safe helper)
    func weight(for muscle: Muscle) -> Double {
        muscleWeights[muscle.rawValue] ?? 0.0
    }

    /// Get all muscles with their weights, sorted by weight descending
    var sortedMuscleWeights: [(muscle: Muscle, weight: Double)] {
        muscleWeights.compactMap { key, value in
            guard let muscle = Muscle(rawValue: key) else { return nil }
            return (muscle, value)
        }.sorted { $0.weight > $1.weight }
    }

    // MARK: - Initialization

    init(
        id: String? = nil,
        displayName: String = "",
        movement: Movement? = nil,
        equipment: Equipment? = nil,
        dimensions: Dimensions = Dimensions(),
        muscleWeights: [String: Double] = [:],
        popularity: Popularity = .common,
        exerciseType: ExerciseType = .weightReps,
        isBuiltIn: Bool = false
    ) {
        self.id = id ?? UUID().uuidString
        self.displayName = displayName
        self.movement = movement
        self.equipment = equipment
        self.dimensions = dimensions
        self.muscleWeights = muscleWeights
        self.popularityRaw = popularity.rawValue
        self.exerciseTypeRaw = exerciseType.rawValue
        self.isBuiltIn = isBuiltIn
    }

    /// Create a custom exercise inheriting defaults from movement
    static func custom(
        displayName: String,
        movement: Movement,
        equipment: Equipment?,
        dimensions: Dimensions = Dimensions()
    ) -> Exercise {
        let exercise = Exercise(
            displayName: displayName,
            movement: movement,
            equipment: equipment,
            dimensions: dimensions,
            muscleWeights: movement.defaultMuscleWeights,
            isBuiltIn: false
        )
        return exercise
    }

    /// Create a duplicate custom exercise with same properties
    func duplicate(in context: ModelContext) -> Exercise {
        let copy = Exercise(
            displayName: "\(displayName) (Copy)",
            movement: movement,
            equipment: equipment,
            dimensions: dimensions,
            muscleWeights: muscleWeights,
            popularity: popularity,
            exerciseType: exerciseType,
            isBuiltIn: false
        )
        copy.notes = notes
        copy.sources = sources
        copy.searchTerms = searchTerms
        copy.restDuration = restDuration
        copy.autoStartTimer = autoStartTimer
        context.insert(copy)
        return copy
    }
}
