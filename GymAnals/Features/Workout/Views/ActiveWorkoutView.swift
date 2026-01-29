//
//  ActiveWorkoutView.swift
//  GymAnals
//
//  Created on 28/01/2026.
//

import SwiftData
import SwiftUI

/// The main active workout view containing the sticky header, exercise sections, FAB, and finish/discard flow.
/// This is the primary view users interact with during a workout session.
struct ActiveWorkoutView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State var viewModel: ActiveWorkoutViewModel
    @State var timerManager: SetTimerManager

    @State private var showingExercisePicker = false
    @State private var showingTimerControls = false
    @State private var showingFinishConfirmation = false
    @State private var showingDiscardConfirmation = false
    @State private var selectedTimerForControls: SetTimer?

    @FocusState private var focusedField: SetEntryField?

    @AppStorage("weightUnit") private var weightUnit: WeightUnit = .kilograms
    @AppStorage("defaultRestDuration") private var defaultRestDuration: Double = AppConstants.defaultRestDuration

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            ScrollView {
                LazyVStack(spacing: 0, pinnedViews: [.sectionHeaders]) {
                    Section {
                        // Exercise sections
                        ForEach(viewModel.exerciseOrder, id: \.self) { exerciseID in
                            ExerciseSectionForID(
                                exerciseID: exerciseID,
                                viewModel: viewModel,
                                weightUnit: weightUnit,
                                timerManager: timerManager,
                                focusedField: $focusedField,
                                onConfirmSet: { workoutSet in
                                    handleSetConfirmation(workoutSet)
                                },
                                onTimerTap: { timer in
                                    selectedTimerForControls = timer
                                    showingTimerControls = true
                                }
                            )
                        }

                        // Empty state if no exercises
                        if viewModel.exerciseOrder.isEmpty {
                            emptyStateView
                        }

                        // Finish Workout button at bottom
                        if !viewModel.exerciseOrder.isEmpty {
                            finishWorkoutButton
                        }

                        // Bottom padding for FAB clearance
                        Spacer()
                            .frame(height: 80)

                    } header: {
                        WorkoutHeader(
                            startDate: viewModel.activeWorkout?.startDate ?? .now,
                            totalSets: viewModel.activeWorkout?.sets.count ?? 0,
                            headerTimer: timerManager.headerTimer,
                            gym: viewModel.activeWorkout?.gym,
                            defaultRestDuration: defaultRestDuration,
                            onTimerTap: {
                                if let timer = timerManager.headerTimer {
                                    selectedTimerForControls = timer
                                    showingTimerControls = true
                                }
                            },
                            onStartManualTimer: {
                                timerManager.removeExpiredTimers()
                                timerManager.startTimer(for: UUID(), duration: 120)
                            }
                        )
                    }
                }
            }

            // Floating action button
            AddExerciseFAB {
                showingExercisePicker = true
            }
            .padding()
        }
        .navigationTitle("Workout")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Button(role: .destructive) {
                        showingDiscardConfirmation = true
                    } label: {
                        Label("Discard Workout", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .sheet(isPresented: $showingExercisePicker) {
            ExercisePickerSheet { exercises in
                withAnimation {
                    for exercise in exercises {
                        viewModel.addExercise(exercise)
                        // Auto-add first set for each exercise
                        viewModel.addSet(for: exercise)
                    }
                }
            }
        }
        .sheet(isPresented: $showingTimerControls) {
            if let timer = selectedTimerForControls {
                TimerControlsSheet(
                    timer: timer,
                    onSkip: {
                        timerManager.skipTimer(timer)
                    },
                    onAdjustTimer: { delta in
                        _ = timerManager.adjustTimer(timer, by: delta)
                    },
                    onDismiss: {
                        showingTimerControls = false
                    }
                )
            }
        }
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Button {
                    adjustFocusedField(by: -1)
                } label: {
                    Image(systemName: "minus")
                }
                Button {
                    adjustFocusedField(by: 1)
                } label: {
                    Image(systemName: "plus")
                }
                Spacer()
                Button("Done") {
                    focusedField = nil
                }
            }
        }
        .confirmationDialog(
            "Finish Workout?",
            isPresented: $showingFinishConfirmation,
            titleVisibility: .visible
        ) {
            Button("Finish Workout") {
                viewModel.finishWorkout()
                timerManager.cancelAllTimers()
                dismiss()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This will save your workout and end the session.")
        }
        .confirmationDialog(
            "Discard Workout?",
            isPresented: $showingDiscardConfirmation,
            titleVisibility: .visible
        ) {
            Button("Discard", role: .destructive) {
                viewModel.discardWorkout()
                timerManager.cancelAllTimers()
                dismiss()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This will delete all sets and cannot be undone.")
        }
    }

    // MARK: - Subviews

    private var emptyStateView: some View {
        ContentUnavailableView(
            "No Exercises",
            systemImage: "figure.strengthtraining.traditional",
            description: Text("Tap the + button to add exercises to your workout")
        )
        .padding(.top, 60)
    }

    private var finishWorkoutButton: some View {
        Button {
            showingFinishConfirmation = true
        } label: {
            Label("Finish Workout", systemImage: "checkmark.circle")
                .font(.headline)
        }
        .buttonStyle(.borderedProminent)
        .controlSize(.large)
        .padding(.vertical, 24)
    }

    // MARK: - Actions

    /// Adjusts the currently focused field's value by the given delta.
    /// Weight fields adjust by 1.0, reps fields adjust by 1.
    private func adjustFocusedField(by delta: Int) {
        guard let field = focusedField,
              let workout = viewModel.activeWorkout else { return }

        switch field {
        case .weight(let setID):
            if let workoutSet = workout.sets.first(where: { $0.id == setID }) {
                workoutSet.weight = max(0, min(999, workoutSet.weight + Double(delta)))
            }
        case .reps(let setID):
            if let workoutSet = workout.sets.first(where: { $0.id == setID }) {
                workoutSet.reps = max(0, min(999, workoutSet.reps + delta))
            }
        }
    }

    private func handleSetConfirmation(_ workoutSet: WorkoutSet) {
        guard let exercise = workoutSet.exercise else { return }

        // Toggle confirmation state
        if workoutSet.isConfirmed {
            // Unconfirming: remove timer for this set
            workoutSet.isConfirmed = false
            timerManager.removeTimer(forSetID: workoutSet.id)
        } else {
            // Confirming: mark as complete and start timer
            workoutSet.isConfirmed = true
            workoutSet.completedDate = .now

            // Update exercise last used date
            exercise.lastUsedDate = .now

            // Start timer if auto-start is enabled
            if exercise.autoStartTimer {
                timerManager.removeExpiredTimers()
                let effectiveDefault = defaultRestDuration
                if effectiveDefault > 0 {
                    let duration = exercise.restDuration == AppConstants.defaultRestDuration
                        ? effectiveDefault
                        : exercise.restDuration
                    timerManager.startTimer(for: workoutSet.id, duration: duration)
                }
            }
        }
    }
}

