//
//  ExercisePickerSheet.swift
//  GymAnals
//
//  Created on 28/01/2026.
//

import SwiftData
import SwiftUI

/// Sheet for selecting exercises to add to a workout.
/// Supports multi-select with checkboxes, muscle group filter tabs, and search.
struct ExercisePickerSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Exercise.lastUsedDate, order: .reverse) private var exercises: [Exercise]
    @State private var searchText = ""
    @State private var selectedExerciseIDs: Set<String> = []
    @State private var selectedMuscleGroup: MuscleGroup? = nil
    @State private var showingExerciseCreation = false
    @State private var exerciseToEdit: Exercise?
    @State private var exerciseToDelete: Exercise?

    let onSelectExercises: ([Exercise]) -> Void

    private var filteredExercises: [Exercise] {
        var result = exercises

        // Filter by muscle group if selected
        if let group = selectedMuscleGroup {
            result = result.filter { $0.primaryMuscleGroup == group }
        }

        // Filter by search text
        if !searchText.isEmpty {
            let lowered = searchText.lowercased()
            result = result.filter { exercise in
                exercise.displayName.localizedCaseInsensitiveContains(searchText) ||
                exercise.searchTerms.contains { $0.lowercased().contains(lowered) } ||
                exercise.movement?.displayName.localizedCaseInsensitiveContains(searchText) == true
            }
        }

        // Only limit to 50 when no filters are active
        if searchText.isEmpty && selectedMuscleGroup == nil {
            return Array(result.prefix(50))
        }

        return result
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Muscle group filter tabs
                MuscleGroupFilterTabs(selectedGroup: $selectedMuscleGroup)
                    .padding(.vertical, 8)

                List(filteredExercises) { exercise in
                    ExercisePickerRow(
                        exercise: exercise,
                        isSelected: selectedExerciseIDs.contains(exercise.id),
                        onToggleSelection: {
                            toggleSelection(exercise)
                        }
                    )
                    .contextMenu {
                        exerciseContextMenu(for: exercise)
                    }
                }
                .listStyle(.plain)
                .safeAreaInset(edge: .bottom) {
                    if !selectedExerciseIDs.isEmpty {
                        Button {
                            let selected = exercises.filter { selectedExerciseIDs.contains($0.id) }
                            onSelectExercises(selected)
                            dismiss()
                        } label: {
                            Text("Add \(selectedExerciseIDs.count) \(selectedExerciseIDs.count == 1 ? "Exercise" : "Exercises")")
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                        .controlSize(.large)
                        .padding()
                        .background(.bar, ignoresSafeAreaEdges: .bottom)
                    }
                }
            }
            .navigationTitle("Add Exercises")
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $searchText, prompt: "Search exercises")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showingExerciseCreation = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingExerciseCreation) {
                ExerciseCreationWizard(onCreated: { newExercise in
                    // Auto-select the newly created exercise
                    selectedExerciseIDs.insert(newExercise.id)
                })
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

    // MARK: - Helpers

    private func toggleSelection(_ exercise: Exercise) {
        withAnimation(.snappy) {
            if selectedExerciseIDs.contains(exercise.id) {
                selectedExerciseIDs.remove(exercise.id)
            } else {
                selectedExerciseIDs.insert(exercise.id)
            }
        }
    }

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
        selectedExerciseIDs.remove(exercise.id)
        modelContext.delete(exercise)
        try? modelContext.save()
    }
}

// MARK: - Exercise Picker Row

/// A row in the exercise picker with split tap zones:
/// - Main area navigates to ExerciseDetailView
/// - Right checkmark area toggles selection
private struct ExercisePickerRow: View {
    let exercise: Exercise
    let isSelected: Bool
    let onToggleSelection: () -> Void

    var body: some View {
        HStack(spacing: 0) {
            // Main row area: navigates to detail view
            NavigationLink {
                ExerciseDetailView(exercise: exercise)
            } label: {
                ExerciseRow(exercise: exercise)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .buttonStyle(.plain)

            // Checkmark area: toggles selection
            Button {
                onToggleSelection()
            } label: {
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 26))
                    .foregroundStyle(isSelected ? Color.accentColor : .secondary)
                    .frame(width: 64, height: 44)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
        }
    }
}
