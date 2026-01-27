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
    let steps = ["Movement", "Variation", "Equipment", "Type", "Muscles"]

    // MARK: - Step 1: Movement

    var selectedMovement: Movement?
    var newMovementName: String = ""
    var isCreatingNewMovement: Bool = false

    // MARK: - Step 2: Variation

    var variationName: String = ""

    // MARK: - Step 3: Equipment

    var selectedEquipment: Equipment?

    // MARK: - Step 4: Exercise Type

    var selectedExerciseType: ExerciseType = .weightReps

    // MARK: - Created Entities

    var createdVariant: Variant?
    var createdExercise: Exercise?

    // MARK: - Validation

    var canProceed: Bool {
        switch currentStep {
        case 0: return selectedMovement != nil || !newMovementName.isEmpty
        case 1: return !variationName.isEmpty
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

        // Create variant
        let variant = Variant(name: variationName, isBuiltIn: false)
        variant.movement = movement
        context.insert(variant)
        createdVariant = variant

        // Create exercise with equipment
        let exercise = Exercise(variant: variant, equipment: selectedEquipment)
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
        variationName = ""
        selectedEquipment = nil
        selectedExerciseType = .weightReps
        createdVariant = nil
        createdExercise = nil
    }
}
