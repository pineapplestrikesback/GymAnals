//
//  StepperTextField.swift
//  GymAnals
//
//  Created on 28/01/2026.
//

import SwiftUI

/// A reusable stepper input with tap-to-type text field.
/// Combines +/- buttons for quick adjustment with direct keyboard entry.
struct StepperTextField: View {
    @Binding var value: Double
    let step: Double
    let range: ClosedRange<Double>
    let unit: String
    var onFocus: (() -> Void)?

    @State private var textValue: String = ""
    @FocusState private var isFocused: Bool

    var body: some View {
        HStack(spacing: 8) {
            // Minus button
            Button {
                decrementValue()
            } label: {
                Image(systemName: "minus")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.primary)
                    .frame(width: 32, height: 32)
                    .background(.regularMaterial, in: Circle())
            }
            .buttonStyle(.plain)
            .sensoryFeedback(.decrease, trigger: value)

            // Text field
            TextField("", text: $textValue)
                .keyboardType(.decimalPad)
                .multilineTextAlignment(.center)
                .frame(width: 50)
                .textFieldStyle(.roundedBorder)
                .focused($isFocused)
                .onChange(of: isFocused) { oldValue, newValue in
                    if newValue {
                        // On focus: format current value for editing
                        textValue = formatValue(value)
                        onFocus?()
                    } else {
                        // On blur: parse and clamp value
                        parseAndUpdateValue()
                    }
                }

            // Unit label
            Text(unit)
                .font(.caption)
                .foregroundStyle(.secondary)

            // Plus button
            Button {
                incrementValue()
            } label: {
                Image(systemName: "plus")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.primary)
                    .frame(width: 32, height: 32)
                    .background(.regularMaterial, in: Circle())
            }
            .buttonStyle(.plain)
            .sensoryFeedback(.increase, trigger: value)
        }
        .onAppear {
            textValue = formatValue(value)
        }
        .onChange(of: value) { _, newValue in
            // Update text when value changes externally (if not focused)
            if !isFocused {
                textValue = formatValue(newValue)
            }
        }
    }

    // MARK: - Private Methods

    private func decrementValue() {
        let newValue = max(range.lowerBound, value - step)
        value = newValue
        textValue = formatValue(newValue)
    }

    private func incrementValue() {
        let newValue = min(range.upperBound, value + step)
        value = newValue
        textValue = formatValue(newValue)
    }

    private func parseAndUpdateValue() {
        if let parsed = Double(textValue) {
            value = min(range.upperBound, max(range.lowerBound, parsed))
        }
        textValue = formatValue(value)
    }

    /// Formats the value for display: no decimals if whole number, one decimal otherwise.
    private func formatValue(_ val: Double) -> String {
        if val.truncatingRemainder(dividingBy: 1) == 0 {
            return String(format: "%.0f", val)
        } else {
            return String(format: "%.1f", val)
        }
    }
}

#Preview {
    @Previewable @State var weight: Double = 100.0
    @Previewable @State var reps: Double = 8.0

    VStack(spacing: 32) {
        StepperTextField(
            value: $weight,
            step: 2.5,
            range: 0...500,
            unit: "kg"
        )

        StepperTextField(
            value: $reps,
            step: 1,
            range: 0...100,
            unit: "reps"
        )
    }
    .padding()
}
