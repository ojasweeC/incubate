import Foundation

struct MonthlyScore: Identifiable {
    let id = UUID()
    let month: String
    let score: Int
}

final class InsightsViewModel: ObservableObject {
    @Published var monthlyHighMoments: [MonthlyScore] = []
    @Published var topThemes: [String] = []

    init() {
        loadMockData()
    }

    func loadMockData() {
        monthlyHighMoments = [
            MonthlyScore(month: "Jan", score: 60),
            MonthlyScore(month: "Feb", score: 55),
            MonthlyScore(month: "Mar", score: 70),
            MonthlyScore(month: "Apr", score: 65),
            MonthlyScore(month: "May", score: 72),
            MonthlyScore(month: "Jun", score: 80)
        ]
        topThemes = ["Gratitude", "Focus", "Health", "Learning"]
    }
}


