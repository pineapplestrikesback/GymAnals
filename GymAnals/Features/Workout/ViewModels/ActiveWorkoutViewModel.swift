//
//  ActiveWorkoutViewModel.swift
//  GymAnals
//
//  Created on 28/01/2026.
//

import Foundation
import SwiftData
import SwiftUI

/// ViewModel managing active workout session state including exercises, sets, and previous workout lookups.
/// Handles workout lifecycle (start, finish, discard) and crash recovery through SwiftData auto-save.
@Observable
@MainActor
final class ActiveWorkoutViewModel {
    private let modelContext: ModelContext

    /// Currently active workout being logged
    var activeWorkout: Workout?

    /// Exercise IDs in display order (tracks user-arranged sequence)
    var exerciseOrder: [String] = []

    /// Tracks which exercises are expanded vs collapsed in UI
    var expandedExercises: Set<String> = []

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

    // MARK: - Exercise Management

    /// Adds an exercise to the current workout
    /// - Parameter exercise: The exercise to add
    func addExercise(_ exercise: Exercise) {
        guard activeWorkout != nil else { return }

        // Add to order if not already present
        if !exerciseOrder.contains(exercise.id) {
            exerciseOrder.append(exercise.id)
            expandedExercises.insert(exercise.id)
        }

        // Update exercise's last used date
        exercise.lastUsedDate = .now
    }

    /// Removes an exercise from the current workout
    /// Deletes all sets for this exercise but preserves the exercise itself
    /// - Parameter exercise: The exercise to remove
    func removeExercise(_ exercise: Exercise) {
        guard let workout = activeWorkout else { return }

        exerciseOrder.removeAll { $0 == exercise.id }
        expandedExercises.remove(exercise.id)

        // Delete all sets for this exercise in current workout
        let setsToDelete = workout.sets.filter { $0.exercise?.id == exercise.id }
        for set in setsToDelete {
            modelContext.delete(set)
        }
    }

    /// Reorders exercises in the display list
    /// - Parameters:
    ///   - source: The indices to move from
    ///   - destination: The index to move to
    func moveExercise(from source: IndexSet, to destination: Int) {
        exerciseOrder.move(fromOffsets: source, toOffset: destination)
    }

    /// Toggles whether an exercise is expanded or collapsed in the UI
    /// - Parameter exerciseID: The ID of the exercise to toggle
    func toggleExerciseExpanded(_ exerciseID: String) {
        if expandedExercises.contains(exerciseID) {
            expandedExercises.remove(exerciseID)
        } else {
            expandedExercises.insert(exerciseID)
        }
    }

    // MARK: - Set Management

    /// Adds a new set for an exercise with optional pre-filled values from previous workout
    /// - Parameter exercise: The exercise to add a set for
    /// - Returns: The newly created WorkoutSet
    @discardableResult
    func addSet(for exercise: Exercise) -> WorkoutSet {
        let existingSetCount = setsForExercise(exercise).count
        let setNumber = existingSetCount + 1

        // Get suggested values from previous workout
        let suggested = suggestedValues(for: exercise, setNumber: setNumber)

        let newSet = WorkoutSet(
            reps: suggested?.reps ?? 0,
            weight: suggested?.weight ?? 0.0,
            setNumber: setNumber
        )
        newSet.workout = activeWorkout
        newSet.exercise = exercise

        modelContext.insert(newSet)

        return newSet
    }

    /// Deletes a set and renumbers remaining sets for that exercise
    /// - Parameter set: The set to delete
    func deleteSet(_ set: WorkoutSet) {
        guard let exercise = set.exercise else {
            modelContext.delete(set)
            return
        }

        let deletedSetNumber = set.setNumber
        modelContext.delete(set)

        // Renumber remaining sets
        let remainingSets = setsForExercise(exercise)
        for remainingSet in remainingSets where remainingSet.setNumber > deletedSetNumber {
            remainingSet.setNumber -= 1
        }
    }

    /// Returns all sets for an exercise in the current workout, sorted by set number
    /// - Parameter exercise: The exercise to get sets for
    /// - Returns: Array of WorkoutSets sorted by setNumber
    func setsForExercise(_ exercise: Exercise) -> [WorkoutSet] {
        guard let workout = activeWorkout else { return [] }

        return workout.sets
            .filter { $0.exercise?.id == exercise.id }
            .sorted { $0.setNumber < $1.setNumber }
    }

    // MARK: - Previous Workout Lookup

    /// Returns sets from the most recent previous workout for an exercise at the current gym
    /// - Parameter exercise: The exercise to look up
    /// - Returns: Array of previous workout sets sorted by set number, empty if no previous workout
    func previousSets(for exercise: Exercise) -> [WorkoutSet] {
        let currentGymID = activeWorkout?.gym?.id

        // Build predicate based on gym
        let predicate: Predicate<Workout>
        if let gymID = currentGymID {
            predicate = #Predicate<Workout> { workout in
                workout.isActive == false && workout.gym?.id == gymID
            }
        } else {
            // No gym selected - look for workouts without a gym
            predicate = #Predicate<Workout> { workout in
                workout.isActive == false && workout.gym == nil
            }
        }

        var descriptor = FetchDescriptor<Workout>(
            predicate: predicate,
            sortBy: [SortDescriptor(\Workout.endDate, order: .reverse)]
        )
        descriptor.fetchLimit = 50 // Reasonable limit for performance

        guard let previousWorkouts = try? modelContext.fetch(descriptor) else {
            return []
        }

        // Find first workout containing sets for this exercise
        for workout in previousWorkouts {
            let exerciseSets = workout.sets.filter { $0.exercise?.id == exercise.id }
            if !exerciseSets.isEmpty {
                return exerciseSets.sorted { $0.setNumber < $1.setNumber }
            }
        }

        return []
    }

    /// Returns suggested reps and weight for a set based on previous workout
    /// - Parameters:
    ///   - exercise: The exercise to get suggestions for
    ///   - setNumber: The set number (1-based)
    /// - Returns: Tuple of (reps, weight) or nil if no previous data
    func suggestedValues(for exercise: Exercise, setNumber: Int) -> (reps: Int, weight: Double)? {
        let previous = previousSets(for: exercise)

        // setNumber is 1-based, array is 0-based
        guard setNumber > 0, setNumber <= previous.count else {
            return nil
        }

        let previousSet = previous[setNumber - 1]
        return (reps: previousSet.reps, weight: previousSet.weight)
    }

    /// Returns the previous workout's set for display (e.g., "last: 8x100")
    /// - Parameters:
    ///   - exercise: The exercise to look up
    ///   - setNumber: The set number (1-based)
    /// - Returns: The previous WorkoutSet or nil if not available
    func previousSetForRow(exercise: Exercise, setNumber: Int) -> WorkoutSet? {
        let previous = previousSets(for: exercise)

        guard setNumber > 0, setNumber <= previous.count else {
            return nil
        }

        return previous[setNumber - 1]
    }

    // MARK: - Helpers

    /// Extracts unique exercise IDs from sets preserving first-appearance order
    /// - Parameter sets: Array of workout sets
    /// - Returns: Ordered array of unique exercise IDs
    private func uniqueExerciseIDs(from sets: [WorkoutSet]) -> [String] {
        // Sort by completedDate to get chronological order
        let sortedSets = sets.sorted { $0.completedDate < $1.completedDate }

        var seen = Set<String>()
        var result: [String] = []

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
