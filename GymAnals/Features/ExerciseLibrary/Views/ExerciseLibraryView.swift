//
//  ExerciseLibraryView.swift
//  GymAnals
//
//  Created on 27/01/2026.
//

import SwiftUI
import SwiftData

/// Main view for browsing the exercise library with search and filter
struct ExerciseLibraryView: View {
    @State private var viewModel = ExerciseLibraryViewModel()

    var body: some View {
        VStack(spacing: 0) {
            // Muscle group filter tabs
            MuscleGroupFilterTabs(selectedGroup: $viewModel.selectedMuscleGroup)
                .padding(.vertical, 8)

            Divider()

            // Results view with debounced search
            ExerciseSearchResultsView(
                searchText: viewModel.debouncedSearchText,
                muscleGroup: viewModel.selectedMuscleGroup
            )
        }
        .navigationTitle("Exercises")
        .searchable(text: $viewModel.searchText, prompt: "Search exercises")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    // TODO: Navigate to create exercise (Plan 02-05)
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        ExerciseLibraryView()
    }
    .modelContainer(PersistenceController.preview)
}
