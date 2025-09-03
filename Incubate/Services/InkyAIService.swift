import Foundation
import NaturalLanguage

final class InkyAIService {
    static let shared = InkyAIService()
    
    private let tokenizer = NLTokenizer(unit: .word)
    private let tagger = NLTagger(tagSchemes: [.lexicalClass, .nameType])
    
    private init() {
        // No custom initialization needed
    }
    
    // MARK: - Demo Data Generation
    
    func generateDemoEntries() -> [Entry] {
        let calendar = Calendar.current
        let now = Date()
        
        var entries: [Entry] = []
        
        // Generate raw entries with varying sentiment over the last 30 days
        for i in 0..<30 {
            let date = calendar.date(byAdding: .day, value: -i, to: now) ?? now
            
            // Vary sentiment to show trends
            let sentimentFactor = Double(i) / 30.0
            let isPositive = sentimentFactor > 0.5
            
            let rawTexts = [
                "Today was amazing! I accomplished so much and felt really productive.",
                "Feeling grateful for the small wins today. Every step forward counts.",
                "Had some challenges but I'm learning to navigate them better.",
                "Feeling energized and motivated to tackle my goals.",
                "Reflecting on my progress and feeling proud of how far I've come.",
                "Today was a bit challenging but I'm staying positive.",
                "Celebrating another day of growth and self-improvement.",
                "Feeling overwhelmed but reminding myself that this too shall pass.",
                "Great energy today! Everything seems to be falling into place.",
                "Taking time to appreciate the journey, not just the destination."
            ]
            
            let text = rawTexts[i % rawTexts.count]
            let entry = Entry(
                id: UUID().uuidString,
                userId: "demo-user",
                type: .raw,
                title: nil,
                text: text,
                tags: ["demo", "raw"],
                createdAt: date,
                updatedAt: date,
                deletedAt: nil
            )
            entries.append(entry)
        }
        
        // Generate todo entries
        for i in 0..<15 {
            let date = calendar.date(byAdding: .day, value: -i, to: now) ?? now
            let entry = Entry(
                id: UUID().uuidString,
                userId: "demo-user",
                type: .todos,
                title: "Daily Tasks \(i + 1)",
                text: "",
                tags: ["demo", "todos"],
                createdAt: date,
                updatedAt: date,
                deletedAt: nil
            )
            entries.append(entry)
        }
        
        // Generate goal entries
        for i in 0..<10 {
            let date = calendar.date(byAdding: .day, value: -i, to: now) ?? now
            let entry = Entry(
                id: UUID().uuidString,
                userId: "demo-user",
                type: .goals,
                title: "Weekly Goals \(i + 1)",
                text: "",
                tags: ["demo", "goals"],
                createdAt: date,
                updatedAt: date,
                deletedAt: nil
            )
            entries.append(entry)
        }
        
        return entries
    }
    
    func generateDemoTodoItems(for entryIds: [String]) -> [TodoItem] {
        var todoItems: [TodoItem] = []
        
        for (index, entryId) in entryIds.enumerated() {
            let todos = [
                "Complete morning routine",
                "Review daily goals",
                "Take a short break",
                "Reflect on progress",
                "Plan tomorrow's priorities"
            ]
            
            for (todoIndex, todoText) in todos.enumerated() {
                let isDone = index < 10 // First 10 entries have more completed todos
                let todoItem = TodoItem(
                    id: Int64(todoItems.count + 1),
                    entryId: entryId,
                    position: todoIndex,
                    text: todoText,
                    isDone: isDone
                )
                todoItems.append(todoItem)
            }
        }
        
        return todoItems
    }
    
    func generateDemoGoalItems(for entryIds: [String]) -> [GoalItem] {
        var goalItems: [GoalItem] = []
        
        for (index, entryId) in entryIds.enumerated() {
            let goals = [
                "Improve daily productivity",
                "Build consistent habits",
                "Learn new skills",
                "Maintain work-life balance",
                "Grow personal relationships"
            ]
            
            for (goalIndex, goalText) in goals.enumerated() {
                let goalItem = GoalItem(
                    id: Int64(goalItems.count + 1),
                    entryId: entryId,
                    position: goalIndex,
                    bullet: goalText
                )
                goalItems.append(goalItem)
            }
        }
        
        return goalItems
    }
    
    // MARK: - Core Analysis Methods
    
