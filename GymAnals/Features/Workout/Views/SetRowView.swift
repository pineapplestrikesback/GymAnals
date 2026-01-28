//
//  SetRowView.swift
//  GymAnals
//
//  Created on 28/01/2026.
//

import SwiftUI

/// A single set entry row with reps, weight inputs, previous value hints, timer badge, and confirm button.
/// Combines direct keyboard entry with "last: X" hints below each field for fast set logging.
struct SetRowView: View {
    let setNumber: Int
    @Binding var reps: Int
    @Binding var weight: Double
    let previousReps: Int?
    let previousWeight: Double?
    let weightUnit: WeightUnit
    let timer: SetTimer?
    let onConfirm: () -> Void
    let onTimerTap: () -> Void

    @FocusState.Binding var focusedField: SetEntryField?
    let setID: UUID

    var body: some View {
        HStack(spacing: 12) {
            // Set number label
            Text("\(setNumber)")
                .font(.headline)
                .foregroundStyle(.secondary)
                .frame(width: 24)

            // Reps input
            repsSection

            Text("x")
                .foregroundStyle(.secondary)

            // Weight input
            weightSection

            Spacer()

            // Timer badge (if active)
            if let timer {
                SetTimerBadge(timer: timer, onTap: onTimerTap)
            }

            // Confirm button
            Button {
                onConfirm()
            } label: {
                Image(systemName: "checkmark.circle.fill")
                    .font(.title2)
                    .foregroundStyle(.green)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 10)
    }

    // MARK: - Reps Section

    private var repsSection: some View {
        VStack(alignment: .leading, spacing: 2) {
            TextField("", value: $reps, format: .number)
                .keyboardType(.numberPad)
                .multilineTextAlignment(.center)
                .frame(width: 50)
                .textFieldStyle(.roundedBorder)
                .focused($focusedField, equals: .reps(setID: setID))

            if let previousReps {
                Text("last: \(previousReps)")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
        }
    }

    // MARK: - Weight Section

    private var weightSection: some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack(spacing: 4) {
                TextField("", value: $weight, format: .number)
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.center)
                    .frame(width: 60)
                    .textFieldStyle(.roundedBorder)
                    .focused($focusedField, equals: .weight(setID: setID))

                Text(weightUnit.abbreviation)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            if let previousWeight {
                Text("last: \(formatWeight(previousWeight))")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
        }
    }

    // MARK: - Helper

    private func formatWeight(_ weight: Double) -> String {
        if weight.truncatingRemainder(dividingBy: 1) == 0 {
            return String(format: "%.0f", weight)
        }
        return String(format: "%.1f", weight)
    }
}

#Preview {
    @Previewable @State var reps1 = 8
    @Previewable @State var weight1 = 100.0
    @Previewable @State var reps2 = 10
    @Previewable @State var weight2 = 50.0
    @Previewable @FocusState var focus: SetEntryField?

    let setID1 = UUID()
    let setID2 = UUID()

    VStack(spacing: 0) {
        // Row with previous values and timer
        SetRowView(
            setNumber: 1,
            reps: $reps1,
            weight: $weight1,
            previousReps: 8,
            previousWeight: 95.0,
            weightUnit: .kilograms,
            timer: SetTimer(setID: setID1, duration: 90),
            onConfirm: { print("Confirmed set 1") },
            onTimerTap: { print("Timer tapped") },
            focusedField: $focus,
            setID: setID1
        )

        Divider()

        // Row without previous values or timer
        SetRowView(
            setNumber: 2,
            reps: $reps2,
            weight: $weight2,
            previousReps: nil,
            previousWeight: nil,
            weightUnit: .pounds,
            timer: nil,
            onConfirm: { print("Confirmed set 2") },
            onTimerTap: {},
            focusedField: $focus,
            setID: setID2
        )
    }
    .padding()
}
