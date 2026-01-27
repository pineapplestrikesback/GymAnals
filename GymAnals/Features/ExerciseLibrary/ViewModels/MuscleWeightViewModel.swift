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
    private let variant: Variant?

    init(variant: Variant?) {
        self.variant = variant
        loadWeights()
    }

    private func loadWeights() {
        guard let variant else { return }
        for vm in variant.muscleWeights {
            weights[vm.muscle] = vm.weight
        }
        originalWeights = weights
    }

    func updateWeight(muscle: Muscle, weight: Double) {
        weights[muscle] = weight
        hasChanges = weights != originalWeights
    }

    func saveChanges(context: ModelContext) {
        guard let variant, hasChanges else { return }

        // Remove existing weights
        for vm in variant.muscleWeights {
            context.delete(vm)
        }

        // Create new weights
        for (muscle, weight) in weights where weight > 0 {
            let vm = VariantMuscle(muscle: muscle, weight: weight)
            vm.variant = variant
            context.insert(vm)
        }

        // Update primary muscle group based on highest weighted muscle
        if let primary = weights.max(by: { $0.value < $1.value }) {
            variant.primaryMuscleGroupRaw = primary.key.group.rawValue
        }

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

    func resetToDefault() {
        // For built-in exercises, this would restore original seed data
        // For now, clear all weights
        weights = [:]
        hasChanges = weights != originalWeights
    }
}
