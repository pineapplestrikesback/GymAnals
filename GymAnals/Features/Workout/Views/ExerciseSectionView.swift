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
        VStack(spacing: 0) {
            // Exercise header with swipe-to-delete
            exerciseHeaderRow

            // Expandable content
            if isExpanded {
                VStack(spacing: 0) {
                    // Sets list with swipe-to-delete
                    ForEach(sets) { workoutSet in
                        setRowWithSwipe(workoutSet)

                        if workoutSet.id != sets.last?.id {
                            Divider()
                                .padding(.leading, 32)
                        }
                    }

                    // Add Set button
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
                .padding(.leading, 16)
            }
        }
        .background(Color(.systemBackground))
    }

    // MARK: - Exercise Header with Swipe

    private var exerciseHeaderRow: some View {
        SwipeActionRow(
            onDelete: onDeleteExercise,
            deleteLabel: "Remove Exercise"
        ) {
            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                    isExpanded.toggle()
                }
            } label: {
                HStack(spacing: 12) {
                    Image(systemName: isExpanded ? "chevron.down" : "chevron.right")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                        .frame(width: 16)

                    VStack(alignment: .leading, spacing: 2) {
                        Text(exercise.displayName)
                            .font(.headline)
                            .foregroundStyle(.primary)

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
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .contentShape(Rectangle())
                .background(Color(.secondarySystemBackground))
            }
            .buttonStyle(.plain)
        }
    }

    // MARK: - Set Row with Swipe

    @ViewBuilder
    private func setRowWithSwipe(_ workoutSet: WorkoutSet) -> some View {
        SwipeActionRow(
            onDelete: { onDeleteSet(workoutSet) },
            deleteLabel: "Delete Set"
        ) {
            SetRowView(
                setNumber: workoutSet.setNumber,
                reps: repsBinding(workoutSet),
                weight: weightBinding(workoutSet),
                previousReps: previousReps(workoutSet),
                previousWeight: previousWeight(workoutSet),
                weightUnit: weightUnit,
                timer: timerForSet(workoutSet),
                isConfirmed: workoutSet.isConfirmed,
                onConfirm: { onConfirmSet(workoutSet) },
                onTimerTap: {
                    if let timer = timerForSet(workoutSet) {
                        onTimerTap(timer)
                    }
                },
                focusedField: $focusedField,
                setID: workoutSet.id
            )
        }
    }
}

// MARK: - Swipe Action Row Component

/// A generic swipe-to-delete row that works outside of List context.
/// Uses drag gesture to reveal delete button.
private struct SwipeActionRow<Content: View>: View {
    let onDelete: () -> Void
    let deleteLabel: String
    @ViewBuilder let content: Content

    @State private var offset: CGFloat = 0
    @State private var isSwiped = false

    private let deleteButtonWidth: CGFloat = 80

    var body: some View {
        ZStack(alignment: .trailing) {
            // Delete button (revealed on swipe)
            Button(role: .destructive) {
                withAnimation {
                    onDelete()
                    resetSwipe()
                }
            } label: {
                Image(systemName: "trash")
                    .font(.title3)
                    .foregroundStyle(.white)
                    .frame(width: deleteButtonWidth)
                    .frame(maxHeight: .infinity)
                    .background(Color.red)
            }
            .buttonStyle(.plain)

            // Main content
            content
                .offset(x: offset)
                .highPriorityGesture(
                    DragGesture(minimumDistance: 20)
                        .onChanged { value in
                            let translation = value.translation.width
                            if translation < 0 {
                                // Swiping left
                                offset = max(translation, -deleteButtonWidth)
                            } else if isSwiped {
                                // Swiping right when already swiped
                                offset = min(-deleteButtonWidth + translation, 0)
                            }
                        }
                        .onEnded { value in
                            withAnimation(.easeOut(duration: 0.2)) {
                                if value.translation.width < -40 {
                                    // Swipe past threshold - reveal delete
                                    offset = -deleteButtonWidth
                                    isSwiped = true
                                } else {
                                    // Reset
                                    resetSwipe()
                                }
                            }
                        }
                )
        }
        .clipped()
    }

    private func resetSwipe() {
        offset = 0
        isSwiped = false
    }
}
