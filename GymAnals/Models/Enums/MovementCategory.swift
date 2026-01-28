//
//  MovementCategory.swift
//  GymAnals
//
//  Created on 28/01/2026.
//

import Foundation

/// Movement pattern categories for exercise organization
enum MovementCategory: String, CaseIterable, Codable, Identifiable {
    case push
    case pull
    case squat
    case lunge
    case hinge
    case isolation
    case core

    var id: String { rawValue }

    /// User-friendly display name
    var displayName: String {
        switch self {
        case .push: return "Push"
        case .pull: return "Pull"
        case .squat: return "Squat"
        case .lunge: return "Lunge"
        case .hinge: return "Hinge"
        case .isolation: return "Isolation"
        case .core: return "Core"
        }
    }
}
