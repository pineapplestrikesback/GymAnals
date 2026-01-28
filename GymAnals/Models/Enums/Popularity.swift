//
//  Popularity.swift
//  GymAnals
//
//  Created on 28/01/2026.
//

import Foundation

/// Exercise popularity for sorting and filtering
enum Popularity: String, CaseIterable, Codable, Identifiable {
    case very_common
    case common
    case uncommon

    var id: String { rawValue }

    /// User-friendly display name
    var displayName: String {
        switch self {
        case .very_common: return "Very Common"
        case .common: return "Common"
        case .uncommon: return "Uncommon"
        }
    }

    /// Sort order for popularity (lower = more popular)
    var sortOrder: Int {
        switch self {
        case .very_common: return 1
        case .common: return 2
        case .uncommon: return 3
        }
    }
}
