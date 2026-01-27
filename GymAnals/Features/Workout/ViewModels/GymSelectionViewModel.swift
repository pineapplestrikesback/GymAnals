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

    private let modelContext: ModelContext

    /// Currently selected gym (persisted via @AppStorage)
    var selectedGym: Gym? {
        get {
            guard let uuid = UUID(uuidString: selectedGymIDString) else { return nil }
            let descriptor = FetchDescriptor<Gym>(
                predicate: #Predicate { $0.id == uuid }
            )
            return try? modelContext.fetch(descriptor).first
        }
        set {
            selectedGymIDString = newValue?.id.uuidString ?? ""
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
        ensureDefaultSelection()
    }

    /// Ensures a gym is selected, falling back to default gym on first launch
    private func ensureDefaultSelection() {
        // If no selection stored, or stored gym doesn't exist, select default
        if selectedGymIDString.isEmpty || selectedGym == nil {
            let descriptor = FetchDescriptor<Gym>(
                predicate: #Predicate { $0.isDefault == true }
            )
            if let defaultGym = try? modelContext.fetch(descriptor).first {
                selectedGymIDString = defaultGym.id.uuidString
            }
        }
    }
}
