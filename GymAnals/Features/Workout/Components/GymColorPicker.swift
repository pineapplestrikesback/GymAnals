//
//  GymColorPicker.swift
//  GymAnals
//
//  Created on 27/01/2026.
//

import SwiftUI

/// Picker for selecting a gym color from predefined palette
/// Uses a custom grid layout instead of .palette picker style,
/// which template-renders labels and loses explicit fill colors.
struct GymColorPicker: View {
    @Binding var selectedColor: GymColor

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 12), count: 4)

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Color")
                .foregroundStyle(.secondary)

            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(GymColor.allCases, id: \.self) { gymColor in
                    Circle()
                        .fill(gymColor.color)
                        .frame(width: 36, height: 36)
                        .overlay {
                            if gymColor == selectedColor {
                                Circle()
                                    .strokeBorder(.white, lineWidth: 3)
                                    .frame(width: 36, height: 36)
                            }
                        }
                        .shadow(color: gymColor == selectedColor ? gymColor.color.opacity(0.5) : .clear, radius: 4)
                        .onTapGesture {
                            selectedColor = gymColor
                        }
                        .accessibilityLabel(gymColor.rawValue)
                        .accessibilityAddTraits(gymColor == selectedColor ? .isSelected : [])
                }
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    @Previewable @State var color: GymColor = .blue
    Form {
        GymColorPicker(selectedColor: $color)
    }
}
