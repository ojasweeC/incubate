import Foundation

struct DailyReflection: Identifiable, Codable, Equatable {
    let id: String
    let date: Date
    var conversation: [ConversationMessage]
    var isCompleted: Bool
    var growthScore: Int? // 1-10 scale
    
    init(date: Date = Date()) {
        self.id = UUID().uuidString
        self.date = date
        self.conversation = []
        self.isCompleted = false
        self.growthScore = nil
    }
}

struct ConversationMessage: Identifiable, Codable, Equatable {
    let id: String
    let timestamp: Date
    let sender: MessageSender
    let content: String
    let messageType: MessageType
    
    init(sender: MessageSender, content: String, messageType: MessageType = .text) {
        self.id = UUID().uuidString
        self.timestamp = Date()
        self.sender = sender
        self.content = content
        self.messageType = messageType
    }
}

enum MessageSender: String, Codable, CaseIterable {
    case user = "user"
    case inky = "inky"
}

enum MessageType: String, Codable, CaseIterable {
    case text = "text"
    case question = "question"
    case insight = "insight"
    case celebration = "celebration"
}

struct GrowthInsight: Identifiable, Codable, Equatable {
    let id: String
    let title: String
    let description: String
    let category: InsightCategory
    let confidence: Double // 0.0 - 1.0
    let relatedEntries: [String] // Entry IDs
    
    init(title: String, description: String, category: InsightCategory, confidence: Double, relatedEntries: [String] = []) {
        self.id = UUID().uuidString
        self.title = title
        self.description = description
        self.category = category
        self.confidence = confidence
        self.relatedEntries = relatedEntries
    }
}

enum InsightCategory: String, Codable, CaseIterable {
    case sentiment = "sentiment"
    case productivity = "productivity"
    case goalProgress = "goal_progress"
    case patterns = "patterns"
    case momentum = "momentum"
}
