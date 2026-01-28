//
//  GymAnalsApp.swift
//  GymAnals
//
//  Created by opera_user on 26/01/2026.
//

import SwiftUI
import SwiftData

@main
struct GymAnalsApp: App {
    let container: ModelContainer

    init() {
        do {
            container = try PersistenceController.shared.createContainer()
            // Seed database on first launch (order matters: presets depend on movements + equipment)
            GymSeedService.seedIfNeeded(context: container.mainContext)
            EquipmentSeedService.seedIfNeeded(context: container.mainContext)
            MovementSeedService.seedIfNeeded(context: container.mainContext)
            PresetSeedService.seedIfNeeded(context: container.mainContext)
        } catch {
            fatalError("Failed to initialize SwiftData: \(error.localizedDescription)")
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(container)
    }
}
