//
//  GymSelectorHeader.swift
//  GymAnals
//
//  Created on 27/01/2026.
//

import SwiftUI

/// Tappable header showing currently selected gym with color indicator
/// Displays gym name with color dot and chevron to indicate tap action
/// When `isDisabled` is true, shows a lock icon and prevents interaction
struct GymSelectorHeader: View {
    let gym: Gym?
    let onTap: () -> Void
    var isDisabled: Bool = false

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 6) {
                Circle()
                    .fill(gym?.colorTag.color ?? .gray)
                    .frame(width: 12, height: 12)

                Text(gym?.name ?? "Select Gym")
                    .font(.subheadline)

                Image(systemName: isDisabled ? "lock.fill" : "chevron.down")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(.regularMaterial, in: Capsule())
        }
        .buttonStyle(.plain)
        .disabled(isDisabled)
        .opacity(isDisabled ? 0.5 : 1.0)
    }
}

#Preview {
    VStack(spacing: 20) {
        GymSelectorHeader(gym: nil, onTap: {})
        // Gym preview would require model container
    }
    .padding()
}
