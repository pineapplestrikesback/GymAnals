//
//  CustomExerciseEditView.swift
//  GymAnals
//
//  Created on 28/01/2026.
//

import SwiftUI
import SwiftData

/// Form-based editor for custom exercise properties (name, equipment, movement, timer, notes)
struct CustomExerciseEditView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    let exercise: Exercise

    @State private var displayName: String
    @State private var notes: String
    @State private var restDuration: TimeInterval
    @State private var autoStartTimer: Bool
    @State private var selectedEquipment: Equipment?
    @State private var selectedMovement: Movement?

    init(exercise: Exercise) {
        self.exercise = exercise
        _displayName = State(initialValue: exercise.displayName)
        _notes = State(initialValue: exercise.notes)
        _restDuration = State(initialValue: exercise.restDuration)
        _autoStartTimer = State(initialValue: exercise.autoStartTimer)
        _selectedEquipment = State(initialValue: exercise.equipment)
        _selectedMovement = State(initialValue: exercise.movement)
    }

    private var restDurationSeconds: Int {
        Int(restDuration)
    }

    private var canSave: Bool {
        !displayName.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var body: some View {
        Form {
            // Name section
            Section("Name") {
                TextField("Exercise Name", text: $displayName)
            }

            // Classification section
            Section("Classification") {
                NavigationLink {
                    EquipmentPickerList(selection: $selectedEquipment)
                } label: {
                    HStack {
                        Text("Equipment")
                        Spacer()
                        Text(selectedEquipment?.displayName ?? "None")
                            .foregroundStyle(.secondary)
                    }
                }

                NavigationLink {
                    MovementPickerList(selection: $selectedMovement)
                } label: {
                    HStack {
                        Text("Movement")
                        Spacer()
                        Text(selectedMovement?.displayName ?? "None")
                            .foregroundStyle(.secondary)
                    }
                }
            }

            // Timer Settings section
            Section("Timer Settings") {
                Stepper(
                    "Rest Duration: \(restDurationSeconds)s",
                    value: $restDuration,
                    in: 30...300,
                    step: 15
                )

                Toggle("Auto-start Timer", isOn: $autoStartTimer)
            }

            // Notes section
            Section("Notes") {
                TextEditor(text: $notes)
                    .frame(minHeight: 80)
            }
        }
        .navigationTitle("Edit Exercise")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
                    dismiss()
                }
            }

            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    saveChanges()
                }
                .disabled(!canSave)
            }
        }
    }

    private func saveChanges() {
        exercise.displayName = displayName.trimmingCharacters(in: .whitespaces)
        exercise.notes = notes
        exercise.restDuration = restDuration
        exercise.autoStartTimer = autoStartTimer
        exercise.equipment = selectedEquipment
        exercise.movement = selectedMovement
        do {
            try modelContext.save()
            dismiss()
        } catch {
            print("Failed to save exercise: \(error)")
        }
    }
}

// MARK: - Equipment Picker

/// List of all equipment for selection in the edit form
private struct EquipmentPickerList: View {
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \Equipment.displayName) private var allEquipment: [Equipment]
    @Binding var selection: Equipment?

    var body: some View {
        List {
            // Allow clearing equipment selection
            Button {
                selection = nil
                dismiss()
            } label: {
                HStack {
                    Text("None")
                        .foregroundStyle(.primary)
                    Spacer()
                    if selection == nil {
                        Image(systemName: "checkmark")
                            .foregroundStyle(.tint)
                    }
                }
            }

            ForEach(allEquipment) { equipment in
                Button {
                    selection = equipment
                    dismiss()
                } label: {
                    HStack {
                        Text(equipment.displayName)
                            .foregroundStyle(.primary)
                        Spacer()
                        if selection?.id == equipment.id {
                            Image(systemName: "checkmark")
                                .foregroundStyle(.tint)
                        }
                    }
                }
            }
        }
        .navigationTitle("Select Equipment")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Movement Picker

/// List of all movements for selection in the edit form
private struct MovementPickerList: View {
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \Movement.displayName) private var allMovements: [Movement]
    @Binding var selection: Movement?

    var body: some View {
        List {
            // Allow clearing movement selection
            Button {
                selection = nil
                dismiss()
            } label: {
                HStack {
                    Text("None")
                        .foregroundStyle(.primary)
                    Spacer()
                    if selection == nil {
                        Image(systemName: "checkmark")
                            .foregroundStyle(.tint)
                    }
                }
            }

            ForEach(allMovements) { movement in
                Button {
                    selection = movement
                    dismiss()
                } label: {
                    HStack {
                        Text(movement.displayName)
                            .foregroundStyle(.primary)
                        Spacer()
                        if selection?.id == movement.id {
                            Image(systemName: "checkmark")
                                .foregroundStyle(.tint)
                        }
                    }
                }
            }
        }
        .navigationTitle("Select Movement")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        CustomExerciseEditView(exercise: Exercise(displayName: "Custom Test Exercise"))
    }
    .modelContainer(PersistenceController.preview)
}