// MARK: - Exercise Section Helper View

/// Wrapper view to fetch Exercise by ID and display ExerciseSectionView.
/// Uses modelContext fetch since SwiftData @Query can't dynamically filter by ID.
private struct ExerciseSectionForID: View {
    let exerciseID: String
    let viewModel: ActiveWorkoutViewModel
    let weightUnit: WeightUnit
    let timerManager: SetTimerManager
    @FocusState.Binding var focusedField: SetEntryField?
    let onConfirmSet: (WorkoutSet) -> Void
    let onTimerTap: (SetTimer) -> Void

    @Environment(\.modelContext) private var modelContext

    var body: some View {
        if let exercise = fetchExercise() {
            let sets = viewModel.setsForExercise(exercise)

            ExerciseSectionView(
                exercise: exercise,
                sets: sets,
                isExpanded: Binding(
                    get: { viewModel.expandedExercises.contains(exerciseID) },
                    set: { isExpanded in
                        if isExpanded {
                            viewModel.expandedExercises.insert(exerciseID)
                        } else {
                            viewModel.expandedExercises.remove(exerciseID)
                        }
                    }
                ),
                onDeleteSet: { set in
                    viewModel.deleteSet(set)
                },
                onAddSet: {
                    viewModel.addSet(for: exercise)
                },
                onDeleteExercise: {
                    viewModel.removeExercise(exercise)
                },
                repsBinding: { workoutSet in
                    Binding(
                        get: { workoutSet.reps },
                        set: { workoutSet.reps = $0 }
                    )
                },
                weightBinding: { workoutSet in
                    Binding(
                        get: { workoutSet.weight },
                        set: { workoutSet.weight = $0 }
                    )
                },
                previousReps: { workoutSet in
                    viewModel.previousSetForRow(exercise: exercise, setNumber: workoutSet.setNumber)?.reps
                },
                previousWeight: { workoutSet in
                    viewModel.previousSetForRow(exercise: exercise, setNumber: workoutSet.setNumber)?.weight
                },
                onConfirmSet: { workoutSet in
                    onConfirmSet(workoutSet)
                },
                timerForSet: { setID in
                    timerManager.activeTimers.first { $0.setID == setID && !$0.isExpired }
                },
                onTimerTap: { timer in
                    onTimerTap(timer)
                },
                focusedField: $focusedField,
                weightUnit: weightUnit
            )
        }
    }

    private func fetchExercise() -> Exercise? {
        let descriptor = FetchDescriptor<Exercise>(
            predicate: #Predicate { $0.id == exerciseID }
        )
        return try? modelContext.fetch(descriptor).first
    }
}

#Preview {
    NavigationStack {
        ActiveWorkoutView(
            viewModel: ActiveWorkoutViewModel(modelContext: PersistenceController.preview.mainContext),
            timerManager: SetTimerManager()
        )
        .modelContainer(PersistenceController.preview)
    }
}
