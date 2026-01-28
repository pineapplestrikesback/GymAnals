//
//  SetRowView.swift
//  GymAnals
//
//  Created on 28/01/2026.
//

import SwiftUI

/// A single set entry row with reps, weight inputs, previous value hints, timer badge, and confirm button.
/// Shows +/- stepper buttons only when the corresponding field is focused for a cleaner default UI.
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

    // MARK: - Computed Properties

    private var isRepsFocused: Bool {
        focusedField == .reps(setID: setID)
    }

    private var isWeightFocused: Bool {
        focusedField == .weight(setID: setID)
    }

    // String bindings for TextField
    @State private var repsText: String = ""
    @State private var weightText: String = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 6) {
                // Set number label
                Text("\(setNumber)")
                    .font(.headline)
                    .foregroundStyle(.secondary)
                    .frame(width: 24)

                // Reps input with conditional +/- buttons
                repsInputView

                Text("x")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                // Weight input with conditional +/- buttons
                weightInputView

                Text(weightUnit.abbreviation)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .frame(width: 24, alignment: .leading)

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
                HStack(spacing: 6) {
                    Spacer()
                        .frame(width: 24)

                    if let previousReps {
                        Text("last: \(previousReps)")
                            .font(.caption2)
                            .foregroundStyle(.tertiary)
                            .frame(width: isRepsFocused ? 90 : 50, alignment: .center)
                    } else {
                        Spacer().frame(width: isRepsFocused ? 90 : 50)
                    }

                    // Spacer for "x"
                    Spacer().frame(width: 14)

                    if let previousWeight {
                        Text("last: \(formatWeight(previousWeight))")
                            .font(.caption2)
                            .foregroundStyle(.tertiary)
                            .frame(width: isWeightFocused ? 90 : 50, alignment: .center)
                    } else {
                        Spacer().frame(width: isWeightFocused ? 90 : 50)
                    }

                    Spacer()
                }
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 10)
        .animation(.easeInOut(duration: 0.2), value: isRepsFocused)
        .animation(.easeInOut(duration: 0.2), value: isWeightFocused)
        .onAppear {
            repsText = "\(reps)"
            weightText = formatWeight(weight)
        }
        .onChange(of: reps) { _, newValue in
            if !isRepsFocused {
                repsText = "\(newValue)"
            }
        }
        .onChange(of: weight) { _, newValue in
            if !isWeightFocused {
                weightText = formatWeight(newValue)
            }
        }
    }

    // MARK: - Reps Input

    @ViewBuilder
    private var repsInputView: some View {
        HStack(spacing: 4) {
            // Minus button (only when focused)
            if isRepsFocused {
                stepperButton(systemName: "minus") {
                    reps = max(0, reps - 1)
                    repsText = "\(reps)"
                }
            }

            // Reps text field
            TextField("", text: $repsText)
                .keyboardType(.numberPad)
                .multilineTextAlignment(.center)
                .frame(width: 40)
                .padding(.vertical, 6)
                .background(Color(.systemGray6))
                .cornerRadius(6)
                .focused($focusedField, equals: .reps(setID: setID))
                .onChange(of: repsText) { _, newValue in
                    if let value = Int(newValue) {
                        reps = max(0, min(999, value))
                    }
                }
                .onSubmit {
                    // Sync on submit
                    if let value = Int(repsText) {
                        reps = max(0, min(999, value))
                    }
                    repsText = "\(reps)"
                }

            // Plus button (only when focused)
            if isRepsFocused {
                stepperButton(systemName: "plus") {
                    reps = min(999, reps + 1)
                    repsText = "\(reps)"
                }
            }
        }
        .frame(width: isRepsFocused ? 90 : 50)
    }

    // MARK: - Weight Input

    @ViewBuilder
    private var weightInputView: some View {
        HStack(spacing: 4) {
            // Minus button (only when focused)
            if isWeightFocused {
                stepperButton(systemName: "minus") {
                    weight = max(0, weight - 1.0)
                    weightText = formatWeight(weight)
                }
            }

            // Weight text field
            TextField("", text: $weightText)
                .keyboardType(.decimalPad)
                .multilineTextAlignment(.center)
                .frame(width: 40)
                .padding(.vertical, 6)
                .background(Color(.systemGray6))
                .cornerRadius(6)
                .focused($focusedField, equals: .weight(setID: setID))
                .onChange(of: weightText) { _, newValue in
                    if let value = Double(newValue) {
                        weight = max(0, min(999, value))
                    }
                }
                .onSubmit {
                    // Sync on submit
                    if let value = Double(weightText) {
                        weight = max(0, min(999, value))
                    }
                    weightText = formatWeight(weight)
                }

            // Plus button (only when focused)
            if isWeightFocused {
                stepperButton(systemName: "plus") {
                    weight = min(999, weight + 1.0)
                    weightText = formatWeight(weight)
                }
            }
        }
        .frame(width: isWeightFocused ? 90 : 50)
    }

    // MARK: - Stepper Button

    @ViewBuilder
    private func stepperButton(systemName: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(.primary)
                .frame(width: 22, height: 22)
                .background(Color(.systemGray5))
                .cornerRadius(4)
        }
        .buttonStyle(.plain)
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
