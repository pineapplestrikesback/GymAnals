//
//  VariantMuscle.swift
//  GymAnals
//
//  Created on 26/01/2026.
//

import Foundation
import SwiftData

/// Junction model linking a Variant to a Muscle with a contribution weight
/// Weight represents how much this muscle is targeted (0.0 to 1.0)
@Model
final class VariantMuscle {
    var id: UUID = UUID()
    var muscle: Muscle = Muscle.pectoralisMajorUpper
    var weight: Double = 0.5

    var variant: Variant?

    init(muscle: Muscle, weight: Double) {
        self.muscle = muscle
        self.weight = max(0.0, min(1.0, weight))
    }
}
