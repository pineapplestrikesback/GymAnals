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
}
