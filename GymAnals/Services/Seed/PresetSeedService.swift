//
//  PresetSeedService.swift
//  GymAnals
//
//  Created on 28/01/2026.
//

import Foundation
import SwiftData

/// Service responsible for seeding exercise presets from presets_all.json
@MainActor
final class PresetSeedService {

    /// Seeds the database with exercise presets if not already populated
    /// Must be called AFTER MovementSeedService and EquipmentSeedService
    static func seedIfNeeded(context: ModelContext) {
        // Check if already seeded
        let descriptor = FetchDescriptor<Exercise>(
            predicate: #Predicate { $0.isBuiltIn == true }
        )
        let count = (try? context.fetchCount(descriptor)) ?? 0
        guard count == 0 else {
            return
        }

        // Load JSON from bundle
        guard let url = Bundle.main.url(forResource: "presets_all", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let seedData = try? JSONDecoder().decode(PresetSeedData.self, from: data) else {
            print("PresetSeedService: Failed to load presets_all.json from bundle")
            return
        }

        // Fetch movements and equipment for relationship linking
        let movements = (try? context.fetch(FetchDescriptor<Movement>())) ?? []
        let equipment = (try? context.fetch(FetchDescriptor<Equipment>())) ?? []
        let movementMap = Dictionary(uniqueKeysWithValues: movements.map { ($0.id, $0) })
        let equipmentMap = Dictionary(uniqueKeysWithValues: equipment.map { ($0.id, $0) })

        var presetCount = 0
        var invalidMuscleKeys: Set<String> = []
        var invalidExerciseTypeRaws: Set<Int> = []
        var invalidPopularityValues: Set<String> = []

        for seed in seedData.presets {
            // Validate muscle weight keys
            for key in seed.muscleWeights.keys {
                if Muscle(rawValue: key) == nil {
                    invalidMuscleKeys.insert(key)
                }
            }

            let dimensions = Dimensions(
                angle: seed.dimensions.angle,
                gripWidth: seed.dimensions.gripWidth,
                gripOrientation: seed.dimensions.gripOrientation,
                stance: seed.dimensions.stance,
                laterality: seed.dimensions.laterality
            )

            // Validate popularity and exerciseType, logging invalid values
            if Popularity(rawValue: seed.popularity) == nil {
                invalidPopularityValues.insert(seed.popularity)
            }
            let popularity = Popularity(rawValue: seed.popularity) ?? .common

            if let raw = seed.exerciseTypeRaw, ExerciseType(rawValue: raw) == nil {
                invalidExerciseTypeRaws.insert(raw)
            }
            let exerciseType = ExerciseType(rawValue: seed.exerciseTypeRaw ?? 0) ?? .weightReps

            let exercise = Exercise(
                id: seed.id,
                displayName: seed.displayName,
                movement: movementMap[seed.movementID],
                equipment: equipmentMap[seed.equipmentID],
                dimensions: dimensions,
                muscleWeights: seed.muscleWeights,
                popularity: popularity,
                exerciseType: exerciseType,
                isBuiltIn: true
            )
            exercise.searchTerms = seed.searchTerms
            exercise.notes = seed.notes
            exercise.sources = seed.sources

            context.insert(exercise)
            presetCount += 1
        }

        if !invalidMuscleKeys.isEmpty {
            print("PresetSeedService: Warning - invalid muscle keys found: \(invalidMuscleKeys.sorted())")
        }
        if !invalidExerciseTypeRaws.isEmpty {
            print("PresetSeedService: Warning - invalid exerciseTypeRaw values found: \(invalidExerciseTypeRaws.sorted())")
        }
        if !invalidPopularityValues.isEmpty {
            print("PresetSeedService: Warning - invalid popularity values found: \(invalidPopularityValues.sorted())")
        }

        do {
            try context.save()
            print("PresetSeedService: Seeded \(presetCount) exercise presets")
        } catch {
            print("PresetSeedService: Failed to save - \(error.localizedDescription)")
        }
    }
}
