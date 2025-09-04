import Foundation
import SwiftUI

@MainActor
final class DailyReflectionViewModel: ObservableObject {
    @Published var currentReflection: DailyReflection?
    @Published var isLoading = false
    @Published var isThinking = false
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
        
        var title: String {
            switch self {
            case .greeting: return "Daily Check-in"
            case .contextual: return "Insights & Patterns"
            case .goalSetting: return "Looking Forward"
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
            isThinking = false
            addInkyMessage(inkyService.generateDailyGreeting(), type: .question)
        }
        
        // Analyze data and generate insights
        Task {
            await generateInsights()
        }
    }
    
    func sendUserMessage(_ content: String, completion: @escaping () -> Void = {}) {
        guard !content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        // Add user message
        addUserMessage(content)
        
        // Show thinking state
        isThinking = true
        
        // Progress conversation based on current stage with a delay
        Task {
            // Simulate thinking time (1-3 seconds)
            let thinkingTime = Double.random(in: 1.0...3.0)
            try? await Task.sleep(nanoseconds: UInt64(thinkingTime * 1_000_000_000))
            
            await MainActor.run {
                switch conversationStage {
                case .greeting:
                    progressToContextual()
                case .contextual:
                    progressToGoalSetting()
                case .goalSetting:
                    completeReflection()
                }
                isThinking = false
                
                // Call completion callback
                completion()
            }
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
    
    private func saveReflection() {
        guard let reflection = currentReflection else { return }
        
        do {
            // Convert conversation to Q&A pairs for database
            var qaPairs: [(String, String)] = []
            var pendingQuestion = ""
            
            for message in reflection.conversation {
                if message.sender == .inky && (message.messageType == .question || message.messageType == .text) {
                    pendingQuestion = message.content
                } else if message.sender == .user && !pendingQuestion.isEmpty {
                    qaPairs.append((pendingQuestion, message.content))
                    pendingQuestion = ""
                }
            }
            
            // Create title with date
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .medium
            let dateString = dateFormatter.string(from: reflection.date)
            let title = "Daily Reflection - \(dateString)"
            
            // Save to database
            let entry = try databaseManager.saveNewReflection(
                title: title,
                qas: qaPairs
            )
            
            print("✅ Reflection saved successfully: \(entry.id)")
            
        } catch {
            errorMessage = "Failed to save reflection: \(error.localizedDescription)"
            showingError = true
        }
    }
}
