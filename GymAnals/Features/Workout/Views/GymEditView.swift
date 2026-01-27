//
//  GymEditView.swift
//  GymAnals
//
//  Created on 27/01/2026.
//

import SwiftUI
import SwiftData

/// Form view for creating or editing a gym
struct GymEditView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var name: String
    @State private var colorTag: GymColor

    /// The gym being edited, or nil when creating a new gym
    let gym: Gym?

    init(gym: Gym? = nil) {
        self.gym = gym
        _name = State(initialValue: gym?.name ?? "")
        _colorTag = State(initialValue: gym?.colorTag ?? .blue)
    }

    private var canSave: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty
    }

    private var isDefaultGym: Bool {
        gym?.isDefault ?? false
    }

    var body: some View {
        Form {
            Section {
                if isDefaultGym {
                    // Default gym name is fixed
                    HStack {
                        Text("Gym Name")
                            .foregroundStyle(.secondary)
                        Spacer()
                        Text(name)
                    }
                } else {
                    TextField("Gym Name", text: $name)
                }
            }

            Section {
                GymColorPicker(selectedColor: $colorTag)
            }
        }
        .navigationTitle(gym == nil ? "New Gym" : "Edit Gym")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
                    dismiss()
                }
            }

            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    save()
                }
                .disabled(!canSave)
            }
        }
    }

    private func save() {
        if let gym {
            // Update existing gym
            if !gym.isDefault {
                gym.name = name.trimmingCharacters(in: .whitespaces)
            }
            gym.colorTag = colorTag
        } else {
            // Create new gym
            let newGym = Gym(
                name: name.trimmingCharacters(in: .whitespaces),
                colorTag: colorTag
            )
            modelContext.insert(newGym)
        }

        try? modelContext.save()
        dismiss()
    }
}

#Preview("New Gym") {
    NavigationStack {
        GymEditView()
    }
    .modelContainer(PersistenceController.preview)
}

#Preview("Edit Gym") {
    let container = PersistenceController.preview
    let gym = Gym(name: "Home Gym", colorTag: .green)
    container.mainContext.insert(gym)

    return NavigationStack {
        GymEditView(gym: gym)
    }
    .modelContainer(container)
}
