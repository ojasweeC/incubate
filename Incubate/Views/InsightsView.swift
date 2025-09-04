import SwiftUI
import Charts // If available, otherwise use custom drawing

struct InsightsView: View {
    @State private var entries: [Entry] = []
    @State private var todoItems: [TodoItem] = []

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Real growth momentum chart
                GrowthMomentumView(entries: entries, todoItems: todoItems)
            }
            .padding(16)
        }
        .navigationTitle("Insights")
        .background(
            ZStack {
                AppColors.backgroundGradient
                Color.white.opacity(0.9)
            }.ignoresSafeArea()
        )
        .onAppear {
            loadRealData()
        }
    }
    
    private func loadRealData() {
        Task {
            do {
                print("🔍 Loading data for insights...")
                
                // Load real entries and todo items from database
                let allEntries = try DatabaseManager.shared.fetchAllActive()
                print("📊 Total entries loaded: \(allEntries.count)")
                
                let rawEntries = allEntries.filter { $0.type == .raw }
                let todoEntries = allEntries.filter { $0.type == .todos }
                print("📝 Raw entries: \(rawEntries.count)")
                print("✅ Todo entries: \(todoEntries.count)")
                
                // Get todo items for the todo entries
                var allTodoItems: [TodoItem] = []
                for entry in todoEntries {
                    if let entryDetail = try? DatabaseManager.shared.fetchEntryDetail(id: entry.id),
                       let items = entryDetail.todoItems {
                        allTodoItems.append(contentsOf: items)
                        print("📋 Todo items for entry \(entry.id): \(items.count)")
                    }
                }
                
                print("🎯 Total todo items: \(allTodoItems.count)")
                
                await MainActor.run {
                    self.entries = rawEntries
                    self.todoItems = allTodoItems
                    print("✅ UI state updated - entries: \(self.entries.count), todos: \(self.todoItems.count)")
                }
            } catch {
                print("❌ Failed to load data for insights: \(error)")
            }
        }
    }
}

struct GrowthMomentumView: View {
    let entries: [Entry]
    let todoItems: [TodoItem]
    
    private var weeklyData: [DayData] {
        let calendar = Calendar.current
        let last7Days = Array(0..<7).compactMap { dayOffset in
            calendar.date(byAdding: .day, value: -dayOffset, to: Date())
        }.reversed()
        
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd"
        print("📅 Generated 7 days: \(last7Days.map { formatter.string(from: $0) })")
        print("📊 Total entries to analyze: \(entries.count)")
        print("📋 Total todo items to analyze: \(todoItems.count)")
        
        // Show actual entry dates
        if !entries.isEmpty {
            print("📝 Entry dates: \(entries.map { formatter.string(from: $0.createdAt) })")
        }
        
        return last7Days.map { date in
            let dayEntries = entries.filter { calendar.isDate($0.createdAt, inSameDayAs: date) }
            let dayTodos = todoItems.filter { todo in
                dayEntries.contains { $0.id == todo.entryId }
            }
            
            // 🔍 Debug each entry’s text + sentiment
            for e in dayEntries {
                let t = (e.text ?? "").prefix(80)
                let s = InkyAIService.shared.analyzeSentiment(for: e.text ?? "")
                print("🧪 sample '\(t)'… → \(s)")
            }

            let sentiment = dayEntries.isEmpty
                ? 0.5
                : dayEntries
                    .map { InkyAIService.shared.analyzeSentiment(for: $0.text ?? "") }
                    .reduce(0, +) / Double(dayEntries.count)

            
            let completionRate = dayTodos.isEmpty ? 0.0 :
                Double(dayTodos.filter { $0.isDone }.count) / Double(dayTodos.count)
            
            print("📅 Date: \(date)")
            print("📝 Entries: \(dayEntries.count)")
            print("✅ Todos: \(dayTodos.count)")
            
            print("😊 Sentiment: \(sentiment)")
            print("✓ Completion: \(completionRate)")
            print("---")
            
            // Detect "proud moments" - high sentiment + achievement words
            let proudMoments = dayEntries.filter { entry in
                let sentiment = InkyAIService.shared.analyzeSentiment(for: entry.text ?? "")
                let proudWords = ["proud", "accomplished", "achieved", "finished", "completed", "victory", "success"]
                let hasProudWords = proudWords.contains { (entry.text ?? "").lowercased().contains($0) }
                return sentiment > 0.7 && hasProudWords
            }.count
            
            return DayData(
                date: date,
                sentiment: sentiment,
                completionRate: completionRate,
                proudMoments: proudMoments
            )
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Your Growth This Week")
                .font(.headline)
            
            // Simple bar chart for proud moments
            HStack(alignment: .bottom, spacing: 8) {
                ForEach(weeklyData, id: \.date) { day in
                    VStack(spacing: 4) {
                        // Proud moments indicator
                        if day.proudMoments > 0 {
                            Circle()
                                .fill(Color.orange)
                                .frame(width: 8, height: 8)
                        } else {
                            Circle()
                                .fill(Color.clear)
                                .frame(width: 8, height: 8)
                        }
                        
                        // Growth bar (combination of sentiment + completion)
                        let growthScore = (day.sentiment + day.completionRate) / 2
                        Rectangle()
                            .fill(LinearGradient(
                                colors: [AppColors.seaMoss, AppColors.teal],
                                startPoint: .bottom,
                                endPoint: .top
                            ))
                            .frame(width: 30, height: max(4, growthScore * 80))
                            .clipShape(RoundedRectangle(cornerRadius: 4))
                        
                        Text(dayLabel(day.date))
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .frame(height: 120)
            
            // Legend
            HStack {
                HStack(spacing: 4) {
                    Circle()
                        .fill(Color.orange)
                        .frame(width: 8, height: 8)
                    Text("Proud moments")
                        .font(.caption)
                }
                
                Spacer()
                
                Text("Growth momentum")
                    .font(.caption)
            }
            .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
    private func dayLabel(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "E"
        return formatter.string(from: date)
    }
}

struct DayData {
    let date: Date
    let sentiment: Double
    let completionRate: Double
    let proudMoments: Int
}

struct InsightsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack { InsightsView() }
    }
}


