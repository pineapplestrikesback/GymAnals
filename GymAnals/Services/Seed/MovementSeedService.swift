//
//  MovementSeedService.swift
//  GymAnals
//
//  Created on 28/01/2026.
//

import Foundation
import SwiftData

/// Service responsible for seeding movements from movements.json
@MainActor
final class MovementSeedService {

    /// Seeds the database with movements if not already populated
    static func seedIfNeeded(context: ModelContext) {
        // Check if already seeded
        let descriptor = FetchDescriptor<Movement>(
            predicate: #Predicate { $0.isBuiltIn == true }
        )
        let count = (try? context.fetchCount(descriptor)) ?? 0
        guard count == 0 else {
            return
        }

        // Load JSON from bundle
        guard let url = Bundle.main.url(forResource: "movements", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let seedData = try? JSONDecoder().decode(MovementSeedData.self, from: data) else {
            print("MovementSeedService: Failed to load movements.json from bundle")
            return
        }

        // Create Movement entities
        for seed in seedData.movements {
            let category = MovementCategory(rawValue: seed.category) ?? .push

            // Validate muscle weight keys
            for key in seed.defaultMuscleWeights.keys {
                if Muscle(rawValue: key) == nil {
                    print("MovementSeedService: Warning - invalid muscle key '\(key)' in movement '\(seed.id)'")
                }
            }

            let movement = Movement(
                id: seed.id,
                displayName: seed.displayName,
                category: category,
                subcategory: seed.subcategory,
                isBuiltIn: true
            )
            movement.applicableDimensions = seed.applicableDimensions.toDictionary()
            movement.applicableEquipment = seed.applicableEquipment
            movement.defaultMuscleWeights = seed.defaultMuscleWeights
            movement.defaultDescription = seed.defaultDescription
            movement.notes = seed.notes
            movement.sources = seed.sources

            context.insert(movement)
        }

        do {
            try context.save()
            print("MovementSeedService: Seeded \(seedData.movements.count) movements")
        } catch {
            print("MovementSeedService: Failed to save - \(error.localizedDescription)")
        }
    }
}
