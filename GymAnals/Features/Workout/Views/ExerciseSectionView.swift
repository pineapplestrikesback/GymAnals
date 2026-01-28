//
//  ExerciseSectionView.swift
//  GymAnals
//
//  Created on 28/01/2026.
//

import SwiftUI

/// A collapsible section displaying an exercise with its sets in the active workout.
/// Provides swipe-to-delete on individual sets and the entire exercise, plus an "Add Set" button.
struct ExerciseSectionView: View {
    let exercise: Exercise
    let sets: [WorkoutSet]
    @Binding var isExpanded: Bool
    let onDeleteSet: (WorkoutSet) -> Void
    let onAddSet: () -> Void
    let onDeleteExercise: () -> Void

    // For SetRowView bindings
    let repsBinding: (WorkoutSet) -> Binding<Int>
    let weightBinding: (WorkoutSet) -> Binding<Double>
    let previousReps: (WorkoutSet) -> Int?
    let previousWeight: (WorkoutSet) -> Double?
    let timerForSet: (WorkoutSet) -> SetTimer?
    let onConfirmSet: (WorkoutSet) -> Void
    let onTimerTap: (SetTimer) -> Void

    @FocusState.Binding var focusedField: SetEntryField?
    let weightUnit: WeightUnit

    var body: some View {
        DisclosureGroup(isExpanded: $isExpanded) {
            VStack(spacing: 0) {
                ForEach(sets) { workoutSet in
                    SetRowView(
                        setNumber: workoutSet.setNumber,
                        reps: repsBinding(workoutSet),
                        weight: weightBinding(workoutSet),
                        previousReps: previousReps(workoutSet),
                        previousWeight: previousWeight(workoutSet),
                        weightUnit: weightUnit,
                        timer: timerForSet(workoutSet),
                        onConfirm: { onConfirmSet(workoutSet) },
                        onTimerTap: {
                            if let timer = timerForSet(workoutSet) {
                                onTimerTap(timer)
                            }
                        },
                        focusedField: $focusedField,
                        setID: workoutSet.id
                    )
                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                        Button(role: .destructive) {
                            onDeleteSet(workoutSet)
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }

                    if workoutSet.id != sets.last?.id {
                        Divider()
                            .padding(.leading, 32)
                    }
                }

                Button {
                    onAddSet()
                } label: {
                    Label("Add Set", systemImage: "plus")
                        .font(.subheadline)
                        .foregroundStyle(.tint)
                }
                .buttonStyle(.plain)
                .padding(.vertical, 12)
            }
        } label: {
            exerciseHeader
        }
        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
            Button(role: .destructive) {
                onDeleteExercise()
            } label: {
                Label("Remove", systemImage: "trash")
            }
        }
    }

    private var exerciseHeader: some View {
        HStack(spacing: 12) {
            Image(systemName: "line.3.horizontal")
                .font(.caption)
                .foregroundStyle(.tertiary)

            VStack(alignment: .leading, spacing: 2) {
                Text(exercise.displayName)
                    .font(.headline)

                if let muscle = exercise.variant?.primaryMuscleGroup {
                    Text(muscle.displayName)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            if !sets.isEmpty {
                Text("\(sets.count) \(sets.count == 1 ? "set" : "sets")")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .contentShape(Rectangle())
    }
}
