import Foundation
import NaturalLanguage

struct EmotionalProfile {
    let overallSentiment: Double
    let complexity: Double
    let isConflicted: Bool
}

enum EmotionalNeed {
    case validation, perspective, encouragement, celebration
}

final class InkyAIService {
    static let shared = InkyAIService()
    
    private let tokenizer = NLTokenizer(unit: .word)
    private let tagger = NLTagger(tagSchemes: [.lexicalClass, .nameType, .sentimentScore])
    
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
    
    // MARK: - Enhanced Sentiment Analysis
    
    func analyzeSentiment(for text: String) -> Double {
        let sentimentTagger = NLTagger(tagSchemes: [.sentimentScore])
        sentimentTagger.string = text
        
        let (sentiment, _) = sentimentTagger.tag(at: text.startIndex, unit: .document, scheme: .sentimentScore)
        
        if let sentimentValue = sentiment?.rawValue,
           let score = Double(sentimentValue) {
            // Apple returns -1.0 (negative) to 1.0 (positive)
            // Convert to 0.0 to 1.0 scale to match your existing logic
            return (score + 1.0) / 2.0
        }
        
        return 0.5 // Neutral fallback
    }
    
    func analyzeEmotionalProfile(for text: String) -> EmotionalProfile {
        let sentimentTagger = NLTagger(tagSchemes: [.sentimentScore])
        sentimentTagger.string = text
        
        // Get overall sentiment
        let (sentiment, _) = sentimentTagger.tag(at: text.startIndex, unit: .document, scheme: .sentimentScore)
        let baseScore = Double(sentiment?.rawValue ?? "0") ?? 0.0
        
        // Detect emotional complexity (mixed feelings)
        let sentences = text.components(separatedBy: CharacterSet(charactersIn: ".!?"))
        let sentenceScores = sentences.compactMap { sentence -> Double? in
            guard !sentence.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return nil }
            sentimentTagger.string = sentence
            let (s, _) = sentimentTagger.tag(at: sentence.startIndex, unit: .document, scheme: .sentimentScore)
            return Double(s?.rawValue ?? "0")
        }
        
        let variance = calculateVariance(sentenceScores)
        let isComplex = variance > 0.5 // Mixed emotions detected
        
