//
//  MuscleGroup.swift
//  GymAnals
//
//  Created on 26/01/2026.
//

import Foundation

/// High-level grouping of muscles by body region
enum MuscleGroup: String, CaseIterable, Codable, Identifiable {
    case chest
    case back
    case shoulders
    case arms
    case core
    case legs

    var id: String { rawValue }

    /// User-friendly display name
    var displayName: String {
        switch self {
        case .chest: return "Chest"
        case .back: return "Back"
        case .shoulders: return "Shoulders"
        case .arms: return "Arms"
        case .core: return "Core"
        case .legs: return "Legs"
        }
    }

    /// All muscles belonging to this group
    var muscles: [Muscle] {
        Muscle.allCases.filter { $0.group == self }
    }
}
