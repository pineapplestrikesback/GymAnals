//
//  SettingsTabView.swift
//  GymAnals
//
//  Created by opera_user on 26/01/2026.
//

import SwiftUI
import SwiftData

struct SettingsTabView: View {
    var body: some View {
        NavigationStack {
            List {
                Section("Preferences") {
                    NavigationLink {
                        Text("Weight Unit Settings")
                    } label: {
                        Label("Weight Unit", systemImage: "scalemass.fill")
                    }

                    NavigationLink {
                        Text("Rest Timer Settings")
                    } label: {
                        Label("Rest Timer", systemImage: "timer")
                    }
                }

                Section("About") {
                    NavigationLink {
                        Text("About This App")
                    } label: {
                        Label("About", systemImage: "info.circle")
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

#Preview {
    SettingsTabView()
        .modelContainer(PersistenceController.preview)
}
