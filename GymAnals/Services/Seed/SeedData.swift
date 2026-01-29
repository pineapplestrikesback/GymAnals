//
//  SeedData.swift
//  GymAnals
//
//  Created on 27/01/2026.
//

import Foundation

// MARK: - Equipment JSON Structure

struct EquipmentSeedData: Decodable {
    let equipment: [SeedEquipment]
}

struct SeedEquipment: Decodable {
    let id: String
    let displayName: String
    let category: String
    let properties: SeedEquipmentProperties
    let notes: String
}

struct SeedEquipmentProperties: Decodable {
    let bilateralOnly: Bool
    let resistanceCurve: String
    let stabilizationDemand: String
    let commonInGyms: Bool
}

// MARK: - Movement JSON Structure

struct MovementSeedData: Decodable {
    let movements: [SeedMovement]
}

struct SeedMovement: Decodable {
    let id: String
    let displayName: String
    let category: String
    let subcategory: String
    let applicableDimensions: SeedApplicableDimensions
    let applicableEquipment: [String]
    let defaultMuscleWeights: [String: Double]
    let defaultDescription: String
    let notes: String
    let sources: [String]
}

struct SeedApplicableDimensions: Decodable {
    let angle: [String]?
    let gripWidth: [String]?
    let gripOrientation: [String]?
    let stance: [String]?
    let laterality: [String]?

    /// Convert to dictionary format for Movement model
    func toDictionary() -> [String: [String]] {
        var result: [String: [String]] = [:]
        if let angle = angle { result["angle"] = angle }
        if let gripWidth = gripWidth { result["gripWidth"] = gripWidth }
        if let gripOrientation = gripOrientation { result["gripOrientation"] = gripOrientation }
        if let stance = stance { result["stance"] = stance }
        if let laterality = laterality { result["laterality"] = laterality }
        return result
    }
}

// MARK: - Preset JSON Structure

struct PresetSeedData: Decodable {
    let presets: [SeedPreset]
}

struct SeedPreset: Decodable {
    let id: String
    let displayName: String
    let searchTerms: [String]
    let movementID: String
    let dimensions: SeedDimensions
    let equipmentID: String
    let exerciseTypeRaw: Int?  // Optional for backward compatibility, defaults to 0 (weightReps)
    let muscleWeights: [String: Double]
    let popularity: String
    let notes: String
    let sources: [String]
}

struct SeedDimensions: Decodable {
    let angle: String?
    let gripWidth: String?
    let gripOrientation: String?
    let stance: String?
    let laterality: String?
}
