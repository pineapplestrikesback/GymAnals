//
//  GymManagementView.swift
//  GymAnals
//
//  Created on 27/01/2026.
//

import SwiftUI
import SwiftData

/// Main view for managing gyms (list, add, edit, delete)
struct GymManagementView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Gym.lastUsedDate, order: .reverse) private var gyms: [Gym]

    @State private var viewModel: GymManagementViewModel?
    @State private var gymToDelete: Gym?
    @State private var showingDeleteOptions = false
    @State private var showingMergeSheet = false

    var body: some View {
        List {
            ForEach(gyms) { gym in
                NavigationLink {
                    GymEditView(gym: gym)
                } label: {
                    GymRow(gym: gym)
                }
                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                    if !gym.isDefault {
                        Button(role: .destructive) {
                            gymToDelete = gym
                            showingDeleteOptions = true
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                }
            }
        }
        .navigationTitle("Manage Gyms")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                NavigationLink {
                    GymEditView()
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .onAppear {
            if viewModel == nil {
                viewModel = GymManagementViewModel(modelContext: modelContext)
            }
        }
        .confirmationDialog(
            "Delete \(gymToDelete?.name ?? "Gym")?",
            isPresented: $showingDeleteOptions,
            titleVisibility: .visible
        ) {
            Button("Delete Gym and History", role: .destructive) {
                if let gym = gymToDelete {
                    viewModel?.deleteGymWithHistory(gym)
                }
                gymToDelete = nil
            }

            Button("Delete Gym, Keep History") {
                if let gym = gymToDelete {
                    viewModel?.deleteGymKeepHistory(gym)
                }
                gymToDelete = nil
            }

            Button("Merge into Another Gym...") {
                showingMergeSheet = true
            }

            Button("Cancel", role: .cancel) {
                gymToDelete = nil
            }
        } message: {
            Text("What should happen to workouts recorded at this gym?")
        }
        .sheet(isPresented: $showingMergeSheet) {
            MergeGymSheet(
                sourceGym: gymToDelete,
                gyms: gyms,
                onMerge: { targetGym in
                    if let source = gymToDelete {
                        viewModel?.mergeGym(from: source, to: targetGym)
                    }
                    gymToDelete = nil
                    showingMergeSheet = false
                },
                onCancel: {
                    showingMergeSheet = false
                }
            )
        }
    }
}

// MARK: - Subviews

private struct GymRow: View {
    let gym: Gym

    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(gym.colorTag.color)
                .frame(width: 16, height: 16)

            Text(gym.name)

            Spacer()

            Text("\(gym.workouts.count)")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color(.systemGray5))
                .clipShape(Capsule())
        }
    }
}

private struct MergeGymSheet: View {
    let sourceGym: Gym?
    let gyms: [Gym]
    let onMerge: (Gym) -> Void
    let onCancel: () -> Void

    private var availableGyms: [Gym] {
        gyms.filter { $0.id != sourceGym?.id }
    }

    var body: some View {
        NavigationStack {
            List {
                Section {
                    ForEach(availableGyms) { gym in
                        Button {
                            onMerge(gym)
                        } label: {
                            HStack(spacing: 12) {
                                Circle()
                                    .fill(gym.colorTag.color)
                                    .frame(width: 16, height: 16)

                                Text(gym.name)
                                    .foregroundStyle(.primary)

                                Spacer()
                            }
                        }
                    }
                } header: {
                    Text("Select a gym to merge into")
                } footer: {
                    Text("All workouts and history from \"\(sourceGym?.name ?? "")\" will be moved to the selected gym.")
                }
            }
            .navigationTitle("Merge Gym")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", action: onCancel)
                }
            }
        }
    }
}

#Preview {
    let container = PersistenceController.preview
    let context = container.mainContext

    // Add sample gyms
    let defaultGym = Gym(name: "Default Gym", colorTag: .blue, isDefault: true)
    let homeGym = Gym(name: "Home Gym", colorTag: .green)
    let workGym = Gym(name: "Work Gym", colorTag: .orange)

    context.insert(defaultGym)
    context.insert(homeGym)
    context.insert(workGym)

    return NavigationStack {
        GymManagementView()
    }
    .modelContainer(container)
}
