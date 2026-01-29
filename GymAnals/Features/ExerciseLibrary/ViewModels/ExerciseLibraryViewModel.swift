//
//  ExerciseLibraryViewModel.swift
//  GymAnals
//
//  Created on 27/01/2026.
//

import Foundation
import SwiftUI

/// ViewModel for ExerciseLibraryView managing search state with debounce
@Observable
final class ExerciseLibraryViewModel {
    /// User's current search input
    var searchText: String = "" {
        didSet { scheduleDebounce() }
    }

    /// Debounced search text (updates 300ms after typing stops)
    var debouncedSearchText: String = ""

    /// Currently selected exercise filter (.all shows everything)
    var selectedFilter: ExerciseFilter = .all

    private var debounceTask: Task<Void, Never>?

    private func scheduleDebounce() {
        debounceTask?.cancel()
        debounceTask = Task { @MainActor in
            try? await Task.sleep(for: .milliseconds(300))
            guard !Task.isCancelled else { return }
            debouncedSearchText = searchText
        }
    }

    /// Clears both search text fields immediately
    func clearSearch() {
        searchText = ""
        debouncedSearchText = ""
        debounceTask?.cancel()
    }

    // MARK: - Filtering & Sorting

    /// Filters and sorts exercises by the given filter and search text.
    /// Applied in-memory because SwiftData predicates can't query muscleWeights dictionaries or arrays.
    static func filterAndSort(
        exercises: [Exercise],
        searchText: String,
        filter: ExerciseFilter
    ) -> [Exercise] {
        var results = Array(exercises)

        // Apply exercise filter
        switch filter {
        case .all:
            break
        case .custom:
            results = results.filter { !$0.isBuiltIn }
        case .muscleGroup(let muscleGroup):
            results = results.filter { $0.primaryMuscleGroup == muscleGroup }
        }

        // Apply search filter (includes searchTerms for in-memory matching)
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

        // Sort: favorites first, then recently used, then alphabetical
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
}
