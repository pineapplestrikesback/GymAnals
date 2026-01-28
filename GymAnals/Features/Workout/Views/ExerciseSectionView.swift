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
    let weightUnit: WeightUnit

    var body: some View {
        DisclosureGroup(isExpanded: $isExpanded) {
            VStack(spacing: 0) {
                ForEach(sets) { workoutSet in
                    SetRowPlaceholder(
                        workoutSet: workoutSet,
                        weightUnit: weightUnit
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

// MARK: - Placeholder Set Row

/// Simplified set row placeholder until SetRowView is implemented in 04-03.
/// Displays set number, reps, weight, and basic layout.
private struct SetRowPlaceholder: View {
    let workoutSet: WorkoutSet
    let weightUnit: WeightUnit

    var body: some View {
        HStack(spacing: 16) {
            Text("\(workoutSet.setNumber)")
                .font(.headline)
                .foregroundStyle(.secondary)
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 2) {
                Text("\(workoutSet.reps)")
                    .font(.body.monospacedDigit())
                Text("reps")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
            .frame(width: 50)

            Text("x")
                .foregroundStyle(.secondary)

            VStack(alignment: .leading, spacing: 2) {
                Text(formatWeight(workoutSet.weight))
                    .font(.body.monospacedDigit())
                Text(weightUnit.abbreviation)
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
            .frame(width: 60)

            Spacer()

            Image(systemName: "checkmark.circle.fill")
                .font(.title2)
                .foregroundStyle(.green)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 10)
    }

    private func formatWeight(_ weight: Double) -> String {
        if weight.truncatingRemainder(dividingBy: 1) == 0 {
            return String(format: "%.0f", weight)
        }
        return String(format: "%.1f", weight)
    }
}
