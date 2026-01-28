//
//  ExerciseCreationViewModel.swift
//  GymAnals
//
//  Created on 27/01/2026.
//

import Foundation
import SwiftData

/// ViewModel managing the exercise creation wizard state
@Observable
final class ExerciseCreationViewModel {
    // MARK: - Wizard Step Tracking

    var currentStep: Int = 0
    let steps = ["Movement", "Name", "Equipment", "Type", "Muscles"]

    // MARK: - Step 1: Movement

    var selectedMovement: Movement?
    var newMovementName: String = ""
    var isCreatingNewMovement: Bool = false

    // MARK: - Step 2: Name (replaces Variation)

    var exerciseName: String = ""

    // MARK: - Step 3: Equipment

    var selectedEquipment: Equipment?

    // MARK: - Step 4: Exercise Type

    var selectedExerciseType: ExerciseType = .weightReps

    // MARK: - Dimensions

    var dimensions: Dimensions = Dimensions()

    // MARK: - Created Entities

    var createdExercise: Exercise?

    // MARK: - Suggested Name

    /// Generates a suggested exercise name from equipment + movement
    var suggestedName: String? {
        guard let movement = selectedMovement else { return nil }
        if let equipment = selectedEquipment {
            return "\(equipment.displayName) \(movement.displayName)"
        }
        return movement.displayName
    }

    // MARK: - Validation

    var canProceed: Bool {
        switch currentStep {
        case 0: return selectedMovement != nil || !newMovementName.isEmpty
        case 1: return !exerciseName.isEmpty
        case 2: return selectedEquipment != nil
        case 3: return true // Type always has default
        case 4: return true // Muscles can be empty
        default: return false
        }
    }

    var isLastStep: Bool {
        currentStep == steps.count - 1
    }

    // MARK: - Navigation

    func nextStep() {
        if currentStep < steps.count - 1 {
            currentStep += 1
        }
    }

    func previousStep() {
        if currentStep > 0 {
            currentStep -= 1
        }
    }

    // MARK: - Exercise Creation

    func createExercise(context: ModelContext) -> Exercise? {
        // Get or create movement
        let movement: Movement
        if let existing = selectedMovement {
            movement = existing
        } else {
            movement = Movement(name: newMovementName, isBuiltIn: false, exerciseType: selectedExerciseType)
            context.insert(movement)
        }

        // Create exercise directly with movement (no variant)
        let exercise = Exercise.custom(
            displayName: exerciseName,
            movement: movement,
            equipment: selectedEquipment,
            dimensions: dimensions
        )
        context.insert(exercise)
        createdExercise = exercise

        try? context.save()
        return exercise
    }

    // MARK: - Reset

    func reset() {
        currentStep = 0
        selectedMovement = nil
        newMovementName = ""
        isCreatingNewMovement = false
        exerciseName = ""
        selectedEquipment = nil
        selectedExerciseType = .weightReps
        dimensions = Dimensions()
        createdExercise = nil
    }
}
