//
//  MuscleWeightViewModel.swift
//  GymAnals
//
//  Created on 27/01/2026.
//

import Foundation
import SwiftData

/// ViewModel for managing muscle weight editing with change tracking
@Observable
final class MuscleWeightViewModel {
    var weights: [Muscle: Double] = [:]
    var isEditing: Bool = false
    var hasChanges: Bool = false

    private var originalWeights: [Muscle: Double] = [:]
    private let exercise: Exercise?

    init(exercise: Exercise?, startInEditMode: Bool = false) {
        self.exercise = exercise
        self.isEditing = startInEditMode
        loadWeights()
    }

    private func loadWeights() {
        guard let exercise else { return }
        for (key, value) in exercise.muscleWeights {
            if let muscle = Muscle(rawValue: key) {
                weights[muscle] = value
            }
        }
        originalWeights = weights
    }

    func updateWeight(muscle: Muscle, weight: Double) {
        weights[muscle] = weight
        hasChanges = weights != originalWeights
    }

    func saveChanges(context: ModelContext) {
        guard let exercise, hasChanges else { return }

        // Update the exercise's muscleWeights dictionary
        var newWeights: [String: Double] = [:]
        for (muscle, weight) in weights where weight > 0 {
            newWeights[muscle.rawValue] = weight
        }
        exercise.muscleWeights = newWeights

        try? context.save()
        originalWeights = weights
        hasChanges = false
        isEditing = false
    }

    func discardChanges() {
        weights = originalWeights
        hasChanges = false
        isEditing = false
    }

    func undoAll() {
        weights = originalWeights
        hasChanges = false
    }

    /// Active muscles (weight > 0), sorted by weight descending
    var activeMuscles: [(muscle: Muscle, weight: Double)] {
        weights.filter { $0.value > 0 }
            .sorted { $0.value > $1.value }
            .map { ($0.key, $0.value) }
    }

    func resetToDefault() {
        // Restore from movement's default muscle weights
        weights = [:]
        if let defaults = exercise?.movement?.defaultMuscleWeights {
            for (key, value) in defaults {
                if let muscle = Muscle(rawValue: key) {
                    weights[muscle] = value
                }
            }
        }
        hasChanges = weights != originalWeights
    }
}
