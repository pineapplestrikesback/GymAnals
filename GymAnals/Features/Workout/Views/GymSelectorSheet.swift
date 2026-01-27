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
struct GymSelectorSheet: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @Query(sort: \Gym.lastUsedDate, order: .reverse) private var gyms: [Gym]

    @Binding var selectedGym: Gym?
    let onManageGyms: () -> Void

    var body: some View {
        NavigationStack {
            List {
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
        }
    }

    private func selectGym(_ gym: Gym) {
        gym.lastUsedDate = Date.now
        selectedGym = gym
        dismiss()
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
