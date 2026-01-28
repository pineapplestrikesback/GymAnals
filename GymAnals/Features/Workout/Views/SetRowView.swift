//
//  SetRowView.swift
//  GymAnals
//
//  Created on 28/01/2026.
//

import SwiftUI

/// A single set entry row with reps, weight inputs, previous value hints, timer badge, and confirm button.
/// Combines +/- stepper buttons with direct keyboard entry and "last: X" hints for fast set logging.
struct SetRowView: View {
    let setNumber: Int
    @Binding var reps: Int
    @Binding var weight: Double
    let previousReps: Int?
    let previousWeight: Double?
    let weightUnit: WeightUnit
    let timer: SetTimer?
    let isConfirmed: Bool
    let onConfirm: () -> Void
    let onTimerTap: () -> Void

    @FocusState.Binding var focusedField: SetEntryField?
    let setID: UUID

    /// Internal double binding for reps (StepperTextField expects Double)
    private var repsDouble: Binding<Double> {
        Binding(
            get: { Double(reps) },
            set: { reps = Int($0) }
        )
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 8) {
                // Set number label
                Text("\(setNumber)")
                    .font(.headline)
                    .foregroundStyle(.secondary)
                    .frame(width: 24)

                // Reps stepper
                StepperTextField(
                    value: repsDouble,
                    step: 1,
                    range: 0...999,
                    unit: "reps"
                )

                // Weight stepper
                StepperTextField(
                    value: $weight,
                    step: 2.5,
                    range: 0...999,
                    unit: weightUnit.abbreviation
                )

                Spacer()

                // Timer badge (if active)
                if let timer {
                    SetTimerBadge(timer: timer, onTap: onTimerTap)
                }

                // Confirm button (toggleable)
                Button {
                    onConfirm()
                } label: {
                    Image(systemName: isConfirmed ? "checkmark.circle.fill" : "circle")
                        .font(.title2)
                        .foregroundStyle(isConfirmed ? .green : .secondary)
                }
                .buttonStyle(.plain)
            }

            // Previous values hint row
            if previousReps != nil || previousWeight != nil {
                HStack(spacing: 8) {
                    Spacer()
                        .frame(width: 24)

                    if let previousReps {
                        Text("last: \(previousReps)")
                            .font(.caption2)
                            .foregroundStyle(.tertiary)
                    }

                    Spacer()

                    if let previousWeight {
                        Text("last: \(formatWeight(previousWeight)) \(weightUnit.abbreviation)")
                            .font(.caption2)
                            .foregroundStyle(.tertiary)
                    }

                    Spacer()
                }
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 10)
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
        // Row with previous values and timer (confirmed)
        SetRowView(
            setNumber: 1,
            reps: $reps1,
            weight: $weight1,
            previousReps: 8,
            previousWeight: 95.0,
            weightUnit: .kilograms,
            timer: SetTimer(setID: setID1, duration: 90),
            isConfirmed: true,
            onConfirm: { print("Toggled set 1") },
            onTimerTap: { print("Timer tapped") },
            focusedField: $focus,
            setID: setID1
        )

        Divider()

        // Row without previous values or timer (not confirmed)
        SetRowView(
            setNumber: 2,
            reps: $reps2,
            weight: $weight2,
            previousReps: nil,
            previousWeight: nil,
            weightUnit: .pounds,
            timer: nil,
            isConfirmed: false,
            onConfirm: { print("Toggled set 2") },
            onTimerTap: {},
            focusedField: $focus,
            setID: setID2
        )
    }
    .padding()
}
