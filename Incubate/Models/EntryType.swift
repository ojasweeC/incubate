import Foundation

enum EntryType: String, CaseIterable, Identifiable, Codable {
    case reflection
    case goals
    case todos
    case raw

    var id: String { rawValue }
    var title: String {
        switch self {
        case .reflection: return "Reflection"
        case .goals: return "Goals"
        case .todos: return "To-Do's"
        case .raw: return "Raw"
        }
    }
}


