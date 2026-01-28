//
//  Equipment.swift
//  GymAnals
//
//  Created on 26/01/2026.
//

import Foundation
import SwiftData

/// Equipment used for exercises (e.g., "Barbell", "Dumbbell", "Cable Machine")
@Model
final class Equipment {
    // MARK: - Identification

    /// Unique identifier - snake_case for built-in, UUID string for custom
    var id: String = UUID().uuidString

    /// Display name shown in UI
    var displayName: String = ""

    // MARK: - Classification

    /// Raw value storage for SwiftData predicate filtering
    var categoryRaw: String = EquipmentCategory.free_weight.rawValue

    /// Equipment physical properties (embedded struct)
    var properties: EquipmentProperties = EquipmentProperties()

    /// Notes about the equipment
    var notes: String = ""

    // MARK: - Metadata

    var isBuiltIn: Bool = true

    // MARK: - Relationships

    @Relationship(deleteRule: .cascade, inverse: \Exercise.equipment)
    var exercises: [Exercise] = []

    // MARK: - Computed Properties

    /// Type-safe access to equipment category
    var category: EquipmentCategory {
        get { EquipmentCategory(rawValue: categoryRaw) ?? .free_weight }
        set { categoryRaw = newValue.rawValue }
    }

    // MARK: - Initialization

    init(
        id: String? = nil,
        displayName: String,
        category: EquipmentCategory = .free_weight,
        properties: EquipmentProperties = EquipmentProperties(),
        notes: String = "",
        isBuiltIn: Bool = true
    ) {
        self.id = id ?? UUID().uuidString
        self.displayName = displayName
        self.categoryRaw = category.rawValue
        self.properties = properties
        self.notes = notes
        self.isBuiltIn = isBuiltIn
    }

    /// Convenience initializer for backward compatibility
    convenience init(name: String, isBuiltIn: Bool = true) {
        self.init(displayName: name, isBuiltIn: isBuiltIn)
    }
}
