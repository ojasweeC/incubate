import Foundation

// Test file to verify enhanced sentiment analysis functionality
class SentimentAnalysisTest {
    static func runTest() {
        print("🧪 Testing Enhanced Sentiment Analysis...")
        
        let inkyService = InkyAIService.shared
        
        // Test cases with various emotional keywords
        let testCases = [
            ("I'm so grateful for today's opportunities", "Should be highly positive"),
            ("Feeling thankful and blessed for this moment", "Should be highly positive"),
            ("Today was amazing and I feel joyful", "Should be positive"),
            ("I'm feeling anxious and overwhelmed", "Should be negative"),
            ("Struggling with motivation but staying hopeful", "Should be mixed/neutral"),
            ("Feeling proud of my progress and excited for tomorrow", "Should be positive"),
            ("Grateful for the lessons learned from challenges", "Should be positive"),
            ("Feeling tired and drained from work", "Should be negative"),
            ("Appreciate the small wins and feeling content", "Should be positive"),
            ("Feeling lonely and disconnected today", "Should be negative")
        ]
        
        print("\n📊 Sentiment Analysis Results:")
        print("=" * 60)
        
        for (text, expected) in testCases {
            let baseSentiment = inkyService.analyzeSentiment(for: text)
            let enhancedSentiment = inkyService.analyzeEnhancedSentiment(for: text)
            
            print("Text: \"\(text)\"")
            print("Expected: \(expected)")
            print("Base Sentiment: \(String(format: "%.3f", baseSentiment))")
            print("Enhanced Sentiment: \(String(format: "%.3f", enhancedSentiment))")
            print("Improvement: \(String(format: "%.3f", enhancedSentiment - baseSentiment))")
            print("-" * 40)
        }
        
        // Test gratitude detection specifically
        print("\n🙏 Gratitude Detection Test:")
        print("=" * 40)
        
        let gratitudeTests = [
            "I'm grateful for everything",
            "Feeling thankful today",
            "So appreciative of this moment",
            "Blessed to have this opportunity",
            "I appreciate your help"
        ]
        
        for text in gratitudeTests {
            let enhancedSentiment = inkyService.analyzeEnhancedSentiment(for: text)
            let isPositive = enhancedSentiment > 0.6
            print("'\(text)' -> \(String(format: "%.3f", enhancedSentiment)) (\(isPositive ? "✅ Positive" : "❌ Not Positive"))")
        }
        
        print("\n✅ Sentiment Analysis Test Complete!")
    }
}

// Extension to repeat strings
extension String {
    static func * (left: String, right: Int) -> String {
        return String(repeating: left, count: right)
    }
}
