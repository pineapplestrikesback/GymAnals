//
//  MovementStepView.swift
//  GymAnals
//
//  Created on 27/01/2026.
//

import SwiftUI
import SwiftData

/// Step 1: Movement selection or creation
struct MovementStepView: View {
    @Bindable var viewModel: ExerciseCreationViewModel
    @Query(sort: \Movement.name) private var movements: [Movement]
    @State private var searchText = ""

    private var filteredMovements: [Movement] {
        if searchText.isEmpty {
            return movements
        }
        return movements.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Select or create a movement")
                .font(.headline)

            TextField("Search movements", text: $searchText)
                .textFieldStyle(.roundedBorder)

            if filteredMovements.isEmpty && !searchText.isEmpty {
                Button {
                    viewModel.newMovementName = searchText
                    viewModel.isCreatingNewMovement = true
                    viewModel.selectedMovement = nil
                } label: {
                    Label("Create \"\(searchText)\"", systemImage: "plus.circle.fill")
                }
                .buttonStyle(.borderedProminent)
            }

            List {
                ForEach(filteredMovements) { movement in
                    HStack {
                        Text(movement.name)
                        Spacer()
                        if viewModel.selectedMovement?.id == movement.id {
                            Image(systemName: "checkmark")
                                .foregroundStyle(Color.accentColor)
                        }
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        viewModel.selectedMovement = movement
                        viewModel.isCreatingNewMovement = false
                        viewModel.newMovementName = ""
                    }
                }
            }
            .listStyle(.plain)

            if viewModel.isCreatingNewMovement {
                HStack {
                    Image(systemName: "sparkles")
                    Text("Creating new: \(viewModel.newMovementName)")
                }
                .foregroundStyle(.secondary)
                .font(.caption)
            }
        }
        .padding()
    }
}

#Preview {
    MovementStepView(viewModel: ExerciseCreationViewModel())
        .modelContainer(PersistenceController.preview)
}
