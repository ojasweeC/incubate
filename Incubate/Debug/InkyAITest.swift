import Foundation
import NaturalLanguage

// Simple test to verify Inky AI service functionality
class InkyAITest {
    static func runBasicTest() {
        print("Testing Inky AI Service...")
        
        // Test sentiment analysis
        let testTexts = [
            "Today was amazing! I feel great!",
            "I'm having a really difficult time right now.",
            "It's just another regular day, nothing special.",
            "I'm so grateful for today's opportunities and feeling blessed.",
            "Feeling anxious and overwhelmed but trying to stay positive."
        ]
        
        for text in testTexts {
            let baseSentiment = InkyAIService.shared.analyzeSentiment(for: text)
            let enhancedSentiment = InkyAIService.shared.analyzeEnhancedSentiment(for: text)
            print("Text: '\(text)'")
            print("  Base Sentiment: \(String(format: "%.3f", baseSentiment))")
            print("  Enhanced Sentiment: \(String(format: "%.3f", enhancedSentiment))")
            print("  Improvement: \(String(format: "%.3f", enhancedSentiment - baseSentiment))")
        }
        
        // Test keyword extraction
        let sampleText = "I'm feeling motivated to work on my goals and improve my productivity today."
        let keywords = InkyAIService.shared.extractKeywords(from: sampleText)
        print("Keywords from '\(sampleText)': \(keywords)")
        
        // Test demo data generation
        let demoEntries = InkyAIService.shared.generateDemoEntries()
        print("Generated \(demoEntries.count) demo entries")
        
        let rawEntries = demoEntries.filter { $0.type == .raw }
        let todoEntries = demoEntries.filter { $0.type == .todos }
        let goalEntries = demoEntries.filter { $0.type == .goals }
        
        print("- Raw entries: \(rawEntries.count)")
        print("- Todo entries: \(todoEntries.count)")
        print("- Goal entries: \(goalEntries.count)")
        
        // Test pattern detection
        if let productivityInsight = InkyAIService.shared.detectProductivityPatterns(
            entries: demoEntries,
            todoItems: InkyAIService.shared.generateDemoTodoItems(for: todoEntries.map { $0.id })
        ) {
            print("✅ Productivity insight detected: \(productivityInsight.title)")
        }
        
        if let sentimentInsight = InkyAIService.shared.detectSentimentTrends(entries: demoEntries) {
            print("✅ Sentiment insight detected: \(sentimentInsight.title)")
        }
        
        let momentum = InkyAIService.shared.calculateWeeklyGrowthMomentum(entries: demoEntries)
        print("Weekly growth momentum: \(String(format: "%.2f", momentum))")
        
        print("Inky AI Service test completed successfully!")
    }
}
