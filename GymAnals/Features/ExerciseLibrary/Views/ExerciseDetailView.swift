//
//  ExerciseDetailView.swift
//  GymAnals
//
//  Created on 27/01/2026.
//

import SwiftUI
import SwiftData

/// Detail view for a single exercise showing info and muscle targeting
struct ExerciseDetailView: View {
    @Environment(\.modelContext) private var modelContext
    let exercise: Exercise

    @State private var showingMuscleEditor = false

    /// Groups weight history by gym for branch display
    private var gymBranches: [(gym: Gym, entryCount: Int)] {
        // Group weight history by gym
        let grouped = Dictionary(grouping: exercise.weightHistory) { $0.gym }

        // Filter out entries with nil gym using compactMap.
        // nil gym records exist when user chose "Delete Gym, Keep History" -
        // this is valid orphaned history but should NOT appear as a "branch"
        // since there's no gym to display it under.
        return grouped.compactMap { gym, entries in
            guard let gym = gym else { return nil }
            return (gym: gym, entryCount: entries.count)
        }
        .sorted {
            ($0.gym.lastUsedDate ?? .distantPast) > ($1.gym.lastUsedDate ?? .distantPast)
        }
    }

    /// Non-empty dimensions for display
    private var activeDimensions: [(label: String, value: String)] {
        var dims: [(String, String)] = []
        let d = exercise.dimensions
        if !d.angle.isEmpty { dims.append(("Angle", d.angle.replacingOccurrences(of: "_", with: " ").capitalized)) }
        if !d.gripWidth.isEmpty { dims.append(("Grip Width", d.gripWidth.capitalized)) }
        if !d.gripOrientation.isEmpty { dims.append(("Grip", d.gripOrientation.capitalized)) }
        if !d.stance.isEmpty { dims.append(("Stance", d.stance.replacingOccurrences(of: "_", with: " ").capitalized)) }
        if !d.laterality.isEmpty { dims.append(("Laterality", d.laterality.capitalized)) }
        return dims
    }

    var body: some View {
        List {
            // Basic info section
            Section("Exercise Info") {
                LabeledContent("Name", value: exercise.displayName)

                if let equipment = exercise.equipment?.displayName {
                    LabeledContent("Equipment", value: equipment)
                }

                if let movement = exercise.movement {
                    LabeledContent("Movement", value: movement.displayName)
                    LabeledContent("Category", value: movement.category.displayName)
                    LabeledContent("Type", value: movement.exerciseType.displayName)
                }

                LabeledContent("Popularity", value: exercise.popularity.displayName)

                if exercise.isUnilateral {
                    LabeledContent("Unilateral", value: "Yes")
                }
            }

            // Dimensions section (only show if exercise has non-empty dimensions)
            if !exercise.dimensions.isEmpty {
                Section("Dimensions") {
                    ForEach(activeDimensions, id: \.label) { dim in
                        LabeledContent(dim.label, value: dim.value)
                    }
                }
            }

            // Muscle targeting section
            Section {
                if !exercise.isBuiltIn {
                    Button {
                        showingMuscleEditor = true
                    } label: {
                        HStack {
                            Text("Edit Muscle Weights")
                            Spacer()
                            let count = exercise.muscleWeights.count
                            Text("\(count) muscles")
                                .foregroundStyle(.secondary)
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundStyle(.tertiary)
                        }
                    }
                    .tint(.primary)
                } else {
                    HStack {
                        Text("Muscle Weights")
                        Spacer()
                        let count = exercise.muscleWeights.count
                        Text("\(count) muscles")
                            .foregroundStyle(.secondary)
                    }
                }

                // Quick preview of top muscles
                let topMuscles = exercise.sortedMuscleWeights.prefix(5)

                ForEach(Array(topMuscles), id: \.muscle) { entry in
                    HStack {
                        Text(entry.muscle.displayName)
                            .font(.subheadline)
                        Spacer()
                        Text(String(format: "%.0f%%", entry.weight * 100))
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
            } header: {
                Text("Muscle Targeting")
            }

            // Timer settings section
            Section("Timer Settings") {
                LabeledContent("Rest Duration", value: "\(Int(exercise.restDuration))s")
                LabeledContent("Auto-start Timer", value: exercise.autoStartTimer ? "On" : "Off")
            }

            // Notes section
            if !exercise.notes.isEmpty {
                Section("Notes") {
                    Text(exercise.notes)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }

            // Sources section
            if !exercise.sources.isEmpty {
                Section("Sources") {
                    ForEach(exercise.sources, id: \.self) { source in
                        Text(source)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }

            // Info section for built-in vs custom
            if exercise.isBuiltIn {
                Section {
                    Label("Built-in Exercise (read-only)", systemImage: "lock.fill")
                        .foregroundStyle(.secondary)
                        .font(.subheadline)
                }
            } else {
                Section {
                    Label("Custom Exercise", systemImage: "person.fill")
                        .foregroundStyle(.secondary)
                        .font(.subheadline)
                }
            }

            // Gym branches section - shows which gyms have weight history for this exercise
            if !gymBranches.isEmpty {
                Section("Weight History by Gym") {
                    ForEach(gymBranches, id: \.gym.id) { branch in
                        HStack {
                            Circle()
                                .fill(branch.gym.colorTag.color)
                                .frame(width: 12, height: 12)
                            Text(branch.gym.name)
                            Spacer()
                            Text("\(branch.entryCount) \(branch.entryCount == 1 ? "entry" : "entries")")
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
        }
        .navigationTitle(exercise.displayName)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    exercise.isFavorite.toggle()
                    try? modelContext.save()
                } label: {
                    Image(systemName: exercise.isFavorite ? "star.fill" : "star")
                        .foregroundStyle(exercise.isFavorite ? .yellow : .gray)
                }
            }
        }
        .sheet(isPresented: $showingMuscleEditor) {
            NavigationStack {
                MuscleWeightEditorView(viewModel: MuscleWeightViewModel(exercise: exercise))
            }
        }
    }
}

#Preview {
    NavigationStack {
        ExerciseDetailView(exercise: Exercise())
    }
    .modelContainer(PersistenceController.preview)
}
