import Foundation

struct TodoItem: Identifiable, Codable, Equatable {
    let id: Int64
    let entryId: String
    let position: Int
    var text: String
    var isDone: Bool
}

struct GoalItem: Identifiable, Codable, Equatable {
    let id: Int64
    let entryId: String
    let position: Int
    var bullet: String
}

struct EntryDetail: Identifiable, Equatable {
    let entry: Entry
    let todoItems: [TodoItem]?
    let goalItems: [GoalItem]?
    
    var id: String { entry.id }
}
