import SwiftUI

struct InsightsView: View {
    @StateObject private var vm = InsightsViewModel()

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                if vm.isLoading {
                    ProgressView("Analyzing your patterns...")
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding()
                } else if let errorMessage = vm.errorMessage {
                    Text("Error: \(errorMessage)")
                        .foregroundColor(.red)
                        .padding()
                } else {
                    WeeklySentimentChart(data: vm.weeklySentimentData)
                }
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
        .refreshable {
            vm.refreshData()
        }
    }
}

struct WeeklySentimentChart: View {
    let data: [WeeklySentimentData]
    
    var body: some View {
        SoftCard {
            VStack(alignment: .leading, spacing: 16) {
                Text("Weekly Sentiment Pattern")
                    .font(AppFonts.headline)
                    .foregroundColor(AppColors.ink)
                
                Text("Days when you expressed positive feelings")
                    .font(.caption)
                    .foregroundColor(AppColors.seaMoss)
                
                HStack(alignment: .bottom, spacing: 8) {
                    ForEach(data) { dayData in
                        VStack(spacing: 8) {
                            // Sentiment bar
                            VStack(spacing: 0) {
                                Spacer()
                                
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(dayData.hasPositiveSentiment ? AppColors.seaMoss : Color.gray.opacity(0.3))
                                    .frame(width: 24, height: max(4, CGFloat(dayData.sentimentScore * 60)))
                                    .overlay(
                                        // Show entry count as small dots
                                        HStack(spacing: 2) {
                                            ForEach(0..<min(dayData.entryCount, 3), id: \.self) { _ in
                                                Circle()
                                                    .fill(Color.white)
                                                    .frame(width: 3, height: 3)
                                            }
                                        }
                                        .offset(y: -2)
                                    )
                            }
                            .frame(height: 60)
                            
                            // Day label
                            Text(dayData.dayOfWeek)
                                .font(.caption2)
                                .foregroundColor(AppColors.ink)
                                .fontWeight(dayData.hasPositiveSentiment ? .semibold : .regular)
                        }
                    }
                }
                .frame(maxWidth: .infinity)
                
                // Legend
                HStack(spacing: 16) {
                    HStack(spacing: 4) {
                        RoundedRectangle(cornerRadius: 2)
                            .fill(AppColors.seaMoss)
                            .frame(width: 12, height: 8)
                        Text("Positive days")
                            .font(.caption2)
                            .foregroundColor(AppColors.ink)
                    }
                    
                    HStack(spacing: 4) {
                        RoundedRectangle(cornerRadius: 2)
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: 12, height: 8)
                        Text("Neutral days")
                            .font(.caption2)
                            .foregroundColor(AppColors.ink)
                    }
                    
                    Spacer()
                }
                
                // Summary
                if !data.isEmpty {
                    let positiveDays = data.filter { $0.hasPositiveSentiment }.count
                    let totalEntries = data.reduce(0) { $0 + $1.entryCount }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("This week: \(positiveDays) positive days out of 7")
                            .font(.caption)
                            .foregroundColor(AppColors.seaMoss)
                        
                        if totalEntries > 0 {
                            Text("\(totalEntries) journal entries analyzed")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
        }
    }
}

struct InsightsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack { InsightsView() }
    }
}


