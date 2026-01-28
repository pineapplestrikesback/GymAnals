//
//  ExerciseRow.swift
//  GymAnals
//
//  Created on 27/01/2026.
//

import SwiftUI

/// A row displaying exercise information in a list
struct ExerciseRow: View {
    let exercise: Exercise

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(exercise.displayName)
                    .font(.body)

                HStack(spacing: 6) {
                    if let equipment = exercise.equipment?.displayName {
                        Text(equipment)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    if exercise.equipment != nil, exercise.primaryMuscleGroup != nil {
                        Text("\u{2022}")
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                    }

                    if let muscles = exercise.primaryMuscleGroup?.displayName {
                        Text(muscles)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }

            Spacer()

            if exercise.isFavorite {
                Image(systemName: "star.fill")
                    .foregroundStyle(.yellow)
                    .font(.caption)
            }

            if let category = exercise.movement?.category {
                Text(category.displayName)
                    .font(.caption2)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color.accentColor.opacity(0.1))
                    .clipShape(Capsule())
            }

            if !exercise.isBuiltIn {
                Text("Custom")
                    .font(.caption2)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color.blue.opacity(0.1))
                    .clipShape(Capsule())
            }
        }
        .contentShape(Rectangle())
    }
}
