//
//  MuscleGroupFilterTabs.swift
//  GymAnals
//
//  Created on 27/01/2026.
//

import SwiftUI

/// Horizontal scrolling filter tabs for muscle group selection
struct MuscleGroupFilterTabs: View {
    @Binding var selectedGroup: MuscleGroup?

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                FilterTab(title: "All", isSelected: selectedGroup == nil) {
                    selectedGroup = nil
                }

                ForEach(MuscleGroup.allCases) { group in
                    FilterTab(title: group.displayName, isSelected: selectedGroup == group) {
                        selectedGroup = group
                    }
                }
            }
            .padding(.horizontal)
        }
        .sensoryFeedback(.selection, trigger: selectedGroup)
    }
}

/// Individual filter tab button
private struct FilterTab: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .fontWeight(isSelected ? .semibold : .regular)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? Color.accentColor : Color.secondary.opacity(0.1))
                .foregroundStyle(isSelected ? .white : .primary)
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    @Previewable @State var selectedGroup: MuscleGroup? = nil
    MuscleGroupFilterTabs(selectedGroup: $selectedGroup)
}
