//
//  SetEntryField.swift
//  GymAnals
//
//  Created on 28/01/2026.
//

import Foundation

/// Focus state enum for set entry fields, enabling programmatic focus control across sets.
enum SetEntryField: Hashable {
    case reps(setID: UUID)
    case weight(setID: UUID)
}
