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
        
        // Generate raw entries with varying sentiment over the last 10 days
        for i in 0..<10 {
            let date = calendar.date(byAdding: .day, value: -i, to: now) ?? now
            
            // Vary sentiment to show trends
            let sentimentFactor = Double(i) / 10.0
            let isPositive = sentimentFactor > 0.5
            
            let rawTexts = [
                "Today was amazing! I accomplished so much and felt really productive and grateful for the opportunities.",
                "Feeling grateful for the small wins today. Every step forward counts and I'm thankful for this progress.",
                "Had some challenges but I'm learning to navigate them better. Grateful for the lessons learned.",
                "Feeling energized and motivated to tackle my goals. I'm excited about what's ahead!",
                "Reflecting on my progress and feeling proud of how far I've come. So grateful for this journey.",
                "Today was a bit challenging but I'm staying positive and hopeful about tomorrow.",
                "Celebrating another day of growth and self-improvement. Feeling blessed and thankful.",
                "Feeling overwhelmed but reminding myself that this too shall pass. Taking it one step at a time.",
                "Great energy today! Everything seems to be falling into place. Feeling joyful and content.",
                "Taking time to appreciate the journey, not just the destination. Grateful for every moment.",
                "Feeling anxious about the upcoming presentation but trying to stay calm and confident.",
                "Had a wonderful conversation with a friend today. Feeling connected and supported.",
                "Struggling with motivation today but grateful for the small moments of peace.",
                "Feeling inspired by a book I'm reading. Excited to apply these new insights.",
                "Tired but satisfied with the work accomplished today. Grateful for the progress made."
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
        for i in 0..<7 {
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
        for i in 0..<5 {
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
                let isDone = index < 5 // First 5 entries have more completed todos
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
    
    func analyzeEnhancedSentiment(for text: String) -> Double {
        let baseSentiment = analyzeSentiment(for: text)
        let keywordBoost = calculateKeywordSentimentBoost(for: text)
        
        // Combine base sentiment with keyword analysis
        // Weight the keyword analysis more heavily for better detection
        let enhancedScore = (baseSentiment * 0.4) + (keywordBoost * 0.6)
        
        // Ensure score stays within 0.0 to 1.0 range
        return max(0.0, min(1.0, enhancedScore))
    }
    
    private func calculateKeywordSentimentBoost(for text: String) -> Double {
        let lowercased = text.lowercased()
        
        // Comprehensive positive keywords
        let positiveKeywords = [
            // Gratitude and appreciation
            "grateful", "gratitude", "thankful", "appreciate", "appreciation", "blessed", "fortunate",
            // Joy and happiness
            "happy", "joy", "joyful", "cheerful", "delighted", "ecstatic", "elated", "thrilled",
            "amazing", "wonderful", "fantastic", "excellent", "great", "awesome", "incredible",
            // Success and achievement
            "accomplished", "achieved", "success", "successful", "progress", "improvement", "growth",
            "proud", "confident", "motivated", "inspired", "energized", "excited",
            // Love and connection
            "love", "loved", "caring", "supportive", "connected", "belonging", "warmth",
            // Optimism and hope
            "hopeful", "optimistic", "positive", "bright", "promising", "encouraging",
            // Peace and contentment
            "peaceful", "calm", "content", "satisfied", "fulfilled", "balanced", "centered",
            // Energy and vitality
            "energetic", "vibrant", "alive", "refreshed", "renewed", "revitalized"
        ]
        
        // Comprehensive negative keywords
        let negativeKeywords = [
            // Sadness and depression
            "sad", "depressed", "down", "blue", "melancholy", "gloomy", "miserable", "unhappy",
            // Anxiety and worry
            "anxious", "worried", "stressed", "overwhelmed", "panicked", "nervous", "fearful",
            "concerned", "troubled", "distressed", "agitated",
            // Anger and frustration
            "angry", "mad", "furious", "irritated", "frustrated", "annoyed", "upset", "disappointed",
            // Exhaustion and fatigue
            "tired", "exhausted", "drained", "burned out", "fatigued", "weary", "spent",
            // Loneliness and isolation
            "lonely", "alone", "isolated", "disconnected", "abandoned", "rejected",
            // Failure and disappointment
            "failed", "failure", "disappointed", "let down", "defeated", "hopeless", "helpless",
            // Pain and suffering
            "hurt", "pain", "suffering", "struggling", "difficult", "challenging", "hard"
        ]
        
        // Count positive and negative keyword matches
        let positiveCount = positiveKeywords.reduce(0) { count, keyword in
            count + (lowercased.components(separatedBy: keyword).count - 1)
        }
        
        let negativeCount = negativeKeywords.reduce(0) { count, keyword in
            count + (lowercased.components(separatedBy: keyword).count - 1)
        }
        
        // Calculate boost based on keyword density
        let totalWords = lowercased.components(separatedBy: .whitespacesAndNewlines).filter { !$0.isEmpty }.count
        let positiveDensity = totalWords > 0 ? Double(positiveCount) / Double(totalWords) : 0.0
        let negativeDensity = totalWords > 0 ? Double(negativeCount) / Double(totalWords) : 0.0
        
        // Apply stronger boost for gratitude and positive keywords
        let gratitudeBoost = (lowercased.contains("grateful") || lowercased.contains("gratitude") || 
                             lowercased.contains("thankful") || lowercased.contains("appreciate")) ? 0.3 : 0.0
        
        // Calculate final sentiment boost
        let netBoost = (positiveDensity * 0.8) - (negativeDensity * 0.8) + gratitudeBoost
        
        // Convert to 0.0 to 1.0 scale (0.5 is neutral)
        return 0.5 + netBoost
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
        response += "I'm here to listen and support you as you process what feels most important to share right now."
        
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
            "Welcome back! I'm here to support your reflection journey. Take a moment to share what's on your mind today.",
            "Hello! I've been looking forward to our time together. What's been happening in your world lately?",
            "Good to see you again! I'm ready to listen and help you process your thoughts. What's been on your mind?"
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
            return "I hear mixed feelings in what you're sharing. It sounds like part of you feels one way, and another part feels different. That's completely normal and shows you're processing complex emotions. Take your time to explore what feels most important to you right now."
        }
        
        switch conversationStage {
        case 1: // Follow-up to greeting
            if profile.overallSentiment > 0.7 && profile.complexity < 0.3 {
                let templates = [
                    "Your energy feels really clear and positive right now. I'd love to hear more about what's contributing to this wonderful feeling.",
                    keywords.isEmpty ? "I love hearing that clarity and joy! I'm curious about what's been fueling this positive energy." : "It's beautiful how you describe \(keywords.first!). I'd love to hear more about that experience.",
                    frequentKeywords.isEmpty ? "I'm curious about what's been bringing you the most happiness lately." : "I've noticed you often write about \(frequentKeywords.first!) - I'd love to hear how that connects to your positive energy today."
                ]
                return templates.randomElement()!
            } else if profile.overallSentiment < 0.3 && profile.complexity > 0.5 {
                return "It sounds like you're working through some complex feelings. Sometimes our emotions can feel layered, and that's completely okay. I'm here to listen as you process what feels most important to you right now."
            } else if emotionalNeeds.contains(.validation) {
                return "What you're experiencing sounds really valid. I'm here to listen and support you as you explore what feels most important to share."
            } else if emotionalNeeds.contains(.celebration) {
                return generateTherapeuticResponse(userText: userResponse, emotionalNeeds: emotionalNeeds)
            } else {
                let templates = [
                    "I'd love to hear more about what's been occupying your thoughts lately.",
                    "I'm interested in hearing how you're feeling about where things stand right now.",
                    "I'm curious about what's been on your mind most this week.",
                    frequentKeywords.isEmpty ? "I'd love to hear what's been on your mind most this week." : "I've noticed you've been writing about \(frequentKeywords.first!) recently - I'd love to hear more about how that's been for you."
                ]
                return templates.randomElement()!
            }
            
        case 2: // Contextual based on insights
            if let insight = insights.first {
                switch insight.category {
                case .productivity:
                    let completionRate = insight.confidence
                    if completionRate > 0.7 {
                        return "I've noticed you've been crushing your tasks lately - completing about \(Int(completionRate * 100))% of what you set out to do. I'd love to hear about your approach to staying so consistent."
                    } else {
                        return "I see you're working on building your task completion rhythm. I'm curious about what strategies you're exploring to help you feel more on track."
                    }
                case .sentiment:
                    return insight.title.contains("Positive") ?
                        "Your recent entries show such beautiful growth in positivity. I'd love to hear about the shifts you've noticed in yourself." :
                        "I can see you've been working through some challenging feelings in your writing. I'm curious about how you're taking care of yourself through this time."
                case .goalProgress:
                    return "Your goals really seem to energize you! When you write about them, there's such passion in your words. I'd love to hear which goal feels most alive for you right now."
                default:
                    return frequentKeywords.isEmpty ? "Looking at your recent entries, I'm curious about what patterns you're noticing in yourself." : "I've been noticing you write about \(frequentKeywords.first!) quite often. I'd love to hear what that tells you about where your energy is flowing."
                }
            }
            // Fallback with potential data reference
            return frequentKeywords.isEmpty ? "I'd love to hear about one thing you're learning about yourself lately." : "Looking at your recent writing, especially around \(frequentKeywords.first!), I'm curious about what insights are emerging for you."
            
        default: // Goal setting stage
            let goalTemplates = [
                "Looking ahead to tomorrow, I'd love to hear about one small thing you could do that would make you proud.",
                "If you could accomplish just one meaningful thing this week, I'm curious about what would light you up.",
                "I'd love to hear about one way you could build on today's energy tomorrow.",
                insights.contains(where: { $0.category == .momentum }) ? "You've been building such good momentum - I'm curious about how you want to keep that going." : "I'd love to hear what would make tomorrow feel like a win for you."
            ]
            return goalTemplates.randomElement()!
        }
    }
    
    func generateGoalSettingPrompt() -> String {
        let prompts = [
            "Looking ahead, I'd love to hear about one small step you could take tomorrow to move closer to your goals.",
            "If you could accomplish just one thing this week, I'm curious about what would make you feel most proud.",
            "What challenge are you facing that you'd like to tackle differently tomorrow?",
            "I'm curious about how you could make tomorrow even better than today."
        ]
        return prompts.randomElement() ?? prompts[0]
    }
    
    // MARK: - Motivational Phrases
    
    func generateMotivationalPhrase() -> String {
        do {
            let entries = try DatabaseManager.shared.fetchAllActive(limit: 20)
            
            if entries.isEmpty {
                return getDefaultMotivationalPhrase()
            }
            
            // Analyze recent sentiment
            let recentSentiment = calculateRecentSentiment(entries: entries)
            let productivityLevel = calculateProductivityLevel(entries: entries)
            let goalProgress = calculateGoalProgress(entries: entries)
            
            // Generate phrase based on patterns
            if recentSentiment > 0.6 && productivityLevel > 0.7 {
                return getHighEnergyPhrase()
            } else if recentSentiment < 0.3 {
                return getEncouragingPhrase()
            } else if productivityLevel < 0.4 {
                return getProductivityPhrase()
            } else if goalProgress > 0.6 {
                return getGoalFocusedPhrase()
            } else {
                return getBalancedPhrase()
            }
            
        } catch {
            return getDefaultMotivationalPhrase()
        }
    }
    
    private func calculateRecentSentiment(entries: [Entry]) -> Double {
        let recentEntries = entries.prefix(10)
        let sentiments = recentEntries.compactMap { entry -> Double? in
            if entry.type == .raw {
                return analyzeSentiment(for: entry.text)
            }
            return nil
        }
        
        guard !sentiments.isEmpty else { return 0.5 }
        return sentiments.reduce(0, +) / Double(sentiments.count)
    }
    
    private func calculateProductivityLevel(entries: [Entry]) -> Double {
        let todoEntries = entries.filter { $0.type == .todos }
        guard !todoEntries.isEmpty else { return 0.5 }
        
        // This is a simplified calculation - in a real app you'd fetch todo items
        return Double(todoEntries.count) / 10.0 // Normalize based on expected entries
    }
    
    private func calculateGoalProgress(entries: [Entry]) -> Double {
        let goalEntries = entries.filter { $0.type == .goals }
        guard !goalEntries.isEmpty else { return 0.5 }
        
        // This is a simplified calculation - in a real app you'd analyze goal completion
        return Double(goalEntries.count) / 5.0 // Normalize based on expected entries
    }
    
    private func getHighEnergyPhrase() -> String {
        let phrases = [
            "You're on fire!",
            "Crushing it today!",
            "Momentum building!",
            "Energy is flowing!",
            "Riding the wave!"
        ]
        return phrases.randomElement() ?? phrases[0]
    }
    
    private func getEncouragingPhrase() -> String {
        let phrases = [
            "You've got this!",
            "One step forward!",
            "Progress over perfection!",
            "Small wins matter!",
            "Keep going strong!"
        ]
        return phrases.randomElement() ?? phrases[0]
    }
    
    private func getProductivityPhrase() -> String {
        let phrases = [
            "Focus and flow!",
            "Time to shine!",
            "Make it happen!",
            "Productivity mode!",
            "Ready to conquer!"
        ]
        return phrases.randomElement() ?? phrases[0]
    }
    
    private func getGoalFocusedPhrase() -> String {
        let phrases = [
            "Goals in sight!",
            "Dreams becoming real!",
            "Vision to reality!",
            "Target locked in!",
            "Mission in progress!"
        ]
        return phrases.randomElement() ?? phrases[0]
    }
    
    private func getBalancedPhrase() -> String {
        let phrases = [
            "Growing every day!",
            "Journey continues!",
            "Steady progress!",
            "Building momentum!",
            "On the path!"
        ]
        return phrases.randomElement() ?? phrases[0]
    }
    
    private func getDefaultMotivationalPhrase() -> String {
        let phrases = [
            "Ready to grow!",
            "New day, new you!",
            "Time to reflect!",
            "Journey begins!",
            "Let's do this!"
        ]
        return phrases.randomElement() ?? phrases[0]
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
    
    func generateRealisticMockData() -> ([Entry], [TodoItem], [GoalItem]) {
        let calendar = Calendar.current
        let now = Date()
        var entries: [Entry] = []
        var todoItems: [TodoItem] = []
        var goalItems: [GoalItem] = []
        
        // Create 7 days of realistic data with a professional growth story
        for i in 0..<7 {
            let date = calendar.date(byAdding: .day, value: -i, to: now) ?? now
            
            // Professional-focused raw entries showing career and life balance growth
            let rawTexts = [
                "Finally sent that proposal I've been perfecting for weeks. The client feedback was positive and I feel confident about my strategic thinking. Learning to trust my expertise more.",
                "Declined working late tonight to have dinner with friends. Six months ago I would have felt guilty, but setting boundaries is helping me show up better at work and in life.",
                "Tough day with back-to-back meetings and competing deadlines. Instead of panicking like I used to, I prioritized ruthlessly and communicated clearly with my team. Growth in action.",
                "Had my quarterly review today. My manager noticed how much my communication skills have improved. All those uncomfortable conversations I've been having are paying off.",
                "Networking event felt less draining than usual. I'm getting better at authentic professional relationships instead of just collecting business cards. Quality over quantity.",
                "Presented to senior leadership today and didn't apologize for taking up their time. I'm learning that my insights have value and deserve space in the room.",
                "Wrapping up a challenging week. The old me would have burned out by Wednesday, but I've been managing my energy better. Small sustainable changes are adding up."
            ]
            
            let entry = Entry(
                id: UUID().uuidString,
                userId: "demo-user",
                type: .raw,
                title: nil,
                text: rawTexts[i],
                tags: ["demo", "professional-growth"],
                createdAt: date,
                updatedAt: date,
                deletedAt: nil
            )
            entries.append(entry)
            
            // Professional-focused todos
            let todoEntry = Entry(
                id: UUID().uuidString,
                userId: "demo-user",
                type: .todos,
                title: "Professional Tasks",
                text: "",
                tags: ["demo"],
                createdAt: date,
                updatedAt: date,
                deletedAt: nil
            )
            entries.append(todoEntry)
            
            // Realistic professional todos with improving completion
            let completionRate = 0.5 + (Double(6-i) * 0.08) // Improves from 50% to 98%
            let professionalTodos = [
                "Review quarterly metrics",
                "Follow up on client proposal",
                "One-on-one with direct report",
                "Update project timeline",
                "Industry reading (15 min)",
                "Send thank you note",
                "Block focus time tomorrow"
            ]
            
            let dayTodos = professionalTodos.shuffled().prefix(5)
            for (index, todoText) in dayTodos.enumerated() {
                let isDone = Double.random(in: 0...1) < completionRate
                let todoItem = TodoItem(
                    id: Int64(todoItems.count + 1),
                    entryId: todoEntry.id,
                    position: index,
                    text: todoText,
                    isDone: isDone
                )
                todoItems.append(todoItem)
            }
            
            // Add some professional goals
            if i == 6 { // Only for the oldest entry to avoid duplication
                let goalEntry = Entry(
                    id: UUID().uuidString,
                    userId: "demo-user",
                    type: .goals,
                    title: "Q4 Professional Goals",
                    text: "",
                    tags: ["demo", "career"],
                    createdAt: date,
                    updatedAt: date,
                    deletedAt: nil
                )
                entries.append(goalEntry)
                
                let professionalGoals = [
                    "Lead cross-functional project successfully",
                    "Improve public speaking confidence",
                    "Build stronger stakeholder relationships",
                    "Develop junior team member",
                    "Complete leadership training program"
                ]
                
                for (index, goalText) in professionalGoals.enumerated() {
                    let goalItem = GoalItem(
                        id: Int64(goalItems.count + 1),
                        entryId: goalEntry.id,
                        position: index,
                        bullet: goalText
                    )
                    goalItems.append(goalItem)
                }
            }
        }
        
        return (entries, todoItems, goalItems)
    }
}
