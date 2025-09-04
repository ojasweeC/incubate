import SwiftUI
import Foundation

struct DailyReflectionView: View {
    @StateObject private var viewModel = DailyReflectionViewModel()
    @Environment(\.dismiss) private var dismiss
    @State private var userInput = ""
    @State private var showingInsights = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Header with progress indicator
                headerSection
                
                // Conversation area
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            // Welcome message
                            if viewModel.currentReflection?.conversation.isEmpty == true {
                                welcomeSection
                            }
                            
                            // Conversation messages
                            ForEach(viewModel.currentReflection?.conversation ?? []) { message in
                                MessageBubble(message: message)
                            }
                            
                            // Loading indicator
                            if viewModel.isLoading {
                                HStack {
                                    ProgressView()
                                        .scaleEffect(0.8)
                                    Text("Analyzing your patterns...")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                .padding()
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 16)
                    }
                    .onChange(of: viewModel.currentReflection?.conversation.count) { _ in
                        // Scroll to bottom when new messages arrive
                        if let lastMessage = viewModel.currentReflection?.conversation.last {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                proxy.scrollTo(lastMessage.id, anchor: .bottom)
                            }
                        }
                    }
                }
                
                // Input section (only show if not completed)
                if viewModel.conversationStage != .completed {
                    inputSection
                } else {
                    completionSection
                }
            }
            .navigationTitle("Daily Reflection")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") { dismiss() }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingInsights.toggle()
                    } label: {
                        Image(systemName: "chart.line.uptrend.xyaxis")
                            .foregroundColor(AppColors.seaMoss)
                    }
                    .disabled(viewModel.insights.isEmpty)
                }
            }
            .sheet(isPresented: $showingInsights) {
                InsightsSheet(insights: viewModel.insights, momentum: viewModel.weeklyMomentum)
            }
            .alert("Error", isPresented: $viewModel.showingError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(viewModel.errorMessage ?? "An unknown error occurred")
            }
            .onAppear {
                viewModel.startDailyReflection()
            }
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: 12) {
            // Progress indicator
            HStack(spacing: 16) {
                ForEach(DailyReflectionViewModel.ConversationStage.allCases, id: \.self) { stage in
                    VStack(spacing: 4) {
                        Circle()
                            .fill(stage.rawValue <= viewModel.conversationStage.rawValue ? AppColors.seaMoss : Color.gray.opacity(0.3))
                            .frame(width: 12, height: 12)
                        Text(stage.title)
                            .font(.caption2)
                            .foregroundColor(stage.rawValue <= viewModel.conversationStage.rawValue ? AppColors.seaMoss : .secondary)
                    }
                }
            }
            
            // Weekly momentum indicator
            if viewModel.weeklyMomentum != 0.0 {
                HStack {
                    Image(systemName: viewModel.weeklyMomentum > 0 ? "arrow.up.circle.fill" : "arrow.down.circle.fill")
                        .foregroundColor(viewModel.weeklyMomentum > 0 ? .green : .orange)
                    Text("Weekly momentum: \(viewModel.weeklyMomentum > 0 ? "+" : "")\(String(format: "%.1f", viewModel.weeklyMomentum))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color(UIColor.systemGray6).opacity(0.5))
    }
    
    private var welcomeSection: some View {
        VStack(spacing: 16) {
            Image(systemName: "octopus")
                .font(.system(size: 48))
                .foregroundColor(AppColors.seaMoss)
            
            Text("Hi! I'm Inky")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(AppColors.ink)
            
            Text("I've been analyzing your journal entries and I'm excited to chat about your growth journey!")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Text("Let's start with a simple check-in...")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(24)
        .background(AppColors.beige.opacity(0.3))
        .cornerRadius(16)
    }
    
    private var inputSection: some View {
        VStack(spacing: 12) {
            Divider()
            
            HStack(spacing: 12) {
                TextField("Type your response...", text: $userInput, axis: .vertical)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .lineLimit(1...3)
                
                Button {
                    sendMessage()
                } label: {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.title2)
                        .foregroundColor(userInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? .gray : AppColors.seaMoss)
                }
                .disabled(userInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 16)
        }
        .background(Color(UIColor.systemBackground))
    }
    
    private var completionSection: some View {
        VStack(spacing: 16) {
            Divider()
            
            VStack(spacing: 12) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 48))
                    .foregroundColor(.green)
                
                Text("Reflection Complete!")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(AppColors.ink)
                
                if let score = viewModel.currentReflection?.growthScore {
                    Text("Growth Score: \(score)/10")
                        .font(.headline)
                        .foregroundColor(AppColors.seaMoss)
                }
                
                Text("Your thoughts have been saved and your growth journey continues!")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                
                Button {
                    dismiss()
                } label: {
                    Text("Done")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(AppColors.seaMoss)
                        .cornerRadius(12)
                }
            }
            .padding(24)
            .background(AppColors.beige.opacity(0.3))
            .cornerRadius(16)
            .padding(.horizontal, 16)
            .padding(.bottom, 16)
        }
        .background(Color(UIColor.systemBackground))
    }
    
    private func sendMessage() {
        let trimmedInput = userInput.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedInput.isEmpty else { return }
        
        viewModel.sendUserMessage(trimmedInput)
        userInput = ""
    }
}

