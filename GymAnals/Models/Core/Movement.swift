//
//  Movement.swift
//  GymAnals
//
//  Created on 26/01/2026.
//

import Foundation
import SwiftData

/// Base movement pattern (e.g., "Bench Press", "Squat", "Deadlift")
/// Contains multiple variants with different muscle targeting
@Model
final class Movement {
    var id: UUID = UUID()
    var name: String = ""
    var isBuiltIn: Bool = true
    var isHidden: Bool = false

    @Relationship(deleteRule: .cascade, inverse: \Variant.movement)
    var variants: [Variant] = []

    init(name: String, isBuiltIn: Bool = true) {
        self.name = name
        self.isBuiltIn = isBuiltIn
    }
}
