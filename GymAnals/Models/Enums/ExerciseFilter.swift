//
//  ExerciseFilter.swift
//  GymAnals
//
//  Created on 29/01/2026.
//

import Foundation

/// Filter type for the exercise library supporting muscle groups and custom exercises
enum ExerciseFilter: Hashable, Identifiable {
    case all
    case custom
    case muscleGroup(MuscleGroup)

    var id: String {
        switch self {
        case .all: return "all"
        case .custom: return "custom"
        case .muscleGroup(let group): return group.rawValue
        }
    }

    /// User-friendly display name
    var displayName: String {
        switch self {
        case .all: return "All"
        case .custom: return "Custom"
        case .muscleGroup(let group): return group.displayName
        }
    }

    /// All filter options in display order: All, Custom, then each muscle group
    static var allFilters: [ExerciseFilter] {
        [.all, .custom] + MuscleGroup.allCases.map { .muscleGroup($0) }
    }
}
