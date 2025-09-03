import Foundation

enum EntryType: String, CaseIterable, Identifiable, Codable {
    case voice
    case goals
    case todos
    case raw

    var id: String { rawValue }
    var title: String {
        switch self {
        case .voice: return "Voice"
        case .goals: return "Goals"
        case .todos: return "To-Do's"
        case .raw: return "Raw"
        }
    }
}


