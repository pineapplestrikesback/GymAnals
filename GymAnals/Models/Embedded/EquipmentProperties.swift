//
//  EquipmentProperties.swift
//  GymAnals
//
//  Created on 28/01/2026.
//

import Foundation

/// Embedded struct for equipment characteristics
struct EquipmentProperties: Codable, Hashable {
    var bilateralOnly: Bool = false
    var resistanceCurve: String = "gravity" // gravity, constant, variable, ascending
    var stabilizationDemand: String = "moderate" // minimal, low, moderate, high, very_high
    var commonInGyms: Bool = true

    init(
        bilateralOnly: Bool = false,
        resistanceCurve: String = "gravity",
        stabilizationDemand: String = "moderate",
        commonInGyms: Bool = true
    ) {
        self.bilateralOnly = bilateralOnly
        self.resistanceCurve = resistanceCurve
        self.stabilizationDemand = stabilizationDemand
        self.commonInGyms = commonInGyms
    }
}
