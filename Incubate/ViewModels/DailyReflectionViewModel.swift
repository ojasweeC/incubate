import Foundation
import SwiftUI

@MainActor
final class DailyReflectionViewModel: ObservableObject {
    @Published var currentReflection: DailyReflection?
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var showingError = false
    
    private let inkyService = InkyAIService.shared
    private let databaseManager = DatabaseManager.shared
    
    // Conversation flow state
    @Published var conversationStage: ConversationStage = .greeting
    @Published var insights: [GrowthInsight] = []
    @Published var weeklyMomentum: Double = 0.0
    
    enum ConversationStage: Int, CaseIterable {
        case greeting = 0
        case contextual = 1
        case goalSetting = 2
        case completed = 3
        
        var title: String {
            switch self {
            case .greeting: return "Daily Check-in"
            case .contextual: return "Insights & Patterns"
            case .goalSetting: return "Looking Forward"
            case .completed: return "Reflection Complete"
            }
        }
    }
    
    init() {
        loadOrCreateTodayReflection()
    }
    
    // MARK: - Public Methods
    
    func startDailyReflection() {
        guard let reflection = currentReflection else { return }
        
        // Reset conversation if starting fresh
        if reflection.conversation.isEmpty {
            conversationStage = .greeting
            addInkyMessage(inkyService.generateDailyGreeting(), type: .question)
        }
        
        // Analyze data and generate insights
        Task {
            await generateInsights()
        }
    }
    
    func sendUserMessage(_ content: String) {
        guard !content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        // Add user message
        addUserMessage(content)
        
        // Progress conversation based on current stage
        switch conversationStage {
        case .greeting:
            progressToContextual()
        case .contextual:
            progressToGoalSetting()
        case .goalSetting:
            completeReflection()
        case .completed:
            // Conversation is already complete, no further action needed
            break
        }
    }
    
    func completeReflection() {
        guard var reflection = currentReflection else { return }
        
        // Calculate growth score based on conversation depth and insights
        let score = calculateGrowthScore()
        reflection.growthScore = score
        reflection.isCompleted = true
        
        // Add completion message
        let completionMessage = generateCompletionMessage(score: score)
        addInkyMessage(completionMessage, type: .celebration)
        
        // Move to completed stage
        conversationStage = .completed
        
        // Add closing sequence after a brief pause
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.addClosingSequence()
        }
        
