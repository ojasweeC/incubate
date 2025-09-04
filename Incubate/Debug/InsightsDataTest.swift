import Foundation

// Test file to verify insights data generation
class InsightsDataTest {
    static func runTest() {
        print("📈 Testing Insights Data Generation...")
        
        let inkyService = InkyAIService.shared
        
        // Test demo data generation
        print("\n🎯 Demo Data Generation Test:")
        print("=" * 40)
        
        let demoEntries = inkyService.generateDemoEntries()
        print("Generated \(demoEntries.count) demo entries")
        
        let rawEntries = demoEntries.filter { $0.type == .raw }
        print("Raw entries: \(rawEntries.count)")
        
        // Test sentiment analysis on demo entries
        print("\n📊 Sentiment Analysis on Demo Entries:")
        print("=" * 50)
        
        for (index, entry) in rawEntries.prefix(5).enumerated() {
            let baseSentiment = inkyService.analyzeSentiment(for: entry.text)
            let enhancedSentiment = inkyService.analyzeEnhancedSentiment(for: entry.text)
            let isPositive = enhancedSentiment > 0.6
            
            print("Entry \(index + 1):")
            print("Text: \"\(entry.text)\"")
            print("Base: \(String(format: "%.3f", baseSentiment)), Enhanced: \(String(format: "%.3f", enhancedSentiment))")
            print("Positive: \(isPositive ? "✅" : "❌")")
            print("-" * 30)
        }
        
        // Test weekly data simulation
        print("\n📅 Weekly Data Simulation:")
        print("=" * 30)
        
        let calendar = Calendar.current
        let now = Date()
        let dayNames = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
        
        for i in 0..<7 {
            let date = calendar.date(byAdding: .day, value: -i, to: now) ?? now
            let dayOfWeek = calendar.component(.weekday, from: date) - 1
            let dayName = dayNames[dayOfWeek]
            
            let dayStart = calendar.startOfDay(for: date)
            let dayEnd = calendar.date(byAdding: .day, value: 1, to: dayStart) ?? dayStart
            
            let dayEntries = rawEntries.filter { entry in
                entry.createdAt >= dayStart && entry.createdAt < dayEnd
            }
            
            if !dayEntries.isEmpty {
                let sentiments = dayEntries.compactMap { entry -> Double? in
                    inkyService.analyzeEnhancedSentiment(for: entry.text)
                }
                
                let averageSentiment = sentiments.reduce(0, +) / Double(sentiments.count)
                let hasPositiveSentiment = averageSentiment > 0.6
                
                print("\(dayName): \(dayEntries.count) entries, sentiment: \(String(format: "%.3f", averageSentiment)) (\(hasPositiveSentiment ? "✅" : "❌"))")
            } else {
                print("\(dayName): No entries")
            }
        }
        
        print("\n✅ Insights Data Test Complete!")
        print("The insights chart should now display data with enhanced sentiment analysis.")
    }
}

// Extension to repeat strings
extension String {
    static func * (left: String, right: Int) -> String {
        return String(repeating: left, count: right)
    }
}
