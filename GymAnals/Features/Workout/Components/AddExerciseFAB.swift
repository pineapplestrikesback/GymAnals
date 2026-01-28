//
//  AddExerciseFAB.swift
//  GymAnals
//
//  Created on 28/01/2026.
//

import SwiftUI

/// Floating action button for adding exercises to a workout.
/// Position in parent view using ZStack with .bottomTrailing alignment.
struct AddExerciseFAB: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: "plus")
                .font(.title2.bold())
                .foregroundStyle(.white)
                .frame(width: 56, height: 56)
                .background(Color.accentColor, in: Circle())
                .shadow(color: .black.opacity(0.15), radius: 4, y: 2)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    ZStack(alignment: .bottomTrailing) {
        Color.gray.opacity(0.1)
            .ignoresSafeArea()

        AddExerciseFAB {
            print("Add exercise tapped")
        }
        .padding()
    }
}
