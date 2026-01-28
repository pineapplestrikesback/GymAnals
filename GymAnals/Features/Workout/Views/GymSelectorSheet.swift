//
//  GymSelectorSheet.swift
//  GymAnals
//
//  Created on 27/01/2026.
//

import SwiftUI
import SwiftData

/// Sheet presenting list of gyms for selection
/// Updates lastUsedDate when a gym is selected
/// Includes "New Gym" button for inline gym creation with auto-select
struct GymSelectorSheet: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @Query(sort: \Gym.lastUsedDate, order: .reverse) private var gyms: [Gym]

    @Binding var selectedGym: Gym?
    let onManageGyms: () -> Void

    @State private var showingNewGymSheet = false
    /// Snapshot of gym count before creating a new gym, used for auto-select detection
    @State private var gymCountBeforeCreate = 0

    var body: some View {
        NavigationStack {
            List {
                Section {
                    Button {
                        gymCountBeforeCreate = gyms.count
                        showingNewGymSheet = true
                    } label: {
                        Label("New Gym", systemImage: "plus.circle.fill")
                    }
                }

                Section {
                    ForEach(gyms, id: \.id) { gym in
                        GymSelectorRow(
                            gym: gym,
                            isSelected: gym.id == selectedGym?.id,
                            onSelect: { selectGym(gym) }
                        )
                    }
                }

                Section {
                    Button {
                        dismiss()
                        onManageGyms()
                    } label: {
                        Label("Manage Gyms", systemImage: "gearshape")
                    }
                }
            }
            .navigationTitle("Select Gym")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showingNewGymSheet) {
                NavigationStack {
                    GymEditView()
                }
            }
            .onChange(of: showingNewGymSheet) { _, isShowing in
                if !isShowing {
                    // Auto-select newly created gym after sheet dismisses
                    autoSelectNewGym()
                }
            }
        }
    }

    private func selectGym(_ gym: Gym) {
        gym.lastUsedDate = Date.now
        selectedGym = gym
        dismiss()
    }

    /// Finds and selects the most recently created gym if a new one was added
    private func autoSelectNewGym() {
        guard gyms.count > gymCountBeforeCreate else { return }
        // Find the gym with the most recent createdDate
        if let newestGym = gyms.max(by: { $0.createdDate < $1.createdDate }) {
            selectGym(newestGym)
        }
    }
}

// MARK: - Subviews

private struct GymSelectorRow: View {
    let gym: Gym
    let isSelected: Bool
    let onSelect: () -> Void

    var body: some View {
        Button(action: onSelect) {
            HStack {
                Circle()
                    .fill(gym.colorTag.color)
                    .frame(width: 16, height: 16)

                Text(gym.name)

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark")
                        .foregroundStyle(.tint)
                }
            }
        }
        .foregroundStyle(.primary)
    }
}

#Preview {
    @Previewable @State var selectedGym: Gym?

    GymSelectorSheet(selectedGym: $selectedGym, onManageGyms: {})
        .modelContainer(PersistenceController.preview)
}
