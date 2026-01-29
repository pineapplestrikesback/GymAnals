//
//  ExerciseSearchResultsView.swift
//  GymAnals
//
//  Created on 27/01/2026.
//

import SwiftUI
import SwiftData

/// Subview that constructs @Query from init parameters for dynamic filtering
/// Uses the subview pattern to rebuild @Query when filter parameters change
struct ExerciseSearchResultsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var exercises: [Exercise]

    private let searchText: String
    private let muscleGroup: MuscleGroup?

    @State private var exerciseToEdit: Exercise?
    @State private var exerciseToDelete: Exercise?

    init(searchText: String, muscleGroup: MuscleGroup?) {
        self.searchText = searchText
        self.muscleGroup = muscleGroup

        // SwiftData predicates have limited support for complex expressions
        // Fetch all exercises, apply muscle group filter and search in-memory
        // (muscleWeights dictionary can't be queried via predicate)
        _exercises = Query()
    }

    /// Exercises filtered by muscle group, search text, and sorted (applied in-memory)
    private var filteredExercises: [Exercise] {
        var results = Array(exercises)

        // Apply muscle group filter in-memory
        if let muscleGroup {
            results = results.filter { exercise in
                exercise.primaryMuscleGroup == muscleGroup
            }
        }

        // Apply search filter (includes searchTerms array for in-memory matching)
        if !searchText.isEmpty {
            let lowercasedSearch = searchText.lowercased()
            results = results.filter { exercise in
                exercise.displayName.lowercased().contains(lowercasedSearch) ||
                exercise.searchTerms.contains { $0.lowercased().contains(lowercasedSearch) } ||
                exercise.movement?.displayName.lowercased().contains(lowercasedSearch) == true ||
                exercise.equipment?.displayName.lowercased().contains(lowercasedSearch) == true ||
                exercise.primaryMuscleGroup?.displayName.lowercased().contains(lowercasedSearch) == true
            }
        }

        // Sort: favorites first, then by display name
        results.sort { lhs, rhs in
            if lhs.isFavorite != rhs.isFavorite {
                return lhs.isFavorite
            }
            if (lhs.lastUsedDate != nil) != (rhs.lastUsedDate != nil) {
                return lhs.lastUsedDate != nil
            }
            return lhs.displayName.localizedStandardCompare(rhs.displayName) == .orderedAscending
        }

        return results
    }

    var body: some View {
        let results = filteredExercises

        Group {
            if results.isEmpty {
                ContentUnavailableView {
                    Label("No Exercises", systemImage: "dumbbell")
                } description: {
                    Text("No exercises match your search")
                }
            } else {
                List {
                    // Starred/Recent section
                    let featured = results.filter { $0.isFavorite || $0.lastUsedDate != nil }
                    if !featured.isEmpty {
                        Section("Starred & Recent") {
                            ForEach(featured.prefix(10)) { exercise in
                                NavigationLink {
                                    ExerciseDetailView(exercise: exercise)
                                } label: {
                                    ExerciseRow(exercise: exercise)
                                }
                                .contextMenu {
                                    exerciseContextMenu(for: exercise)
                                }
                            }
                        }
                    }

                    // All exercises
                    Section("All Exercises") {
                        ForEach(results) { exercise in
                            NavigationLink {
                                ExerciseDetailView(exercise: exercise)
                            } label: {
                                ExerciseRow(exercise: exercise)
                            }
                            .contextMenu {
                                exerciseContextMenu(for: exercise)
                            }
                        }
                    }
                }
            }
        }
        .sheet(item: $exerciseToEdit) { exercise in
            NavigationStack {
                CustomExerciseEditView(exercise: exercise)
            }
        }
        .alert(
            "Delete Exercise",
            isPresented: Binding(
                get: { exerciseToDelete != nil },
                set: { if !$0 { exerciseToDelete = nil } }
            )
        ) {
            Button("Delete", role: .destructive) {
                if let exercise = exerciseToDelete {
                    deleteExercise(exercise)
                }
            }
            Button("Cancel", role: .cancel) {
                exerciseToDelete = nil
            }
        } message: {
            if let exercise = exerciseToDelete {
                Text("Are you sure you want to delete \"\(exercise.displayName)\"? This action cannot be undone.")
            }
        }
    }

    // MARK: - Context Menu

    @ViewBuilder
    private func exerciseContextMenu(for exercise: Exercise) -> some View {
        if !exercise.isBuiltIn {
            Button {
                exerciseToEdit = exercise
            } label: {
                Label("Edit", systemImage: "pencil")
            }
        }

        Button {
            duplicateExercise(exercise)
        } label: {
            Label("Duplicate", systemImage: "doc.on.doc")
        }

        if !exercise.isBuiltIn {
            Button(role: .destructive) {
                exerciseToDelete = exercise
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
    }

    // MARK: - Actions

    private func duplicateExercise(_ exercise: Exercise) {
        let duplicate = Exercise(
            displayName: "\(exercise.displayName) (Copy)",
            movement: exercise.movement,
            equipment: exercise.equipment,
            dimensions: exercise.dimensions,
            muscleWeights: exercise.muscleWeights,
            popularity: exercise.popularity,
            isBuiltIn: false
        )
        duplicate.notes = exercise.notes
        duplicate.restDuration = exercise.restDuration
        duplicate.autoStartTimer = exercise.autoStartTimer
        modelContext.insert(duplicate)
        try? modelContext.save()
    }

    private func deleteExercise(_ exercise: Exercise) {
        modelContext.delete(exercise)
        try? modelContext.save()
    }
}
