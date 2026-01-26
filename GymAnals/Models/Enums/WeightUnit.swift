//
//  WeightUnit.swift
//  GymAnals
//
//  Created on 26/01/2026.
//

import Foundation

/// Weight measurement units supported by the app
enum WeightUnit: String, CaseIterable, Codable {
    case kilograms
    case pounds

    /// Short abbreviation for display
    var abbreviation: String {
        switch self {
        case .kilograms: return "kg"
        case .pounds: return "lbs"
        }
    }

    /// Conversion factor to convert from kilograms to this unit
    /// For kilograms: 1.0 (identity)
    /// For pounds: 2.20462 (1 kg = 2.20462 lbs)
    var conversionFactorFromKg: Double {
        switch self {
        case .kilograms: return 1.0
        case .pounds: return 2.20462
        }
    }

    /// Convert a weight value from this unit to kilograms
    func toKilograms(_ value: Double) -> Double {
        value / conversionFactorFromKg
    }

    /// Convert a weight value from kilograms to this unit
    func fromKilograms(_ value: Double) -> Double {
        value * conversionFactorFromKg
    }
}
