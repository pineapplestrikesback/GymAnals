//
//  EquipmentSeedService.swift
//  GymAnals
//
//  Created on 28/01/2026.
//

import Foundation
import SwiftData

/// Service responsible for seeding equipment from equipment.json
@MainActor
final class EquipmentSeedService {

    /// Seeds the database with equipment if not already populated
    static func seedIfNeeded(context: ModelContext) {
        // Check if already seeded
        let descriptor = FetchDescriptor<Equipment>(
            predicate: #Predicate { $0.isBuiltIn == true }
        )
        let count = (try? context.fetchCount(descriptor)) ?? 0
        guard count == 0 else {
            return
        }

        // Load JSON from bundle
        guard let url = Bundle.main.url(forResource: "equipment", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let seedData = try? JSONDecoder().decode(EquipmentSeedData.self, from: data) else {
            print("EquipmentSeedService: Failed to load equipment.json from bundle")
            return
        }

        // Create Equipment entities
        for seed in seedData.equipment {
            let category = EquipmentCategory(rawValue: seed.category) ?? .free_weight

            let properties = EquipmentProperties(
                bilateralOnly: seed.properties.bilateralOnly,
                resistanceCurve: seed.properties.resistanceCurve,
                stabilizationDemand: seed.properties.stabilizationDemand,
                commonInGyms: seed.properties.commonInGyms
            )

            let equipment = Equipment(
                id: seed.id,
                displayName: seed.displayName,
                category: category,
                properties: properties,
                notes: seed.notes,
                isBuiltIn: true
            )

            context.insert(equipment)
        }

        do {
            try context.save()
            print("EquipmentSeedService: Seeded \(seedData.equipment.count) equipment types")
        } catch {
            print("EquipmentSeedService: Failed to save - \(error.localizedDescription)")
        }
    }
}
