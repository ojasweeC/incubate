import Foundation

struct Entry: Identifiable, Codable, Equatable {
    let id: String
    let userId: String
    var type: EntryType
    var title: String?
    var text: String
    var tags: [String]
    let createdAt: Date
    var updatedAt: Date
    var deletedAt: Date?
}