// MARK: - Message Bubble

struct MessageBubble: View {
    let message: ConversationMessage
    
    var body: some View {
        HStack {
            if message.sender == .user {
                Spacer()
                messageContent
                    .background(AppColors.seaMoss)
                    .foregroundColor(.white)
            } else {
                messageContent
                    .background(Color(UIColor.systemGray5))
                    .foregroundColor(AppColors.ink)
                Spacer()
            }
        }
        .id(message.id)
    }
    
    private var messageContent: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(message.content)
                .font(.body)
                .multilineTextAlignment(message.sender == .user ? .trailing : .leading)
            
            HStack {
                if message.sender == .inky {
                    Text("Inky")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Text(message.timestamp, style: .time)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding(12)
        .cornerRadius(16)
        .frame(maxWidth: UIScreen.main.bounds.width * 0.75, alignment: message.sender == .user ? .trailing : .leading)
    }
}

// MARK: - Insights Sheet

struct InsightsSheet: View {
    let insights: [GrowthInsight]
    let momentum: Double
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Weekly momentum chart
                    momentumChart
                    
                    // Insights list
                    insightsList
                }
                .padding(16)
            }
            .navigationTitle("Your Growth Insights")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
    
    private var momentumChart: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Weekly Growth Momentum")
                .font(.headline)
                .foregroundColor(AppColors.ink)
            
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("This Week")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(String(format: "%.1f", momentum))
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(momentum > 0 ? .green : .orange)
                }
                
                Spacer()
                
                // Simple momentum visualization
                VStack(spacing: 4) {
                    Image(systemName: momentum > 0 ? "arrow.up.circle.fill" : "arrow.down.circle.fill")
                        .font(.title)
                        .foregroundColor(momentum > 0 ? .green : .orange)
                    Text(momentum > 0 ? "Building" : "Reflecting")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding(16)
            .background(Color(UIColor.systemGray6))
            .cornerRadius(12)
        }
    }
    
    private var insightsList: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Patterns & Insights")
                .font(.headline)
                .foregroundColor(AppColors.ink)
            
            if insights.isEmpty {
                Text("No insights available yet. Keep journaling to unlock personalized insights!")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color(UIColor.systemGray6))
                    .cornerRadius(12)
            } else {
                ForEach(insights) { insight in
                    InsightCard(insight: insight)
                }
            }
        }
    }
}

// MARK: - Insight Card

struct InsightCard: View {
    let insight: GrowthInsight
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(insight.title)
                    .font(.headline)
                    .foregroundColor(AppColors.ink)
                
                Spacer()
                
                Text("\(Int(insight.confidence * 100))%")
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(AppColors.seaMoss.opacity(0.2))
                    .foregroundColor(AppColors.seaMoss)
                    .cornerRadius(8)
            }
            
            Text(insight.description)
                .font(.body)
                .foregroundColor(.secondary)
            
            HStack {
                Text(insight.category.rawValue.capitalized)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(AppColors.beige)
                    .foregroundColor(AppColors.ink)
                    .cornerRadius(8)
                
                Spacer()
                
                if !insight.relatedEntries.isEmpty {
                    Text("\(insight.relatedEntries.count) related entries")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(16)
        .background(Color(UIColor.systemGray6))
        .cornerRadius(12)
    }
}

#Preview {
    DailyReflectionView()
}
