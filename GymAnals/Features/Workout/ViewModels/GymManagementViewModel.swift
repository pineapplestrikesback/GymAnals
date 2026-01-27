//
//  GymManagementViewModel.swift
//  GymAnals
//
//  Created on 27/01/2026.
//

import Foundation
import SwiftData

/// ViewModel for gym management operations (CRUD and deletion handling)
@Observable @MainActor
final class GymManagementViewModel {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    /// Deletes the gym and all associated workout history (cascade)
    func deleteGymWithHistory(_ gym: Gym) {
        modelContext.delete(gym)
        try? modelContext.save()
    }

    /// Deletes the gym but preserves workout history by setting gym to nil
    func deleteGymKeepHistory(_ gym: Gym) {
        // Remove gym reference from workouts
        for workout in gym.workouts {
            workout.gym = nil
        }

        // Remove gym reference from weight history
        for history in gym.weightHistory {
            history.gym = nil
        }

        modelContext.delete(gym)
        try? modelContext.save()
    }

    /// Merges workouts and history from one gym into another, then deletes the source gym
    func mergeGym(from sourceGym: Gym, to targetGym: Gym) {
        // Transfer workouts
        for workout in sourceGym.workouts {
            workout.gym = targetGym
        }

        // Transfer weight history
        for history in sourceGym.weightHistory {
            history.gym = targetGym
        }

        // Update lastUsedDate if source gym was used more recently
        if let sourceDate = sourceGym.lastUsedDate {
            if let targetDate = targetGym.lastUsedDate {
                if sourceDate > targetDate {
                    targetGym.lastUsedDate = sourceDate
                }
            } else {
                targetGym.lastUsedDate = sourceDate
            }
        }

        modelContext.delete(sourceGym)
        try? modelContext.save()
    }
}
