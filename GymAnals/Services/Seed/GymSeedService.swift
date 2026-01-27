//
//  GymSeedService.swift
//  GymAnals
//
//  Created on 27/01/2026.
//

import Foundation
import SwiftData

/// Service responsible for seeding the database with a default gym on first launch
@MainActor
final class GymSeedService {

    /// Seeds the database with a default gym if not already populated
    /// - Parameter context: The SwiftData model context to insert data into
    static func seedIfNeeded(context: ModelContext) {
        // Check if already seeded by checking for existing gyms
        let descriptor = FetchDescriptor<Gym>()
        let count = (try? context.fetchCount(descriptor)) ?? 0
        guard count == 0 else {
            return
        }

        // Create default gym
        let defaultGym = Gym(name: "Default Gym", colorTag: .blue, isDefault: true)
        context.insert(defaultGym)

        // Save
        do {
            try context.save()
            print("GymSeedService: Created default gym")
        } catch {
            print("GymSeedService: Failed to save default gym - \(error.localizedDescription)")
        }
    }
}
