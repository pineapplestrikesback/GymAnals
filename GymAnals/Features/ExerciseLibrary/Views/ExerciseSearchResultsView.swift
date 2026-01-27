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
    @Query private var exercises: [Exercise]

    private let searchText: String
    private let muscleGroup: MuscleGroup?

    init(searchText: String, muscleGroup: MuscleGroup?) {
        self.searchText = searchText
        self.muscleGroup = muscleGroup

        // SwiftData predicates have limited support for complex expressions
        // Filter by muscle group in query, apply search/sort in-memory
        if let muscleGroupRaw = muscleGroup?.rawValue {
            _exercises = Query(
                filter: #Predicate<Exercise> { exercise in
                    exercise.variant?.primaryMuscleGroupRaw == muscleGroupRaw
                }
            )
        } else {
            _exercises = Query()
        }
    }

    /// Exercises filtered by search text and sorted (applied in-memory)
    private var filteredExercises: [Exercise] {
        var results = Array(exercises)

        // Apply search filter
        if !searchText.isEmpty {
            let lowercasedSearch = searchText.lowercased()
            results = results.filter { exercise in
                exercise.displayName.lowercased().contains(lowercasedSearch) ||
                exercise.variant?.movement?.name.lowercased().contains(lowercasedSearch) == true ||
                exercise.equipment?.name.lowercased().contains(lowercasedSearch) == true ||
                exercise.variant?.primaryMuscleGroup?.displayName.lowercased().contains(lowercasedSearch) == true
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
                            NavigationLink {
                                ExerciseDetailView(exercise: exercise)
                            } label: {
                                ExerciseRow(exercise: exercise)
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
                    }
                }
            }
        }
    }
}
