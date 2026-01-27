//
//  EquipmentStepView.swift
//  GymAnals
//
//  Created on 27/01/2026.
//

import SwiftUI
import SwiftData

/// Step 3: Equipment selection
struct EquipmentStepView: View {
    @Bindable var viewModel: ExerciseCreationViewModel
    @Query(sort: \Equipment.name) private var equipment: [Equipment]

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Select equipment")
                .font(.headline)

            List {
                ForEach(equipment) { item in
                    HStack {
                        Text(item.name)
                        Spacer()
                        if viewModel.selectedEquipment?.id == item.id {
                            Image(systemName: "checkmark")
                                .foregroundStyle(Color.accentColor)
                        }
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        viewModel.selectedEquipment = item
                    }
                }
            }
            .listStyle(.plain)
        }
        .padding()
    }
}

#Preview {
    EquipmentStepView(viewModel: ExerciseCreationViewModel())
        .modelContainer(PersistenceController.preview)
}
