//
//  GymColorPicker.swift
//  GymAnals
//
//  Created on 27/01/2026.
//

import SwiftUI

/// Picker for selecting a gym color from predefined palette
struct GymColorPicker: View {
    @Binding var selectedColor: GymColor

    var body: some View {
        Picker("Color", selection: $selectedColor) {
            ForEach(GymColor.allCases, id: \.self) { gymColor in
                Circle()
                    .fill(gymColor.color)
                    .frame(width: 24, height: 24)
                    .tag(gymColor)
            }
        }
        .pickerStyle(.palette)
    }
}

#Preview {
    @Previewable @State var color: GymColor = .blue
    Form {
        GymColorPicker(selectedColor: $color)
    }
}
