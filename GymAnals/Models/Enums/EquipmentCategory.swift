//
//  EquipmentCategory.swift
//  GymAnals
//
//  Created on 28/01/2026.
//

import Foundation

/// Equipment type categories for grouping and filtering
enum EquipmentCategory: String, CaseIterable, Codable, Identifiable {
    case free_weight
    case cable
    case machine
    case bodyweight
    case band
    case specialty

    var id: String { rawValue }

    /// User-friendly display name
    var displayName: String {
        switch self {
        case .free_weight: return "Free Weights"
        case .cable: return "Cable/Pulley"
        case .machine: return "Machines"
        case .bodyweight: return "Bodyweight"
        case .band: return "Resistance Bands"
        case .specialty: return "Specialty Equipment"
        }
    }
}
