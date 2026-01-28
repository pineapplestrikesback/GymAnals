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

    @State private var muscleViewModel: MuscleWeightViewModel?

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

    var body: some View {
        List {
            // Basic info section
            Section("Exercise Info") {
                LabeledContent("Name", value: exercise.displayName)

                if let equipment = exercise.equipment?.displayName {
                    LabeledContent("Equipment", value: equipment)
                }

                if let movement = exercise.movement {
                    LabeledContent("Type", value: movement.exerciseType.displayName)
                }

                Toggle("Favorite", isOn: favoriteBinding)
            }

            // Muscle targeting section
            Section {
                NavigationLink {
                    if let viewModel = muscleViewModel {
                        MuscleWeightEditorView(viewModel: viewModel)
                    }
                } label: {
                    HStack {
                        Text("Muscle Weights")
                        Spacer()
                        let count = exercise.muscleWeights.count
                        Text("\(count) muscles")
                            .foregroundStyle(.secondary)
                    }
                }

                // Quick preview of top muscles
                let topMuscles = exercise.sortedMuscleWeights.prefix(3)

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

            // Info section for built-in vs custom
            if !exercise.isBuiltIn {
                Section {
                    Label("Custom Exercise", systemImage: "person.fill")
                        .foregroundStyle(.secondary)
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
        .onAppear {
            muscleViewModel = MuscleWeightViewModel(exercise: exercise)
        }
    }

    private var favoriteBinding: Binding<Bool> {
        Binding(
            get: { exercise.isFavorite },
            set: { newValue in
                exercise.isFavorite = newValue
                try? modelContext.save()
            }
        )
    }
}

#Preview {
    NavigationStack {
        ExerciseDetailView(exercise: Exercise())
    }
    .modelContainer(PersistenceController.preview)
}
