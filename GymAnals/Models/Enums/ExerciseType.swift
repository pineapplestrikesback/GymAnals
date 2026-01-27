//
//  ExerciseType.swift
//  GymAnals
//
//  Created on 27/01/2026.
//

import Foundation

/// Field types required for logging a set
enum LogField: String, CaseIterable {
    case reps
    case weight
    case duration
    case distance
}

/// Exercise type determines which fields are shown during workout logging
enum ExerciseType: Int, CaseIterable, Codable, Identifiable {
    case weightReps = 0        // Bench Press, Curls -> Reps + KG
    case bodyweightReps = 1    // Pullups, Situps -> Reps only
    case weightedBodyweight = 2 // Weighted Pullups -> Reps + (+KG)
    case assistedBodyweight = 3 // Assisted Pullups -> Reps + (-KG)
    case duration = 4          // Planks, Yoga -> Timer
    case durationWeight = 5    // Weighted Plank -> KG + Time
    case distanceDuration = 6  // Running, Cycling -> Time + KM
    case weightDistance = 7    // Farmers Walk -> KG + KM

    var id: Int { rawValue }

    /// User-friendly display name
    var displayName: String {
        switch self {
        case .weightReps: return "Weight & Reps"
        case .bodyweightReps: return "Bodyweight Reps"
        case .weightedBodyweight: return "Weighted Bodyweight"
        case .assistedBodyweight: return "Assisted Bodyweight"
        case .duration: return "Duration"
        case .durationWeight: return "Duration & Weight"
        case .distanceDuration: return "Distance & Duration"
        case .weightDistance: return "Weight & Distance"
        }
    }

    /// Fields required for logging sets of this exercise type
    var logFields: [LogField] {
        switch self {
        case .weightReps: return [.reps, .weight]
        case .bodyweightReps: return [.reps]
        case .weightedBodyweight: return [.reps, .weight]
        case .assistedBodyweight: return [.reps, .weight]
        case .duration: return [.duration]
        case .durationWeight: return [.duration, .weight]
        case .distanceDuration: return [.distance, .duration]
        case .weightDistance: return [.weight, .distance]
        }
    }
}
