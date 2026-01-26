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
    var id: UUID = UUID()
    var name: String = ""
    var isBuiltIn: Bool = true

    @Relationship(deleteRule: .cascade, inverse: \Exercise.equipment)
    var exercises: [Exercise] = []

    init(name: String, isBuiltIn: Bool = true) {
        self.name = name
        self.isBuiltIn = isBuiltIn
    }
}