    func analyzeSentiment(for text: String) -> Double {
        // Simple keyword-based sentiment analysis
        let positiveWords = ["amazing", "great", "awesome", "wonderful", "excellent", "fantastic", "happy", "joy", "love", "excited", "motivated", "energized", "grateful", "proud", "successful", "accomplished", "productive", "inspired", "confident", "optimistic"]
        let negativeWords = ["terrible", "awful", "horrible", "bad", "sad", "angry", "frustrated", "disappointed", "worried", "anxious", "stressed", "overwhelmed", "tired", "exhausted", "defeated", "hopeless", "lonely", "afraid", "scared", "nervous"]
        
        let lowercasedText = text.lowercased()
        let words = lowercasedText.components(separatedBy: .whitespacesAndNewlines)
        
        var positiveCount = 0
        var negativeCount = 0
        
        for word in words {
            if positiveWords.contains(word) {
                positiveCount += 1
            } else if negativeWords.contains(word) {
                negativeCount += 1
            }
        }
        
        // Calculate sentiment score (0.0 to 1.0)
        let totalEmotionalWords = positiveCount + negativeCount
        if totalEmotionalWords == 0 {
            return 0.5 // Neutral if no emotional words
        }
        
        let sentimentScore = Double(positiveCount) / Double(totalEmotionalWords)
        return sentimentScore
    }
    
    func extractKeywords(from text: String, maxCount: Int = 10) -> [String] {
        tokenizer.string = text
        tagger.string = text
        
        var keywords: [String] = []
        var keywordScores: [String: Double] = [:]
        
        // Extract nouns and adjectives as potential keywords
        tagger.enumerateTags(in: text.startIndex..<text.endIndex, unit: .word, scheme: .lexicalClass) { tag, range in
            if let tag = tag {
                let word = String(text[range]).lowercased()
                if tag == .noun || tag == .adjective {
                    let score = keywordScores[word] ?? 0.0
                    keywordScores[word] = score + 1.0
                }
            }
            return true
        }
        
        // Sort by frequency and return top keywords
        let sortedKeywords = keywordScores.sorted { $0.value > $1.value }
        return Array(sortedKeywords.prefix(maxCount).map { $0.key })
    }
    
    // MARK: - Pattern Detection
    
    func detectProductivityPatterns(entries: [Entry], todoItems: [TodoItem]) -> GrowthInsight? {
        guard !entries.isEmpty else { return nil }
        
        let last30Days = Calendar.current.date(byAdding: .day, value: -30, to: Date()) ?? Date()
        let recentEntries = entries.filter { $0.createdAt >= last30Days }
        let recentTodos = todoItems.filter { todo in
            recentEntries.contains { $0.id == todo.entryId }
        }
        
        let completionRate = recentTodos.isEmpty ? 0.0 : Double(recentTodos.filter { $0.isDone }.count) / Double(recentTodos.count)
        
        if completionRate >= 0.7 {
            return GrowthInsight(
                title: "High Productivity Streak!",
                description: "You've been completing \(Int(completionRate * 100))% of your todos in the last 30 days. This shows great focus and follow-through!",
                category: .productivity,
                confidence: completionRate,
                relatedEntries: recentEntries.map { $0.id }
            )
        } else if completionRate <= 0.3 {
            return GrowthInsight(
                title: "Room for Growth",
                description: "You're completing \(Int(completionRate * 100))% of your todos. Consider breaking down larger tasks or setting more achievable daily goals.",
                category: .productivity,
                confidence: 1.0 - completionRate,
                relatedEntries: recentEntries.map { $0.id }
            )
        }
        
        return nil
    }
    
    func detectSentimentTrends(entries: [Entry]) -> GrowthInsight? {
        guard entries.count >= 3 else { return nil }
        
        let last30Days = Calendar.current.date(byAdding: .day, value: -30, to: Date()) ?? Date()
        let recentEntries = entries.filter { $0.createdAt >= last30Days && $0.type == .raw }
        
        guard recentEntries.count >= 3 else { return nil }
        
        let sortedEntries = recentEntries.sorted { $0.createdAt < $1.createdAt }
        let sentiments = sortedEntries.map { analyzeSentiment(for: $0.text) }
        
        // Calculate trend (positive slope = improving sentiment)
        let trend = calculateTrend(values: sentiments)
        
        if trend > 0.1 {
            return GrowthInsight(
                title: "Positive Momentum Building!",
                description: "Your journal entries show an upward trend in positive sentiment. You're developing a more optimistic outlook!",
                category: .sentiment,
                confidence: min(trend * 2, 1.0),
                relatedEntries: recentEntries.map { $0.id }
            )
        } else if trend < -0.1 {
            return GrowthInsight(
                title: "Navigating Challenges",
                description: "Your recent entries suggest you're working through some difficulties. Remember, growth often comes from challenging times.",
                category: .sentiment,
                confidence: min(abs(trend) * 2, 1.0),
                relatedEntries: recentEntries.map { $0.id }
            )
        }
        
        return nil
    }
    
