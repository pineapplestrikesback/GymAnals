//
//  SeedData.swift
//  GymAnals
//
//  Created on 27/01/2026.
//

import Foundation

/// Root container for exercise seed data
struct SeedData: Decodable {
    let equipment: [SeedEquipment]
    let movements: [SeedMovement]
}

/// Equipment definition for seeding
struct SeedEquipment: Decodable {
    let name: String
}

/// Movement definition with exercise type and variants
struct SeedMovement: Decodable {
    let name: String
    let exerciseType: Int  // Maps to ExerciseType.rawValue
    let variants: [SeedVariant]
}

/// Variant definition with muscle weights and equipment options
struct SeedVariant: Decodable {
    let name: String
    let muscleWeights: [SeedMuscleWeight]
    let equipment: [String]  // Equipment names to create Exercise combos
}

/// Muscle weight pairing for variant muscle targeting
struct SeedMuscleWeight: Decodable {
    let muscle: String  // Muscle.rawValue
    let weight: Double  // 0.0 to 1.0
}
