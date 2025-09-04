import SwiftUI

struct MainView: View {
    @EnvironmentObject private var userVM: UserProfileViewModel
    @State private var showingEntryTypeSelector = false

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
            // Prominent Inky button
            NavigationLink { DailyReflectionView() } label: {
                HStack(spacing: 12) {
                    Image(systemName: "octopus.fill")
                        .font(.system(size: 28))
                        .foregroundColor(.white)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Chat with Inky")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                        Text("Daily reflection & insights")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.9))
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.system(size: 16))
                        .foregroundColor(.white.opacity(0.8))
                }
                .padding(20)
                .background(
                    LinearGradient(
                        colors: [AppColors.seaMoss, AppColors.teal],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .cornerRadius(20)
                .shadow(color: AppColors.seaMoss.opacity(0.4), radius: 16, x: 0, y: 8)
            }
            .accessibilityLabel("Start daily reflection with Inky AI")
            
            // Daily completion status
            HStack {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
                Text("Daily reflection ready")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
            }
            .padding(.horizontal, 4)
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack { MainView().environmentObject(UserProfileViewModel()) }
    }
}