    func detectGoalProgressCorrelation(entries: [Entry], goalItems: [GoalItem]) -> GrowthInsight? {
        guard !entries.isEmpty else { return nil }
        
        let last30Days = Calendar.current.date(byAdding: .day, value: -30, to: Date()) ?? Date()
        let recentEntries = entries.filter { $0.createdAt >= last30Days }
        let recentGoals = goalItems.filter { goal in
            recentEntries.contains { $0.id == goal.entryId }
        }
        
        // Look for positive entries that mention goal-related keywords
        let goalKeywords = ["goal", "target", "achieve", "progress", "milestone", "success"]
        let positiveEntries = recentEntries.filter { entry in
            entry.type == .raw && analyzeSentiment(for: entry.text) > 0.6
        }
        
        let goalMentionedEntries = positiveEntries.filter { entry in
            goalKeywords.contains { keyword in
                entry.text.lowercased().contains(keyword)
            }
        }
        
        if !goalMentionedEntries.isEmpty {
            let correlation = Double(goalMentionedEntries.count) / Double(recentEntries.count)
            if correlation > 0.3 {
                return GrowthInsight(
                    title: "Goals Fueling Positivity!",
                    description: "When you focus on your goals, your mood tends to improve. \(goalMentionedEntries.count) out of \(recentEntries.count) positive entries mention goal-related topics.",
                    category: .goalProgress,
                    confidence: correlation,
                    relatedEntries: goalMentionedEntries.map { $0.id }
                )
            }
        }
        
        return nil
    }
    
    func calculateWeeklyGrowthMomentum(entries: [Entry]) -> Double {
        let last7Days = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        let last14Days = Calendar.current.date(byAdding: .day, value: -14, to: Date()) ?? Date()
        
        let recentEntries = entries.filter { $0.createdAt >= last7Days }
        let previousEntries = entries.filter { $0.createdAt >= last14Days && $0.createdAt < last7Days }
        
        let recentSentiment = recentEntries.isEmpty ? 0.5 : recentEntries.map { analyzeSentiment(for: $0.text) }.reduce(0, +) / Double(recentEntries.count)
        let previousSentiment = previousEntries.isEmpty ? 0.5 : previousEntries.map { analyzeSentiment(for: $0.text) }.reduce(0, +) / Double(previousEntries.count)
        
        return recentSentiment - previousSentiment
    }
    
    // MARK: - Conversation Generation
    
    func generateDailyGreeting() -> String {
        let greetings = [
            "Good morning! How are you feeling today?",
            "Hello there! Ready to reflect on your day?",
            "Hi! I've been looking at your recent entries. How's everything going?",
            "Welcome back! I noticed some interesting patterns in your journal. Want to chat about them?"
        ]
        return greetings.randomElement() ?? greetings[0]
    }
    
    func generateContextualQuestion(basedOn insights: [GrowthInsight]) -> String? {
        guard let insight = insights.first else { return nil }
        
        switch insight.category {
        case .sentiment:
            return "I noticed your mood has been \(insight.title.contains("Positive") ? "improving" : "challenging") lately. What do you think is contributing to this?"
        case .productivity:
            return "You've been \(insight.title.contains("High") ? "crushing" : "working on") your todos! What's your secret to staying focused?"
        case .goalProgress:
            return "Your goals seem to really energize you. What's one goal you're most excited about right now?"
        case .patterns:
            return "I'm seeing some interesting patterns in your entries. What do you think they're telling you about yourself?"
        case .momentum:
            return "How do you feel about your current momentum? Are you where you want to be?"
        }
    }
    
    func generateGoalSettingPrompt() -> String {
        let prompts = [
            "Looking ahead, what's one small step you could take tomorrow to move closer to your goals?",
            "If you could accomplish just one thing this week, what would make you feel most proud?",
            "What's a challenge you're facing that you'd like to tackle differently?",
            "How can you make tomorrow even better than today?"
        ]
        return prompts.randomElement() ?? prompts[0]
    }
    
    // MARK: - Helper Methods
    
    private func calculateTrend(values: [Double]) -> Double {
        guard values.count >= 2 else { return 0.0 }
        
        let n = Double(values.count)
        let sumX = n * (n - 1) / 2
        let sumY = values.reduce(0, +)
        let sumXY = values.enumerated().map { Double($0.offset) * $0.element }.reduce(0, +)
        let sumX2 = values.enumerated().map { Double($0.offset) * Double($0.offset) }.reduce(0, +)
        
        let slope = (n * sumXY - sumX * sumY) / (n * sumX2 - sumX * sumX)
        return slope
    }
}
