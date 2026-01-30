//
//  ExerciseCreationWizard.swift
//  GymAnals
//
//  Created on 27/01/2026.
//

import SwiftUI
import SwiftData

/// Multi-step wizard for creating custom exercises
struct ExerciseCreationWizard: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var viewModel = ExerciseCreationViewModel()
    @State private var muscleWeightVM: MuscleWeightViewModel?
    @State private var creationFailed = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Progress dots
                HStack(spacing: 8) {
                    ForEach(0..<viewModel.steps.count, id: \.self) { index in
                        Circle()
                            .fill(index <= viewModel.currentStep ? Color.accentColor : Color.secondary.opacity(0.3))
                            .frame(width: 8, height: 8)
                    }
                }
                .padding(.vertical, 12)

                // Step label
                Text(viewModel.steps[viewModel.currentStep])
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.bottom, 8)

                Divider()

                // Step content
                Group {
                    switch viewModel.currentStep {
                    case 0:
                        MovementStepView(viewModel: viewModel)
                    case 1:
                        ExerciseNameStepView(viewModel: viewModel)
                    case 2:
                        EquipmentStepView(viewModel: viewModel)
                    case 3:
                        ExerciseTypeStepView(viewModel: viewModel)
                    case 4:
                        // Final step: create and show muscle editor
                        if let muscleVM = muscleWeightVM {
                            MuscleWeightEditorView(viewModel: muscleVM)
                        } else if creationFailed {
                            VStack(spacing: 16) {
                                Image(systemName: "exclamationmark.circle.fill")
                                    .font(.system(size: 48))
                                    .foregroundStyle(.red)
                                Text("Failed to create exercise")
                                    .font(.headline)
                                Text("An error occurred while creating the exercise. Please try again or cancel.")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                                    .multilineTextAlignment(.center)

                                HStack(spacing: 12) {
                                    Button("Cancel") {
                                        dismiss()
                                    }
                                    .buttonStyle(.bordered)

                                    Button("Try Again") {
                                        creationFailed = false
                                        if let exercise = viewModel.createExercise(context: modelContext) {
                                            muscleWeightVM = MuscleWeightViewModel(exercise: exercise, startInEditMode: true)
                                        } else {
                                            creationFailed = true
                                        }
                                    }
                                    .buttonStyle(.borderedProminent)
                                }
                            }
                            .padding()
                        } else {
                            ProgressView("Creating exercise...")
                                .onAppear {
                                    if let exercise = viewModel.createExercise(context: modelContext) {
                                        muscleWeightVM = MuscleWeightViewModel(exercise: exercise, startInEditMode: true)
                                    } else {
                                        creationFailed = true
                                    }
                                }
                        }
                    default:
                        EmptyView()
                    }
                }
                .frame(maxHeight: .infinity)

                Divider()

                // Navigation buttons
                HStack {
                    if viewModel.currentStep > 0 {
                        Button("Back") {
                            viewModel.previousStep()
                        }
                        .buttonStyle(.bordered)
                    }

                    Spacer()

                    if viewModel.currentStep < viewModel.steps.count - 1 {
                        Button("Next") {
                            viewModel.nextStep()
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(!viewModel.canProceed)
                    } else {
                        Button("Done") {
                            dismiss()
                        }
                        .buttonStyle(.borderedProminent)
                    }
                }
                .padding()
            }
            .navigationTitle("New Exercise")
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
}

#Preview {
    ExerciseCreationWizard()
        .modelContainer(PersistenceController.preview)
}
