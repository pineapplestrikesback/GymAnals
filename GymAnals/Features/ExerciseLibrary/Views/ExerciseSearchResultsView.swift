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
    @State private var duplicateTrigger = false

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

    /// Exercises filtered by exercise filter, search text, and sorted.
    /// Delegates to ExerciseLibraryViewModel for shared filter/sort logic.
    private var filteredExercises: [Exercise] {
        ExerciseLibraryViewModel.filterAndSort(
            exercises: exercises,
            searchText: searchText,
            filter: filter
        )
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
            .sensoryFeedback(.success, trigger: duplicateTrigger)
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
                duplicateTrigger.toggle()
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

    private func deleteExercise(_ exercise: Exercise) {
        modelContext.delete(exercise)
        try? modelContext.save()
        exerciseToDelete = nil
    }
}
