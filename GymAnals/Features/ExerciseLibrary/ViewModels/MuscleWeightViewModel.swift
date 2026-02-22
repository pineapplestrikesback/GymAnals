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
    var isEditing: Bool = false {
        didSet {
            if isEditing && !oldValue {
                // Capture stable display order when entering edit mode
                frozenDisplayOrder = computeSortedAssigned()
            }
        }
    }
    var hasChanges: Bool = false

    /// Frozen display order used during editing to prevent reordering mid-drag.
    /// Set when entering edit mode; cleared when exiting.
    private(set) var frozenDisplayOrder: [Muscle] = []

    private var originalWeights: [Muscle: Double] = [:]
    private let exercise: Exercise?

    init(exercise: Exercise?, startInEditMode: Bool = false) {
        self.exercise = exercise
        loadWeights()
        if startInEditMode {
            // Capture order before setting isEditing so didSet logic works
            self.frozenDisplayOrder = computeSortedAssigned()
            self.isEditing = true
        }
    }

    /// Returns assigned muscles sorted by weight descending.
    private func computeSortedAssigned() -> [Muscle] {
        weights.filter { $0.value > 0 }
            .sorted { $0.value > $1.value }
            .map(\.key)
    }

    /// The list of assigned muscles to display in the "Targeted Muscles" section.
    /// During editing, uses frozen order (adding newly-assigned muscles at the end).
    /// When not editing, returns live sorted order.
    var assignedMusclesForDisplay: [Muscle] {
        if isEditing {
            let currentlyAssigned = Set(weights.filter { $0.value > 0 }.map(\.key))
            // Start with frozen order, filtering out muscles that were zeroed out
            var result = frozenDisplayOrder.filter { currentlyAssigned.contains($0) }
            // Append any newly-assigned muscles not in the frozen order
            let frozenSet = Set(frozenDisplayOrder)
            let newlyAssigned = currentlyAssigned.subtracting(frozenSet)
                .sorted { ($0.displayName) < ($1.displayName) }
            result.append(contentsOf: newlyAssigned)
            return result
        } else {
            return computeSortedAssigned()
        }
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
        frozenDisplayOrder = []
        isEditing = false
    }

    func discardChanges() {
        weights = originalWeights
        hasChanges = false
        frozenDisplayOrder = []
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
