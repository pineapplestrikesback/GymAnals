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
    @Query(sort: \Exercise.lastUsedDate, order: .reverse) private var exercises: [Exercise]
    @State private var searchText = ""
    @State private var selectedExerciseIDs: Set<String> = []
    @State private var selectedFilter: ExerciseFilter = .all

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
                    Button {
                        toggleSelection(exercise)
                    } label: {
                        HStack {
                            ExerciseRow(exercise: exercise)

                            Spacer()

                            Image(systemName: selectedExerciseIDs.contains(exercise.id) ? "checkmark.circle.fill" : "circle")
                                .font(.title3)
                                .foregroundStyle(selectedExerciseIDs.contains(exercise.id) ? Color.accentColor : .secondary)
                        }
                    }
                    .tint(.primary)
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
}