        return EmotionalProfile(
            overallSentiment: (baseScore + 1.0) / 2.0,
            complexity: variance,
            isConflicted: isComplex
        )
    }
    
    func detectEmotionalNeeds(text: String) -> [EmotionalNeed] {
        let lowercased = text.lowercased()
        var needs: [EmotionalNeed] = []
        
        // Detect need for validation
        if lowercased.contains("nobody") || lowercased.contains("alone") || lowercased.contains("understand") {
            needs.append(.validation)
        }
        
        // Detect need for perspective
        if lowercased.contains("stuck") || lowercased.contains("confused") || lowercased.contains("overwhelmed") {
            needs.append(.perspective)
        }
        
        // Detect need for encouragement
        if lowercased.contains("can't") || lowercased.contains("failing") || lowercased.contains("giving up") {
            needs.append(.encouragement)
        }
        
        // Detect moments to celebrate
        if lowercased.contains("accomplished") || lowercased.contains("proud") || lowercased.contains("achieved") {
            needs.append(.celebration)
        }
        
        return needs
    }
    
    func generateTherapeuticResponse(userText: String, emotionalNeeds: [EmotionalNeed]) -> String {
        // Reflection first
        let keywords = extractKeywords(from: userText, maxCount: 2)
        let reflection = keywords.isEmpty ? "" : "It sounds like \(keywords.first!) is really on your mind. "
        
        // Address emotional needs
        var response = reflection
        
        if emotionalNeeds.contains(.validation) {
            response += "What you're feeling makes complete sense given what you're going through. "
        }
        
        if emotionalNeeds.contains(.perspective) {
            response += "Sometimes when we're in the middle of something, it's hard to see the whole picture. "
        }
        
        if emotionalNeeds.contains(.encouragement) {
            response += "I can hear how hard you're trying, and that effort matters even when things feel difficult. "
        }
        
        if emotionalNeeds.contains(.celebration) {
            response += "That's something to genuinely feel good about - you should celebrate that accomplishment! "
        }
        
        // Gentle exploration
        response += "What would feel most supportive right now - talking through what happened, or thinking about what might help you move forward?"
        
        return response
    }
    
    private func calculateVariance(_ values: [Double]) -> Double {
        guard values.count > 1 else { return 0.0 }
        
        let mean = values.reduce(0, +) / Double(values.count)
        let squaredDiffs = values.map { pow($0 - mean, 2) }
        return squaredDiffs.reduce(0, +) / Double(values.count)
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
    
    // MARK: - Enhanced Conversation Generation
    
    func generateDailyGreeting() -> String {
        let greetings = [
            "Good morning! How are you feeling today?",
            "Hello there! Ready to reflect on your day?",
            "Hi! I've been looking at your recent entries. How's everything going?",
            "Welcome back! I noticed some interesting patterns in your journal. Want to chat about them?"
        ]
        return greetings.randomElement() ?? greetings[0]
    }
    
    func generateEmpathicQuestion(userResponse: String, conversationStage: Int, insights: [GrowthInsight] = []) -> String {
        let profile = analyzeEmotionalProfile(for: userResponse)
        let emotionalNeeds = detectEmotionalNeeds(text: userResponse)
        let keywords = extractKeywords(from: userResponse, maxCount: 3)
        
        // Get recent entries to reference user's actual patterns
        let recentEntries = (try? DatabaseManager.shared.fetchAllActive(limit: 20)) ?? []
        let recentKeywords = recentEntries.flatMap { extractKeywords(from: $0.text, maxCount: 2) }
        let keywordFrequency = Dictionary(grouping: recentKeywords, by: { $0 }).mapValues { $0.count }
        let frequentKeywords = keywordFrequency.filter { $0.value >= 2 }.keys.shuffled()
        
        // Handle conflicted emotions specially
        if profile.isConflicted {
            return "I hear mixed feelings in what you're sharing. It sounds like part of you feels one way, and another part feels different. That's completely normal - what aspect feels most important to explore?"
        }
        
        switch conversationStage {
        case 1: // Follow-up to greeting
            if profile.overallSentiment > 0.7 && profile.complexity < 0.3 {
                let templates = [
                    "Your energy feels really clear and positive right now. What's contributing most to this feeling?",
                    keywords.isEmpty ? "I love hearing that clarity and joy! What's been fueling this?" : "It's beautiful how you describe \(keywords.first!). Tell me more about that experience.",
                    frequentKeywords.isEmpty ? "What's been bringing you the most happiness lately?" : "I've noticed you often write about \(frequentKeywords.first!) - how does that connect to your positive energy today?"
                ]
                return templates.randomElement()!
            } else if profile.overallSentiment < 0.3 && profile.complexity > 0.5 {
                return "It sounds like you're working through some complex feelings. Sometimes our emotions can feel layered - what part of this feels most pressing to talk through?"
            } else if emotionalNeeds.contains(.validation) {
                return "What you're experiencing sounds really valid. I'm here to listen - what would feel most supportive to explore?"
            } else if emotionalNeeds.contains(.celebration) {
                return generateTherapeuticResponse(userText: userResponse, emotionalNeeds: emotionalNeeds)
            } else {
                let keywordPhrase = keywords.isEmpty ? "" : " around \(keywords.first!)"
                let templates = [
                    "I'm curious to hear more\(keywordPhrase). What's been occupying your thoughts?",
                    "How are you feeling about where things stand right now?",
                    frequentKeywords.isEmpty ? "What's been on your mind most this week?" : "You've mentioned \(frequentKeywords.first!) in your recent entries - how are you feeling about that today?"
                ]
                return templates.randomElement()!
            }
            
        case 2: // Contextual based on insights
            if let insight = insights.first {
                switch insight.category {
                case .productivity:
                    let completionRate = insight.confidence
                    if completionRate > 0.7 {
                        return "I've noticed you've been crushing your tasks lately - completing about \(Int(completionRate * 100))% of what you set out to do. What's your secret to staying so consistent?"
                    } else {
                        return "I see you're working on building your task completion rhythm. What's one small change that might help you feel more on track?"
                    }
                case .sentiment:
                    return insight.title.contains("Positive") ?
                        "Your recent entries show such beautiful growth in positivity. I'm curious - what shift have you noticed in yourself?" :
                        "I can see you've been working through some challenging feelings in your writing. How are you taking care of yourself through this time?"
                case .goalProgress:
                    return "Your goals really seem to energize you! When you write about them, there's such passion in your words. What goal feels most alive for you right now?"
                default:
                    return frequentKeywords.isEmpty ? "Looking at your recent entries, what patterns do you notice in yourself?" : "I've been noticing you write about \(frequentKeywords.first!) quite often. What does that tell you about where your energy is flowing?"
                }
            }
            // Fallback with potential data reference
            return frequentKeywords.isEmpty ? "What's one thing you're learning about yourself lately?" : "Looking at your recent writing, especially around \(frequentKeywords.first!), what insights are emerging for you?"
            
        default: // Goal setting stage
            let goalTemplates = [
                "Looking ahead to tomorrow, what's one small thing you could do that would make you proud?",
                "If you could accomplish just one meaningful thing this week, what would light you up?",
                "What's one way you could build on today's energy tomorrow?",
                insights.contains(where: { $0.category == .momentum }) ? "You've been building such good momentum - how do you want to keep that going?" : "What would make tomorrow feel like a win for you?"
            ]
            return goalTemplates.randomElement()!
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
