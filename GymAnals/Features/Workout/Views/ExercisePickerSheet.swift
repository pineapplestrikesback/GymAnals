//
//  ExercisePickerSheet.swift
//  GymAnals
//
//  Created on 28/01/2026.
//

import SwiftData
import SwiftUI

/// Sheet for selecting exercises to add to a workout.
/// Shows recently used exercises first, with search capability.
struct ExercisePickerSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \Exercise.lastUsedDate, order: .reverse) private var exercises: [Exercise]
    @State private var searchText = ""

    let onSelectExercise: (Exercise) -> Void

    private var filteredExercises: [Exercise] {
        if searchText.isEmpty {
            // Return first 50 recently used exercises
            return Array(exercises.prefix(50))
        } else {
            // Filter by displayName, searchTerms, and movement name (in-memory)
            let lowered = searchText.lowercased()
            return exercises.filter { exercise in
                exercise.displayName.localizedCaseInsensitiveContains(searchText) ||
                exercise.searchTerms.contains { $0.lowercased().contains(lowered) } ||
                exercise.movement?.displayName.localizedCaseInsensitiveContains(searchText) == true
            }
        }
    }

    var body: some View {
        NavigationStack {
            List(filteredExercises) { exercise in
                Button {
                    onSelectExercise(exercise)
                    dismiss()
                } label: {
                    ExerciseRow(exercise: exercise)
                }
                .tint(.primary)
            }
            .navigationTitle("Add Exercise")
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
}
