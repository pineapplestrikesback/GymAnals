//
//  MuscleWeightEditorView.swift
//  GymAnals
//
//  Created on 27/01/2026.
//

import SwiftUI
import SwiftData

/// List-based editor for viewing and editing muscle weights with collapsible groups
struct MuscleWeightEditorView: View {
    @Environment(\.modelContext) private var modelContext
    @Bindable var viewModel: MuscleWeightViewModel
    @State private var expandedGroups: Set<MuscleGroup> = []

    var body: some View {
        List {
            // Assigned muscles section (muscles with weight > 0)
            let assigned = viewModel.weights.filter { $0.value > 0 }.sorted { $0.value > $1.value }
            if !assigned.isEmpty {
                Section("Targeted Muscles") {
                    ForEach(assigned, id: \.key) { muscle, _ in
                        MuscleSlider(
                            muscle: muscle,
                            value: binding(for: muscle),
                            isEditing: viewModel.isEditing
                        )
                    }
                }
            }

            // Collapsible muscle groups for adding new muscles
            ForEach(MuscleGroup.allCases) { group in
                Section(isExpanded: expandedBinding(for: group)) {
                    ForEach(group.muscles) { muscle in
                        MuscleSlider(
                            muscle: muscle,
                            value: binding(for: muscle),
                            isEditing: viewModel.isEditing
                        )
                    }
                } header: {
                    HStack {
                        Text(group.displayName)
                        Spacer()
                        let groupTotal = group.muscles.reduce(0.0) { $0 + (viewModel.weights[$1] ?? 0) }
                        if groupTotal > 0 {
                            Text(String(format: "%.1f", groupTotal))
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                if viewModel.isEditing {
                    Button("Done") {
                        viewModel.saveChanges(context: modelContext)
                    }
                } else {
                    Button("Edit") {
                        viewModel.isEditing = true
                    }
                }
            }

            if viewModel.isEditing && viewModel.hasChanges {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        viewModel.discardChanges()
                    }
                }
            }
        }
        .navigationTitle("Muscle Weights")
        .interactiveDismissDisabled(viewModel.hasChanges)
    }

    private func binding(for muscle: Muscle) -> Binding<Double> {
        Binding(
            get: { viewModel.weights[muscle] ?? 0 },
            set: { viewModel.updateWeight(muscle: muscle, weight: $0) }
        )
    }

    private func expandedBinding(for group: MuscleGroup) -> Binding<Bool> {
        Binding(
            get: { expandedGroups.contains(group) },
            set: { isExpanded in
                if isExpanded {
                    expandedGroups.insert(group)
                } else {
                    expandedGroups.remove(group)
                }
            }
        )
    }
}

#Preview {
    NavigationStack {
        MuscleWeightEditorView(viewModel: MuscleWeightViewModel(exercise: nil))
    }
    .modelContainer(PersistenceController.preview)
}