        currentReflection = reflection
        saveReflection()
    }
    
    // MARK: - Private Methods
    
    private func loadOrCreateTodayReflection() {
        let today = Calendar.current.startOfDay(for: Date())
        
        // For demo purposes, create a new reflection each time
        // In production, you'd load from persistent storage
        currentReflection = DailyReflection(date: today)
    }
    
    private func generateInsights() async {
        isLoading = true
        
        do {
            var entries = try databaseManager.fetchAllActive()
            var todoItems: [TodoItem] = []
            var goalItems: [GoalItem] = []
            
            // If no entries exist, generate demo data for testing
            if entries.isEmpty {
                entries = inkyService.generateDemoEntries()
                let todoEntryIds = entries.filter { $0.type == .todos }.map { $0.id }
                let goalEntryIds = entries.filter { $0.type == .goals }.map { $0.id }
                todoItems = inkyService.generateDemoTodoItems(for: todoEntryIds)
                goalItems = inkyService.generateDemoGoalItems(for: goalEntryIds)
            } else {
                todoItems = try await fetchAllTodoItems(from: entries)
                goalItems = try await fetchAllGoalItems(from: entries)
            }
            
            var newInsights: [GrowthInsight] = []
            
            // Generate insights
            if let productivityInsight = inkyService.detectProductivityPatterns(entries: entries, todoItems: todoItems) {
                newInsights.append(productivityInsight)
            }
            
            if let sentimentInsight = inkyService.detectSentimentTrends(entries: entries) {
                newInsights.append(sentimentInsight)
            }
            
            if let goalInsight = inkyService.detectGoalProgressCorrelation(entries: entries, goalItems: goalItems) {
                newInsights.append(goalInsight)
            }
            
            // Calculate weekly momentum
            weeklyMomentum = inkyService.calculateWeeklyGrowthMomentum(entries: entries)
            
            await MainActor.run {
                self.insights = newInsights
                self.isLoading = false
            }
            
        } catch {
            await MainActor.run {
                self.errorMessage = "Failed to generate insights: \(error.localizedDescription)"
                self.showingError = true
                self.isLoading = false
            }
        }
    }
    
    private func fetchAllTodoItems(from entries: [Entry]) async throws -> [TodoItem] {
        var allTodoItems: [TodoItem] = []
        
        for entry in entries where entry.type == .todos {
            if let detail = try? databaseManager.fetchEntryDetail(id: entry.id),
               let todoItems = detail.todoItems {
                allTodoItems.append(contentsOf: todoItems)
            }
        }
        
        return allTodoItems
    }
    
    private func fetchAllGoalItems(from entries: [Entry]) async throws -> [GoalItem] {
        var allGoalItems: [GoalItem] = []
        
        for entry in entries where entry.type == .goals {
            if let detail = try? databaseManager.fetchEntryDetail(id: entry.id),
               let goalItems = detail.goalItems {
                allGoalItems.append(contentsOf: goalItems)
            }
        }
        
        return allGoalItems
    }
    
    private func progressToContextual() {
            conversationStage = .contextual
            
            // First, acknowledge their previous response
            addInkyMessage("Thank you for sharing that. I'm learning more about your patterns and what drives you.", type: .insight)
            
            // Then ask the next question after a brief pause
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                let userResponses = self.currentReflection?.conversation.filter { $0.sender == .user } ?? []
                let lastUserResponse = userResponses.last?.content ?? ""
                
                let contextualQuestion = self.inkyService.generateEmpathicQuestion(
                    userResponse: lastUserResponse,
                    conversationStage: self.conversationStage.rawValue,
                    insights: self.insights
                )
                
                self.addInkyMessage(contextualQuestion, type: .question)
            }
        }
    
    private func progressToGoalSetting() {
        conversationStage = .goalSetting
        
        // Add goal-setting prompt
        let goalPrompt = inkyService.generateGoalSettingPrompt()
        addInkyMessage(goalPrompt, type: .question)
    }
    
    private func addUserMessage(_ content: String) {
        guard var reflection = currentReflection else { return }
        
        let message = ConversationMessage(sender: .user, content: content)
        reflection.conversation.append(message)
        currentReflection = reflection
    }
    
    private func addInkyMessage(_ content: String, type: MessageType) {
        guard var reflection = currentReflection else { return }
        
        let message = ConversationMessage(sender: .inky, content: content, messageType: type)
        reflection.conversation.append(message)
        currentReflection = reflection
    }
    
    private func calculateGrowthScore() -> Int {
        var score = 5 // Base score
        
        // Bonus for conversation depth
        if let reflection = currentReflection {
            score += min(reflection.conversation.count / 2, 3)
        }
        
        // Bonus for insights
        score += min(insights.count, 2)
        
        // Bonus for positive momentum
        if weeklyMomentum > 0.1 {
            score += 1
        }
        
        return min(score, 10)
    }
    
    private func generateCompletionMessage(score: Int) -> String {
        switch score {
        case 8...10:
            return "Amazing work today! You're really building momentum and self-awareness. Keep this energy going!"
        case 6...7:
            return "Great reflection session! You're making solid progress and staying engaged with your growth journey."
        case 4...5:
            return "Good effort today! Every reflection builds your self-awareness muscle. Keep showing up!"
        default:
            return "Thanks for taking time to reflect today. Every small step counts toward your growth!"
        }
    }
    
    private func addClosingSequence() {
        guard let reflection = currentReflection else { return }
        
        // Add summary message
        let summaryMessage = generateSummaryMessage()
        addInkyMessage(summaryMessage, type: .insight)
        
        // Add final farewell after another pause
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            let farewellMessage = "Thank you for sharing your thoughts with me today. I'm proud of the growth I see in you. Until tomorrow!"
            self.addInkyMessage(farewellMessage, type: .celebration)
            
            // Trigger haptic feedback for completion
            HapticsService.playCompletionHaptic()
        }
    }
    
    private func generateSummaryMessage() -> String {
        guard let reflection = currentReflection else { return "" }
        
        let userMessages = reflection.conversation.filter { $0.sender == .user }
        let messageCount = userMessages.count
        
        var summary = "Here's what I noticed from our conversation today:\n\n"
        
        if messageCount >= 3 {
            summary += "• You shared \(messageCount) thoughtful responses - that shows real engagement with your growth journey\n"
        }
        
        if let score = reflection.growthScore {
            if score >= 8 {
                summary += "• Your growth score of \(score)/10 reflects excellent self-awareness and momentum\n"
            } else if score >= 6 {
                summary += "• Your growth score of \(score)/10 shows solid progress and commitment\n"
            } else {
                summary += "• Your growth score of \(score)/10 indicates you're building important reflection habits\n"
            }
        }
        
        if !insights.isEmpty {
            summary += "• I identified \(insights.count) key patterns in your journal entries that we discussed\n"
        }
        
        summary += "\nKeep up this amazing work! Every reflection makes you stronger."
        
        return summary
    }
    
    private func saveReflection() {
        guard let reflection = currentReflection else { return }
        
        do {
            // Convert conversation to Q&A format for database storage
            let qaPairs = convertConversationToQA(reflection.conversation)
            
            // Create a title based on the date and score
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .medium
            let dateString = dateFormatter.string(from: reflection.date)
            let title = "Daily Reflection - \(dateString)"
            
            // Save to database
            let entry = try databaseManager.saveNewReflection(
                title: title,
                qas: qaPairs
            )
            
            print("Daily reflection saved successfully with ID: \(entry.id)")
            
        } catch {
            print("Failed to save daily reflection: \(error.localizedDescription)")
            errorMessage = "Failed to save reflection: \(error.localizedDescription)"
            showingError = true
        }
    }
    
    private func convertConversationToQA(_ conversation: [ConversationMessage]) -> [(String, String)] {
        var qaPairs: [(String, String)] = []
        var currentQuestion = ""
        
        for message in conversation {
            if message.sender == .inky && message.messageType == .question {
                currentQuestion = message.content
            } else if message.sender == .user && !currentQuestion.isEmpty {
                qaPairs.append((currentQuestion, message.content))
                currentQuestion = ""
            }
        }
        
        return qaPairs
    }
}
