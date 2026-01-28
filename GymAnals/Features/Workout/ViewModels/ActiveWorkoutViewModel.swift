//
//  ActiveWorkoutViewModel.swift
//  GymAnals
//
//  Created on 28/01/2026.
//

import Foundation
import SwiftData

/// ViewModel managing active workout session state including exercises, sets, and previous workout lookups.
/// Handles workout lifecycle (start, finish, discard) and crash recovery through SwiftData auto-save.
@Observable
@MainActor
final class ActiveWorkoutViewModel {
    private let modelContext: ModelContext

    /// Currently active workout being logged
    var activeWorkout: Workout?

    /// Exercise IDs in display order (tracks user-arranged sequence)
    var exerciseOrder: [UUID] = []

    /// Tracks which exercises are expanded vs collapsed in UI
    var expandedExercises: Set<UUID> = []

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        loadActiveWorkout()
    }

    // MARK: - Workout Lifecycle

    /// Loads any existing active workout on init for crash recovery
    /// If app was terminated during workout, this restores the session
    private func loadActiveWorkout() {
        let descriptor = FetchDescriptor<Workout>(
            predicate: #Predicate { $0.isActive == true }
        )

        guard let workout = try? modelContext.fetch(descriptor).first else {
            return
        }

        activeWorkout = workout
        exerciseOrder = uniqueExerciseIDs(from: workout.sets)

        // Expand all exercises by default on recovery
        expandedExercises = Set(exerciseOrder)
    }

    /// Starts a new workout session at the specified gym
    /// - Parameter gym: The gym where workout takes place (nil for no gym)
    func startWorkout(at gym: Gym?) {
        let workout = Workout(startDate: .now, gym: gym)
        modelContext.insert(workout)

        activeWorkout = workout
        exerciseOrder = []
        expandedExercises = []

        // Update gym's last used date
        gym?.lastUsedDate = .now
    }

    /// Completes the active workout, marking it as finished
    func finishWorkout() {
        guard let workout = activeWorkout else { return }

        workout.isActive = false
        workout.endDate = .now

        activeWorkout = nil
        exerciseOrder = []
        expandedExercises = []
    }

    /// Discards the active workout without saving
    /// Deletes the workout and all its sets via cascade
    func discardWorkout() {
        guard let workout = activeWorkout else { return }

        modelContext.delete(workout)

        activeWorkout = nil
        exerciseOrder = []
        expandedExercises = []
    }

    // MARK: - Helpers

    /// Extracts unique exercise IDs from sets preserving first-appearance order
    /// - Parameter sets: Array of workout sets
    /// - Returns: Ordered array of unique exercise IDs
    private func uniqueExerciseIDs(from sets: [WorkoutSet]) -> [UUID] {
        // Sort by completedDate to get chronological order
        let sortedSets = sets.sorted { $0.completedDate < $1.completedDate }

        var seen = Set<UUID>()
        var result: [UUID] = []

        for set in sortedSets {
            guard let exerciseID = set.exercise?.id else { continue }
            if !seen.contains(exerciseID) {
                seen.insert(exerciseID)
                result.append(exerciseID)
            }
        }

        return result
    }
}
