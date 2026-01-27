//
//  ExerciseTypeStepView.swift
//  GymAnals
//
//  Created on 27/01/2026.
//

import SwiftUI

/// Step 4: Exercise type selection (determines logging fields)
struct ExerciseTypeStepView: View {
    @Bindable var viewModel: ExerciseCreationViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("What do you log?")
                .font(.headline)

            Text("This determines which fields appear when logging sets")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            List {
                exerciseTypeRow(.weightReps)
                exerciseTypeRow(.bodyweightReps)
                exerciseTypeRow(.weightedBodyweight)
                exerciseTypeRow(.assistedBodyweight)
                exerciseTypeRow(.duration)
                exerciseTypeRow(.durationWeight)
                exerciseTypeRow(.distanceDuration)
                exerciseTypeRow(.weightDistance)
            }
            .listStyle(.plain)
        }
        .padding()
    }

    @ViewBuilder
    private func exerciseTypeRow(_ type: ExerciseType) -> some View {
        HStack {
            VStack(alignment: .leading) {
                Text(type.displayName)
                    .font(.body)
                Text(type.logFields.map { $0.rawValue.capitalized }.joined(separator: " + "))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            if viewModel.selectedExerciseType == type {
                Image(systemName: "checkmark")
                    .foregroundStyle(Color.accentColor)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            viewModel.selectedExerciseType = type
        }
    }
}

#Preview {
    ExerciseTypeStepView(viewModel: ExerciseCreationViewModel())
}
