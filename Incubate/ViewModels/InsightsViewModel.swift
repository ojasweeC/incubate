import Foundation

struct WeeklySentimentData: Identifiable {
    let id = UUID()
    let dayOfWeek: String
    let sentimentScore: Double // 0.0 to 1.0
    let entryCount: Int
    let hasPositiveSentiment: Bool
}

final class InsightsViewModel: ObservableObject {
    @Published var weeklySentimentData: [WeeklySentimentData] = []
    @Published var isLoading = true
    @Published var errorMessage: String?

    init() {
        loadRealData()
    }

    func loadRealData() {
        isLoading = true
        
        do {
            let entries = try DatabaseManager.shared.fetchAllActive()
            let inkyService = InkyAIService.shared
            
            // Analyze entries by day of week
            let calendar = Calendar.current
            let now = Date()
            
            // Get the last 7 days
            var weeklyData: [WeeklySentimentData] = []
            let dayNames = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
            
            for i in 0..<7 {
                let date = calendar.date(byAdding: .day, value: -i, to: now) ?? now
                let dayOfWeek = calendar.component(.weekday, from: date) - 1 // Convert to 0-6
                let dayName = dayNames[dayOfWeek]
                
                // Get entries for this day
                let dayStart = calendar.startOfDay(for: date)
                let dayEnd = calendar.date(byAdding: .day, value: 1, to: dayStart) ?? dayStart
                
                let dayEntries = entries.filter { entry in
                    entry.createdAt >= dayStart && entry.createdAt < dayEnd && entry.type == .raw
                }
                
                if dayEntries.isEmpty {
                    // No data for this day
                    weeklyData.append(WeeklySentimentData(
                        dayOfWeek: dayName,
                        sentimentScore: 0.5, // Neutral
                        entryCount: 0,
                        hasPositiveSentiment: false
                    ))
                } else {
                    // Calculate average sentiment for the day
                    let sentiments = dayEntries.compactMap { entry -> Double? in
                        inkyService.analyzeSentiment(for: entry.text)
                    }
                    
                    let averageSentiment = sentiments.isEmpty ? 0.5 : sentiments.reduce(0, +) / Double(sentiments.count)
                    let hasPositiveSentiment = averageSentiment > 0.6
                    
                    weeklyData.append(WeeklySentimentData(
                        dayOfWeek: dayName,
                        sentimentScore: averageSentiment,
                        entryCount: dayEntries.count,
                        hasPositiveSentiment: hasPositiveSentiment
                    ))
                }
            }
            
            // Reverse to show most recent day first
            weeklySentimentData = weeklyData.reversed()
            isLoading = false
            
        } catch {
            errorMessage = "Failed to load insights: \(error.localizedDescription)"
            isLoading = false
        }
    }
    
    func refreshData() {
        loadRealData()
    }
}


