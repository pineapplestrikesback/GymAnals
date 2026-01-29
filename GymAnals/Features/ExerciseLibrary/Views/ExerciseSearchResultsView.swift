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
    @State private var exerciseToEdit: Exercise?
    @State private var exerciseToDelete: Exercise?

    private let searchText: String
    private let filter: ExerciseFilter

    init(searchText: String, filter: ExerciseFilter) {
        self.searchText = searchText
        self.filter = filter

        // SwiftData predicates have limited support for complex expressions
        // Fetch all exercises, apply muscle group filter and search in-memory
        // (muscleWeights dictionary can't be queried via predicate)
        _exercises = Query()
    }

    /// Exercises filtered by exercise filter, search text, and sorted (applied in-memory)
    private var filteredExercises: [Exercise] {
        var results = Array(exercises)

        // Apply exercise filter in-memory
        switch filter {
        case .all:
            break // No filtering needed
        case .custom:
            results = results.filter { !$0.isBuiltIn }
        case .muscleGroup(let muscleGroup):
            results = results.filter { $0.primaryMuscleGroup == muscleGroup }
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
                            exerciseRowWithContextMenu(exercise)
                        }
                    }
                }

                // All exercises
                Section("All Exercises") {
                    ForEach(results) { exercise in
                        exerciseRowWithContextMenu(exercise)
                    }
                }
            }
            .sheet(item: $exerciseToEdit) { exercise in
                NavigationStack {
                    CustomExerciseEditView(exercise: exercise)
                }
            }
            .confirmationDialog(
                "Delete Exercise",
                isPresented: Binding(
                    get: { exerciseToDelete != nil },
                    set: { if !$0 { exerciseToDelete = nil } }
                ),
                titleVisibility: .visible
            ) {
                Button("Delete", role: .destructive) {
                    if let exercise = exerciseToDelete {
                        modelContext.delete(exercise)
                        exerciseToDelete = nil
                    }
                }
                Button("Cancel", role: .cancel) {
                    exerciseToDelete = nil
                }
            } message: {
                Text("This will permanently delete \"\(exerciseToDelete?.displayName ?? "")\" and all its workout history.")
            }
        }
    }

    // MARK: - Helpers

    @ViewBuilder
    private func exerciseRowWithContextMenu(_ exercise: Exercise) -> some View {
        NavigationLink {
            ExerciseDetailView(exercise: exercise)
        } label: {
            ExerciseRow(exercise: exercise)
        }
        .contextMenu {
            if !exercise.isBuiltIn {
                Button {
                    exerciseToEdit = exercise
                } label: {
                    Label("Edit", systemImage: "pencil")
                }
            }

            Button {
                _ = exercise.duplicate(in: modelContext)
            } label: {
                Label("Duplicate", systemImage: "doc.on.doc")
            }

            if !exercise.isBuiltIn {
                Divider()
                Button(role: .destructive) {
                    exerciseToDelete = exercise
                } label: {
                    Label("Delete", systemImage: "trash")
                }
            }
        }
    }
}
