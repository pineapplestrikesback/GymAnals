//
//  MuscleSlider.swift
//  GymAnals
//
//  Created on 27/01/2026.
//

import SwiftUI

/// Custom slider component with 0.05 increments and haptic feedback
struct MuscleSlider: View {
    let muscle: Muscle
    @Binding var value: Double
    let isEditing: Bool

    // Track snap index for haptic trigger
    @State private var snapIndex: Int = 0

    // 0.05 increments = 21 levels (0, 0.05, 0.10... 1.0)
    private var displayValue: String {
        String(format: "%.2f", value)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(muscle.displayName)
                    .font(.subheadline)

                Spacer()

                Text(displayValue)
                    .font(.subheadline)
                    .monospacedDigit()
                    .foregroundStyle(value > 0 ? .primary : .secondary)
            }

            if isEditing {
                Slider(value: $value, in: 0...1, step: 0.05)
                    .sensoryFeedback(.impact(weight: .light), trigger: snapIndex)
                    .onChange(of: value) { oldValue, newValue in
                        let newIndex = Int(round(newValue / 0.05))
                        if newIndex != snapIndex {
                            snapIndex = newIndex
                        }
                    }
                    .tint(colorForWeight(value))
            } else {
                // Read-only progress bar
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 2)
                            .fill(Color.secondary.opacity(0.2))
                            .frame(height: 4)

                        RoundedRectangle(cornerRadius: 2)
                            .fill(colorForWeight(value))
                            .frame(width: geometry.size.width * value, height: 4)
                    }
                }
                .frame(height: 4)
            }
        }
        .onAppear {
            snapIndex = Int(round(value / 0.05))
        }
    }

    private func colorForWeight(_ weight: Double) -> Color {
        switch weight {
        case 0.8...1.0: return .red
        case 0.5..<0.8: return .orange
        case 0.2..<0.5: return .yellow
        case 0.01..<0.2: return .green
        default: return .gray
        }
    }
}

#Preview("Editing") {
    VStack(spacing: 20) {
        MuscleSlider(
            muscle: .pectoralisMajorUpper,
            value: .constant(0.8),
            isEditing: true
        )
        MuscleSlider(
            muscle: .deltoidAnterior,
            value: .constant(0.5),
            isEditing: true
        )
        MuscleSlider(
            muscle: .tricepsLongHead,
            value: .constant(0.2),
            isEditing: true
        )
    }
    .padding()
}

#Preview("Read-only") {
    VStack(spacing: 20) {
        MuscleSlider(
            muscle: .pectoralisMajorUpper,
            value: .constant(0.8),
            isEditing: false
        )
        MuscleSlider(
            muscle: .deltoidAnterior,
            value: .constant(0.5),
            isEditing: false
        )
        MuscleSlider(
            muscle: .tricepsLongHead,
            value: .constant(0.2),
            isEditing: false
        )
    }
    .padding()
}
