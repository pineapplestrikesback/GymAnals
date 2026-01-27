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

    var body: some View {
        List {
            // Basic info section
            Section("Exercise Info") {
                LabeledContent("Name", value: exercise.displayName)

                if let equipment = exercise.equipment?.name {
                    LabeledContent("Equipment", value: equipment)
                }

                if let movement = exercise.variant?.movement {
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
                        let count = exercise.variant?.muscleWeights.count ?? 0
                        Text("\(count) muscles")
                            .foregroundStyle(.secondary)
                    }
                }

                // Quick preview of top muscles
                if let variant = exercise.variant {
                    let topMuscles = variant.muscleWeights
                        .sorted { $0.weight > $1.weight }
                        .prefix(3)

                    ForEach(Array(topMuscles)) { vm in
                        HStack {
                            Text(vm.muscle.displayName)
                                .font(.subheadline)
                            Spacer()
                            Text(String(format: "%.0f%%", vm.weight * 100))
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            } header: {
                Text("Muscle Targeting")
            }

            // Info section for built-in vs custom
            if !(exercise.variant?.isBuiltIn ?? true) {
                Section {
                    Label("Custom Exercise", systemImage: "person.fill")
                        .foregroundStyle(.secondary)
                }
            }
        }
        .navigationTitle(exercise.displayName)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            muscleViewModel = MuscleWeightViewModel(variant: exercise.variant)
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
