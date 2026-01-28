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

                if let muscles = exercise.primaryMuscleGroup?.displayName {
                    Text(muscles)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            if exercise.isFavorite {
                Image(systemName: "star.fill")
                    .foregroundStyle(.yellow)
                    .font(.caption)
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
