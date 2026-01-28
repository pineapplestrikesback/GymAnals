//
//  Muscle.swift
//  GymAnals
//
//  Created on 26/01/2026.
//

import Foundation

/// Individual muscle enumeration with anatomical accuracy
/// Contains 34 muscles organized by body region
enum Muscle: String, CaseIterable, Codable, Identifiable {

    // MARK: - Chest (3)
    case pectoralisMajorUpper
    case pectoralisMajorLower
    case pectoralisMinor

    // MARK: - Back (7)
    case latissimusDorsi
    case trapeziusUpper
    case trapeziusMiddle
    case trapeziusLower
    case rhomboids
    case teresMajor
    case serratusAnterior

    // MARK: - Shoulders (4)
    case deltoidAnterior
    case deltoidLateral
    case deltoidPosterior
    case rotatorCuff

    // MARK: - Arms (6)
    case bicepsBrachii
    case bicepsBrachialis
    case tricepsLongHead
    case tricepsLateralHead
    case tricepsMedialHead
    case forearms

    // MARK: - Core (4)
    case rectusAbdominis
    case obliquesInternal
    case obliquesExternal
    case erectorSpinae

    // MARK: - Legs (10)
    case quadricepsRectus
    case quadricepsVastus
    case hamstringsBicepsFemoris
    case hamstringsSemimembranosus
    case gluteusMaximus
    case gluteusMedius
    case gluteusMinimus
    case adductors
    case gastrocnemius
    case soleus

    var id: String { rawValue }

    /// User-friendly display name
    var displayName: String {
        switch self {
        // Chest
        case .pectoralisMajorUpper: return "Upper Chest"
        case .pectoralisMajorLower: return "Lower Chest"
        case .pectoralisMinor: return "Pec Minor"
        // Back
        case .latissimusDorsi: return "Lats"
        case .trapeziusUpper: return "Upper Traps"
        case .trapeziusMiddle: return "Middle Traps"
        case .trapeziusLower: return "Lower Traps"
        case .rhomboids: return "Rhomboids"
        case .teresMajor: return "Teres Major"
        case .serratusAnterior: return "Serratus"
        // Shoulders
        case .deltoidAnterior: return "Front Delts"
        case .deltoidLateral: return "Side Delts"
        case .deltoidPosterior: return "Rear Delts"
        case .rotatorCuff: return "Rotator Cuff"
        // Arms
        case .bicepsBrachii: return "Biceps"
        case .bicepsBrachialis: return "Brachialis"
        case .tricepsLongHead: return "Triceps Long Head"
        case .tricepsLateralHead: return "Triceps Lateral Head"
        case .tricepsMedialHead: return "Triceps Medial Head"
        case .forearms: return "Forearms"
        // Core
        case .rectusAbdominis: return "Abs"
        case .obliquesInternal: return "Internal Obliques"
        case .obliquesExternal: return "External Obliques"
        case .erectorSpinae: return "Lower Back"
        // Legs
        case .quadricepsRectus: return "Rectus Femoris"
        case .quadricepsVastus: return "Vastus Muscles"
        case .hamstringsBicepsFemoris: return "Biceps Femoris"
        case .hamstringsSemimembranosus: return "Semimembranosus"
        case .gluteusMaximus: return "Glutes"
        case .gluteusMedius: return "Glute Medius"
        case .gluteusMinimus: return "Glute Min"
        case .adductors: return "Adductors"
        case .gastrocnemius: return "Calves"
        case .soleus: return "Soleus"
        }
    }

    /// Formal anatomical name
    var anatomicalName: String {
        switch self {
        // Chest
        case .pectoralisMajorUpper: return "Pectoralis Major - Clavicular Head"
        case .pectoralisMajorLower: return "Pectoralis Major - Sternal Head"
        case .pectoralisMinor: return "Pectoralis Minor"
        // Back
        case .latissimusDorsi: return "Latissimus Dorsi"
        case .trapeziusUpper: return "Trapezius - Upper Fibers"
        case .trapeziusMiddle: return "Trapezius - Middle Fibers"
        case .trapeziusLower: return "Trapezius - Lower Fibers"
        case .rhomboids: return "Rhomboid Major & Minor"
        case .teresMajor: return "Teres Major"
        case .serratusAnterior: return "Serratus Anterior"
        // Shoulders
        case .deltoidAnterior: return "Deltoid - Anterior Head"
        case .deltoidLateral: return "Deltoid - Lateral Head"
        case .deltoidPosterior: return "Deltoid - Posterior Head"
        case .rotatorCuff: return "Rotator Cuff Muscles"
        // Arms
        case .bicepsBrachii: return "Biceps Brachii"
        case .bicepsBrachialis: return "Brachialis"
        case .tricepsLongHead: return "Triceps Brachii - Long Head"
        case .tricepsLateralHead: return "Triceps Brachii - Lateral Head"
        case .tricepsMedialHead: return "Triceps Brachii - Medial Head"
        case .forearms: return "Forearm Flexors & Extensors"
        // Core
        case .rectusAbdominis: return "Rectus Abdominis"
        case .obliquesInternal: return "Internal Oblique"
        case .obliquesExternal: return "External Oblique"
        case .erectorSpinae: return "Erector Spinae"
        // Legs
        case .quadricepsRectus: return "Rectus Femoris"
        case .quadricepsVastus: return "Vastus Lateralis, Medialis, Intermedius"
        case .hamstringsBicepsFemoris: return "Biceps Femoris"
        case .hamstringsSemimembranosus: return "Semimembranosus & Semitendinosus"
        case .gluteusMaximus: return "Gluteus Maximus"
        case .gluteusMedius: return "Gluteus Medius"
        case .gluteusMinimus: return "Gluteus Minimus"
        case .adductors: return "Hip Adductors"
        case .gastrocnemius: return "Gastrocnemius"
        case .soleus: return "Soleus"
        }
    }

    /// The muscle group this muscle belongs to
    var group: MuscleGroup {
        switch self {
        case .pectoralisMajorUpper, .pectoralisMajorLower, .pectoralisMinor:
            return .chest
        case .latissimusDorsi, .trapeziusUpper, .trapeziusMiddle, .trapeziusLower, .rhomboids, .teresMajor, .serratusAnterior:
            return .back
        case .deltoidAnterior, .deltoidLateral, .deltoidPosterior, .rotatorCuff:
            return .shoulders
        case .bicepsBrachii, .bicepsBrachialis, .tricepsLongHead, .tricepsLateralHead, .tricepsMedialHead, .forearms:
            return .arms
        case .rectusAbdominis, .obliquesInternal, .obliquesExternal, .erectorSpinae:
            return .core
        case .quadricepsRectus, .quadricepsVastus, .hamstringsBicepsFemoris, .hamstringsSemimembranosus, .gluteusMaximus, .gluteusMedius, .gluteusMinimus, .adductors, .gastrocnemius, .soleus:
            return .legs
        }
    }
}
