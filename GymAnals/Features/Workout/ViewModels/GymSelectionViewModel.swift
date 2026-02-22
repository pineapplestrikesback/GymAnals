//
//  GymSelectionViewModel.swift
//  GymAnals
//
//  Created on 27/01/2026.
//

import Foundation
import SwiftUI
import SwiftData

/// ViewModel managing gym selection with persistent storage
/// Selected gym persists across app sessions via @AppStorage
@Observable
@MainActor
final class GymSelectionViewModel {
    /// @ObservationIgnored prevents double-triggering when SwiftUI's @AppStorage
    /// and @Observable both observe changes
    @ObservationIgnored
    @AppStorage("selectedGymID") private var selectedGymIDString: String = ""

    /// Tracked version of the selected gym ID that triggers SwiftUI observation.
    /// @AppStorage is @ObservationIgnored, so without this separate tracked property,
    /// views would never re-render when the gym selection changes.
    private var _selectedGymID: String = ""

    private let modelContext: ModelContext

    /// Currently selected gym (persisted via @AppStorage)
    var selectedGym: Gym? {
        get {
            // Read from _selectedGymID to register observation tracking
            guard let uuid = UUID(uuidString: _selectedGymID) else { return nil }
            let descriptor = FetchDescriptor<Gym>(
                predicate: #Predicate { $0.id == uuid }
            )
            return try? modelContext.fetch(descriptor).first
        }
        set {
            let newID = newValue?.id.uuidString ?? ""
            selectedGymIDString = newID  // Persist to AppStorage
            _selectedGymID = newID       // Trigger observation update
        }
    }

    /// All available gyms sorted by most recently used
    var gyms: [Gym] {
        let descriptor = FetchDescriptor<Gym>(
            sortBy: [SortDescriptor(\Gym.lastUsedDate, order: .reverse)]
        )
        return (try? modelContext.fetch(descriptor)) ?? []
    }

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        // Sync tracked property from persisted AppStorage value
        _selectedGymID = selectedGymIDString
        ensureDefaultSelection()
    }

    /// Ensures a gym is selected, falling back to default gym on first launch
    private func ensureDefaultSelection() {
        // If no selection stored, or stored gym doesn't exist, select default
        if _selectedGymID.isEmpty || selectedGym == nil {
            let descriptor = FetchDescriptor<Gym>(
                predicate: #Predicate { $0.isDefault == true }
            )
            if let defaultGym = try? modelContext.fetch(descriptor).first {
                let defaultID = defaultGym.id.uuidString
                selectedGymIDString = defaultID
                _selectedGymID = defaultID
            }
        }
    }
}
