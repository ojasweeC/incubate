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

struct ReflectionQA: Identifiable, Codable, Equatable {
    let id: Int64
    let entryId: String
    let position: Int
    var question: String
    var answer: String
}

struct EntryDetail: Identifiable, Equatable {
    let entry: Entry
    let todoItems: [TodoItem]?
    let goalItems: [GoalItem]?
    let reflectionQAs: [ReflectionQA]?
    
    var id: String { entry.id }
}
