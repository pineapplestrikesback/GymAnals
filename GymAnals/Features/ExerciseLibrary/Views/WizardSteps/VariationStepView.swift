//
//  VariationStepView.swift
//  GymAnals
//
//  Created on 27/01/2026.
//

import SwiftUI

/// Step 2: Exercise naming with suggestions
struct NameStepView: View {
    @Bindable var viewModel: ExerciseCreationViewModel

    /// Common name suggestions
    private let suggestions = [
        "Standard", "Incline", "Decline",
        "Wide Grip", "Close Grip", "Neutral Grip", "Reverse Grip",
        "Single Arm", "Seated", "Standing"
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Name this exercise")
                .font(.headline)

            TextField("e.g., Incline Bench Press", text: $viewModel.exerciseName)
                .textFieldStyle(.roundedBorder)

            Text("Suggestions")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            FlowLayout(spacing: 8) {
                ForEach(suggestions, id: \.self) { suggestion in
                    Button(suggestion) {
                        if viewModel.exerciseName.isEmpty {
                            viewModel.exerciseName = suggestion
                        } else {
                            viewModel.exerciseName += " \(suggestion)"
                        }
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.small)
                }
            }

            Spacer()
        }
        .padding()
    }
}

// MARK: - FlowLayout

/// Simple horizontal flow layout for suggestion chips
struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let sizes = subviews.map { $0.sizeThatFits(.unspecified) }
        return layout(sizes: sizes, containerWidth: proposal.width ?? .infinity).size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let sizes = subviews.map { $0.sizeThatFits(.unspecified) }
        let offsets = layout(sizes: sizes, containerWidth: bounds.width).offsets

        for (subview, offset) in zip(subviews, offsets) {
            subview.place(
                at: CGPoint(x: bounds.minX + offset.x, y: bounds.minY + offset.y),
                proposal: .unspecified
            )
        }
    }

    private func layout(sizes: [CGSize], containerWidth: CGFloat) -> (offsets: [CGPoint], size: CGSize) {
        var offsets: [CGPoint] = []
        var currentX: CGFloat = 0
        var currentY: CGFloat = 0
        var lineHeight: CGFloat = 0
        var maxWidth: CGFloat = 0

        for size in sizes {
            if currentX + size.width > containerWidth && currentX > 0 {
                currentX = 0
                currentY += lineHeight + spacing
                lineHeight = 0
            }
            offsets.append(CGPoint(x: currentX, y: currentY))
            currentX += size.width + spacing
            lineHeight = max(lineHeight, size.height)
            maxWidth = max(maxWidth, currentX)
        }

        return (offsets, CGSize(width: maxWidth, height: currentY + lineHeight))
    }
}

#Preview {
    NameStepView(viewModel: ExerciseCreationViewModel())
}
