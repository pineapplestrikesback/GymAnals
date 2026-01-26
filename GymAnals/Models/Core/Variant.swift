//
//  Variant.swift
//  GymAnals
//
//  Created on 26/01/2026.
//

import Foundation
import SwiftData

/// A specific variation of a movement with defined muscle targeting
/// (e.g., "Incline" variant of "Bench Press" targets upper chest more)
@Model
final class Variant {
    var id: UUID = UUID()
    var name: String = ""
    var isBuiltIn: Bool = true

    var movement: Movement?

    @Relationship(deleteRule: .cascade, inverse: \VariantMuscle.variant)
    var muscleWeights: [VariantMuscle] = []

    @Relationship(deleteRule: .cascade, inverse: \Exercise.variant)
    var exercises: [Exercise] = []

    init(name: String, isBuiltIn: Bool = true) {
        self.name = name
        self.isBuiltIn = isBuiltIn
    }
}
