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
    @State private var selectedFilter: ExerciseFilter = .all
    @State private var exerciseToEdit: Exercise?
    @State private var exerciseToDelete: Exercise?
    @State private var selectedDetailExercise: Exercise?
    @State private var duplicateTrigger = false

    let onSelectExercises: ([Exercise]) -> Void

    private var filteredExercises: [Exercise] {
        var result = exercises

        // Apply exercise filter
        switch selectedFilter {
        case .all:
            break
        case .custom:
            result = result.filter { !$0.isBuiltIn }
        case .muscleGroup(let group):
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
        if searchText.isEmpty && selectedFilter == .all {
            return Array(result.prefix(50))
        }

        return result
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Muscle group filter tabs
                MuscleGroupFilterTabs(selectedFilter: $selectedFilter)
                    .padding(.vertical, 8)

                List(filteredExercises) { exercise in
                    HStack {
                        // Main row area - tapping navigates to exercise detail
                        Button {
                            selectedDetailExercise = exercise
                        } label: {
                            ExerciseRow(exercise: exercise)
                        }
                        .buttonStyle(.borderless)

                        // Checkmark area - tapping toggles selection
                        Button {
                            toggleSelection(exercise)
                        } label: {
                            Image(systemName: selectedExerciseIDs.contains(exercise.id) ? "checkmark.circle.fill" : "circle")
                                .font(.system(size: 26))
                                .foregroundStyle(selectedExerciseIDs.contains(exercise.id) ? Color.accentColor : .secondary)
                                .frame(width: 60, height: 44)
                                .contentShape(Rectangle())
                        }
                        .buttonStyle(.borderless)
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
            }
            .navigationDestination(isPresented: Binding(
                get: { selectedDetailExercise != nil },
                set: { if !$0 { selectedDetailExercise = nil } }
            )) {
                if let exercise = selectedDetailExercise {
                    ExerciseDetailView(exercise: exercise)
                }
            }
            .sheet(item: $exerciseToEdit) { exercise in
                NavigationStack {
                    CustomExerciseEditView(exercise: exercise)
                }
            }
            .sensoryFeedback(.success, trigger: duplicateTrigger)
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
        let copy = Exercise(
            displayName: exercise.displayName + " (Copy)",
            movement: exercise.movement,
            equipment: exercise.equipment,
            dimensions: exercise.dimensions,
            muscleWeights: exercise.muscleWeights,
            isBuiltIn: false
        )
        copy.notes = exercise.notes
        copy.restDuration = exercise.restDuration
        copy.autoStartTimer = exercise.autoStartTimer
        copy.searchTerms = exercise.searchTerms
        modelContext.insert(copy)
        try? modelContext.save()
        exerciseToEdit = copy
    }

    private func deleteExercise(_ exercise: Exercise) {
        selectedExerciseIDs.remove(exercise.id)
        modelContext.delete(exercise)
        try? modelContext.save()
        exerciseToDelete = nil
    }
}
