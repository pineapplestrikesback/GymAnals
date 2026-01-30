//
//  PersistenceController.swift
//  GymAnals
//
//  Created by opera_user on 26/01/2026.
//

import Foundation
import SwiftData

@MainActor
final class PersistenceController {
    static let shared = PersistenceController()

    let schema: Schema
    let modelConfiguration: ModelConfiguration

    private init() {
        schema = Schema([
            Movement.self,
            Equipment.self,
            Exercise.self,
            Gym.self,
            Workout.self,
            WorkoutSet.self,
            ExerciseWeightHistory.self
        ])

        // User data stored in app's Application Support directory
        let storeURL = URL.applicationSupportDirectory
            .appending(path: "GymAnals")
            .appending(path: "userdata.store")

        modelConfiguration = ModelConfiguration(
            "GymAnals",
            schema: schema,
            url: storeURL,
            allowsSave: true
        )
    }

    func createContainer() throws -> ModelContainer {
        // Ensure directory exists
        let directory = URL.applicationSupportDirectory.appending(path: "GymAnals")
        try FileManager.default.createDirectory(
            at: directory,
            withIntermediateDirectories: true
        )

        do {
            return try ModelContainer(
                for: schema,
                configurations: modelConfiguration
            )
        } catch {
            print("PersistenceController: Schema migration failed - \(error.localizedDescription)")

            #if DEBUG
            // In debug builds, delete incompatible store and retry.
            // This handles cases where model restructuring (e.g., removed tables,
            // changed relationships) exceeds lightweight migration capabilities.
            print("PersistenceController: DEBUG - resetting database for development")

            let fileManager = FileManager.default

            // Remove store file and associated WAL/SHM files
            for suffix in ["", "-shm", "-wal"] {
                let url = directory.appending(path: "userdata.store\(suffix)")
                try? fileManager.removeItem(at: url)
            }

            return try ModelContainer(
                for: schema,
                configurations: modelConfiguration
            )
            #else
            // In release builds, propagate the error to avoid silent data loss.
            // The caller should present a user-facing error or recovery flow.
            throw error
            #endif
        }
    }

    /// For SwiftUI previews - uses in-memory storage
    static var preview: ModelContainer {
        let schema = Schema([
            Movement.self,
            Equipment.self,
            Exercise.self,
            Gym.self,
            Workout.self,
            WorkoutSet.self,
            ExerciseWeightHistory.self
        ])

        let config = ModelConfiguration(isStoredInMemoryOnly: true)

        do {
            return try ModelContainer(for: schema, configurations: config)
        } catch {
            fatalError("Failed to create preview container: \(error)")
        }
    }
}
