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

        // Create Movements and Exercises (no longer uses Variant intermediary)
        var exerciseCount = 0
        for seedMovement in seedData.movements {
            // Create Movement with exercise type
            let exerciseType = ExerciseType(rawValue: seedMovement.exerciseType) ?? .weightReps
            let movement = Movement(name: seedMovement.name, isBuiltIn: true, exerciseType: exerciseType)
            context.insert(movement)

            for seedVariant in seedMovement.variants {
                // Build muscleWeights dictionary from seed data
                var muscleWeights: [String: Double] = [:]
                for seedWeight in seedVariant.muscleWeights {
                    if Muscle(rawValue: seedWeight.muscle) != nil {
                        muscleWeights[seedWeight.muscle] = seedWeight.weight
                    }
                }

                // Create Exercise for each equipment option
                for equipmentName in seedVariant.equipment {
                    if let equipment = equipmentMap[equipmentName] {
                        let exercise = Exercise(
                            displayName: "\(equipment.displayName) \(seedVariant.name)",
                            movement: movement,
                            equipment: equipment,
                            muscleWeights: muscleWeights,
                            isBuiltIn: true
                        )
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
