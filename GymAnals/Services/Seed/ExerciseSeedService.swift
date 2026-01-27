//
//  ExerciseSeedService.swift
//  GymAnals
//
//  Created on 27/01/2026.
//

import Foundation
import SwiftData

/// Service responsible for seeding the database with initial exercise data on first launch
@MainActor
final class ExerciseSeedService {

    /// Seeds the database with exercise data if not already populated
    /// - Parameter context: The SwiftData model context to insert data into
    static func seedIfNeeded(context: ModelContext) {
        // Check if already seeded by checking for existing movements
        let descriptor = FetchDescriptor<Movement>()
        let count = (try? context.fetchCount(descriptor)) ?? 0
        guard count == 0 else {
            return
        }

        // Load and parse JSON from bundle
        guard let url = Bundle.main.url(forResource: "exercises", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let seedData = try? JSONDecoder().decode(SeedData.self, from: data) else {
            print("ExerciseSeedService: Failed to load exercises.json from bundle")
            return
        }

        // Create Equipment lookup
        var equipmentMap: [String: Equipment] = [:]
        for item in seedData.equipment {
            let equipment = Equipment(name: item.name, isBuiltIn: true)
            context.insert(equipment)
            equipmentMap[item.name] = equipment
        }

        // Create Movements, Variants, VariantMuscles, and Exercises
        var exerciseCount = 0
        for seedMovement in seedData.movements {
            // Create Movement with exercise type
            let exerciseType = ExerciseType(rawValue: seedMovement.exerciseType) ?? .weightReps
            let movement = Movement(name: seedMovement.name, isBuiltIn: true, exerciseType: exerciseType)
            context.insert(movement)

            for seedVariant in seedMovement.variants {
                // Create Variant
                let variant = Variant(name: seedVariant.name, isBuiltIn: true)
                variant.movement = movement
                context.insert(variant)

                // Add muscle weights to variant
                for seedWeight in seedVariant.muscleWeights {
                    if let muscle = Muscle(rawValue: seedWeight.muscle) {
                        let variantMuscle = VariantMuscle(muscle: muscle, weight: seedWeight.weight)
                        variantMuscle.variant = variant
                        context.insert(variantMuscle)
                    }
                }

                // Set primary muscle group from highest weighted muscle
                if let primaryMuscle = seedVariant.muscleWeights.max(by: { $0.weight < $1.weight }),
                   let muscle = Muscle(rawValue: primaryMuscle.muscle) {
                    variant.primaryMuscleGroupRaw = muscle.group.rawValue
                }

                // Create Exercise for each equipment option
                for equipmentName in seedVariant.equipment {
                    if let equipment = equipmentMap[equipmentName] {
                        let exercise = Exercise(variant: variant, equipment: equipment)
                        context.insert(exercise)
                        exerciseCount += 1
                    }
                }
            }
        }

        // Save all changes
        do {
            try context.save()
            print("ExerciseSeedService: Seeded \(seedData.movements.count) movements, \(exerciseCount) exercises")
        } catch {
            print("ExerciseSeedService: Failed to save seed data - \(error.localizedDescription)")
        }
    }
}
