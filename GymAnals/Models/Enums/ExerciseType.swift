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
enum ExerciseType: String, CaseIterable, Codable, Identifiable {
    case weightReps = "weight_reps"
    case bodyweightReps = "bodyweight_reps"
    case weightedBodyweight = "weighted_bodyweight"
    case assistedBodyweight = "assisted_bodyweight"
    case duration = "duration"
    case durationWeight = "duration_weight"
    case distanceDuration = "distance_duration"
    case weightDistance = "weight_distance"

    var id: String { rawValue }

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
