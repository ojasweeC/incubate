import SwiftUI

struct MainView: View {
    @EnvironmentObject private var userVM: UserProfileViewModel
    @State private var showingEntryTypeSelector = false
    @StateObject private var reflectionVM = DailyReflectionViewModel()
    @State private var isReflectionCompleted = false

    var body: some View {
        VStack(spacing: 24) {
            header
            streakChip
            entryBuckets
            inkySection
            Spacer()
            buttonRow
        }
        .padding(16)
        .navigationTitle("")
        .navigationBarHidden(true)
        .background(
            ZStack {
                AppColors.backgroundGradient
                Color.white.opacity(0.9)
            }.ignoresSafeArea()
        )
        .sheet(isPresented: $showingEntryTypeSelector) {
            EntryTypeSelectorView()
        }
        .onAppear {
            checkDailyReflectionStatus()
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Welcome back, \(userVM.firstName)")
                .font(AppFonts.title)
                .foregroundColor(AppColors.ink)
            Text("Jot it down.")
                .font(AppFonts.body)
                .foregroundColor(AppColors.seaMoss)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var streakChip: some View {
        HStack(spacing: 8) {
            Text("\(userVM.streakCount)-day streak")
                .font(AppFonts.headline)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(AppColors.beige)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .shadow(color: AppColors.beigeShadow, radius: 8, x: 0, y: 4)
        .accessibilityLabel("Daily streak \(userVM.streakCount) days")
    }

    private var entryBuckets: some View {
        VStack(spacing: 16) {
            HStack(spacing: 16) {
                bucketCard(type: .reflection, icon: "bubble.left.and.bubble.right")
                bucketCard(type: .goals, icon: "target")
            }
            HStack(spacing: 16) {
                bucketCard(type: .todos, icon: "checkmark.circle")
                bucketCard(type: .raw, icon: "pencil")
            }
        }
    }

    private func bucketCard(type: EntryType, icon: String) -> some View {
        NavigationLink {
            EntriesListView(entryType: type)
        } label: {
            SoftCard {
                VStack(spacing: 12) {
                    Image(systemName: icon)
                        .font(.system(size: 24))
                        .foregroundColor(AppColors.seaMoss)
                    Text(type.title)
                        .font(AppFonts.headline)
                        .foregroundColor(AppColors.ink)
                }
                .frame(maxWidth: .infinity, minHeight: 100)
            }
        }
        .accessibilityLabel("Open \(type.title) bucket")
    }

    private var buttonRow: some View {
        HStack(spacing: 24) {
            NavigationLink { InsightsView() } label: {
                Image(systemName: "chart.line.uptrend.xyaxis")
                    .font(.system(size: 24))
            }
            .buttonStyle(BeigeCircleButtonStyle())
            .accessibilityLabel("Open Insights")

            Button {
                showingEntryTypeSelector = true
            } label: {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 26))
            }
            .buttonStyle(BeigeCircleButtonStyle())
            .accessibilityLabel("Add new entry")

            Button {
                generateMockData()
            } label: {
                if isGeneratingMockData {
                    ProgressView()
                        .scaleEffect(0.8)
                } else {
                    Image(systemName: "wand.and.stars")
                        .font(.system(size: 22))
                }
            }
            .buttonStyle(BeigeCircleButtonStyle())
            .disabled(isGeneratingMockData)
            .accessibilityLabel(isGeneratingMockData ? "Generating mock data..." : "Generate mock data")

            NavigationLink { SettingsView() } label: {
                Image(systemName: "person.crop.circle")
                    .font(.system(size: 24))
            }
            .buttonStyle(BeigeCircleButtonStyle())
            .accessibilityLabel("Open Profile/Settings")
        }
    }
    
    private var inkySection: some View {
        VStack(spacing: 16) {
            if isReflectionCompleted {
                // Show takeaway from completed reflection
                dailyTakeawayView
            } else {
                // Show daily reflection conversation
                dailyReflectionView
            }
        }
    }
    
    private var dailyReflectionView: some View {
        VStack(spacing: 16) {
            // Header
            HStack(spacing: 12) {
                Image(systemName: "octopus")
                    .font(.system(size: 24))
                    .foregroundColor(.white)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Daily Reflection")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                    Text("Take a moment to reflect")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.9))
                }
                
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            
            // Conversation area
            if reflectionVM.currentReflection?.conversation.isEmpty == true {
                // Start conversation
                Button {
                    reflectionVM.startDailyReflection()
                } label: {
                    HStack {
                        Image(systemName: "play.circle.fill")
                        Text("Start Reflection")
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(Color.white.opacity(0.2))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .padding(.horizontal, 20)
            } else {
                // Show conversation
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(reflectionVM.currentReflection?.conversation ?? []) { message in
                            MessageBubble(message: message)
                        }
                        
                        if reflectionVM.isThinking {
                            ThinkingBubble()
                        }
                    }
                    .padding(.horizontal, 20)
                }
                .frame(maxHeight: 200)
                
                // Input area
                if reflectionVM.conversationStage != .completed {
                    HStack(spacing: 12) {
                        TextField("Type your response...", text: $reflectionVM.userInput)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        
                        Button {
                            reflectionVM.sendUserMessage(reflectionVM.userInput) {
                                reflectionVM.userInput = ""
                                
                                // Check if conversation is complete
                                if reflectionVM.conversationStage == .completed {
                                    reflectionVM.markReflectionComplete()
                                    isReflectionCompleted = true
                                }
                            }
                        } label: {
                            Image(systemName: "paperplane.fill")
                                .foregroundColor(.white)
                                .padding(8)
                                .background(AppColors.seaMoss)
                                .clipShape(Circle())
                        }
                        .disabled(reflectionVM.userInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    }
                    .padding(.horizontal, 20)
                }
            }
            
            // Background
            LinearGradient(
                colors: [AppColors.seaMoss, AppColors.teal],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .cornerRadius(20)
            .shadow(color: AppColors.seaMoss.opacity(0.4), radius: 16, x: 0, y: 8)
        }
    }
    
    private var dailyTakeawayView: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 24))
                    .foregroundColor(.green)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Today's Reflection Complete")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(AppColors.ink)
                    Text("Great job taking time to reflect")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            
            // Show key takeaway
            if let reflection = reflectionVM.currentReflection {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Key Takeaway")
                        .font(.headline)
                        .foregroundColor(AppColors.ink)
                    
                    Text(generateTakeaway(from: reflection))
                        .font(.body)
                        .foregroundColor(AppColors.ink)
                        .padding(12)
                        .background(AppColors.beige)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
                .padding(.horizontal, 20)
            }
            
            Spacer()
        }
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: AppColors.seaMoss.opacity(0.2), radius: 8, x: 0, y: 4)
    }
    
    private func generateTakeaway(from reflection: DailyReflection) -> String {
        // Generate a simple takeaway based on the conversation
        let messages = reflection.conversation
        if messages.count >= 3 {
            return "You've taken time to reflect on your day and set intentions for growth. Keep building on these insights!"
        } else {
            return "You've started your daily reflection journey. Every moment of self-awareness is a step forward."
        }
    }
    
    private func checkDailyReflectionStatus() {
        Task {
            do {
                // Check if there's a completed reflection for today
                let today = Calendar.current.startOfDay(for: Date())
                let allEntries = try DatabaseManager.shared.fetchAllActive()
                let todayReflections = allEntries.filter { entry in
                    entry.type == .reflection && 
                    Calendar.current.isDate(entry.createdAt, inSameDayAs: today)
                }
                
                await MainActor.run {
                    isReflectionCompleted = !todayReflections.isEmpty
                    if isReflectionCompleted {
                        // Load the completed reflection
                        reflectionVM.loadTodayReflection()
                    }
                }
            } catch {
                print("Failed to check daily reflection status: \(error)")
            }
        }
    }
    
    @State private var isGeneratingMockData = false
    
    private func generateMockData() {
        // Prevent multiple simultaneous generations
        guard !isGeneratingMockData else {
            print("Mock data generation already in progress")
            return
        }
        
        isGeneratingMockData = true
        
        Task {
            do {
                let (entries, todoItems, goalItems) = InkyAIService.shared.generateRealisticMockData()
                
                // Save entries to database with correct dates
                for entry in entries {
                    var savedEntry: Entry
                    
                    switch entry.type {
                    case .raw:
                        savedEntry = try DatabaseManager.shared.saveNewRaw(
                            title: entry.title,
                            body: entry.text ?? ""
                        )
                    case .todos:
                        let todos = todoItems.filter { $0.entryId == entry.id }
                        let todoData = todos.map { (text: $0.text, isDone: $0.isDone) }
                        savedEntry = try DatabaseManager.shared.saveNewTodos(
                            title: entry.title ?? "",
                            items: todoData
                        )
                    case .goals:
                        let goals = goalItems.filter { $0.entryId == entry.id }
                        let goalData = goals.map { $0.bullet }
                        savedEntry = try DatabaseManager.shared.saveNewGoals(
                            title: entry.title ?? "",
                            bullets: goalData
                        )
                    case .reflection:
                        // Skip reflection entries for now as they need Q&A pairs
                        continue
                    }
                    
                    // Update the saved entry's date to match the mock data date
                    try DatabaseManager.shared.updateEntryDate(id: savedEntry.id, createdAt: entry.createdAt)
                }
                
                print("Mock data generated with correct dates!")
            } catch {
                print("Failed to generate mock data: \(error)")
            }
            
            // Reset the flag
            await MainActor.run {
                isGeneratingMockData = false
            }
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack { MainView().environmentObject(UserProfileViewModel()) }
    }
}


