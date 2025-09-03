import SwiftUI

struct MainView: View {
    @EnvironmentObject private var userVM: UserProfileViewModel
    @State private var showingEntryTypeSelector = false

    var body: some View {
        VStack(spacing: 24) {
            header
            streakChip
            entryBuckets
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
                bucketCard(type: .voice, icon: "waveform")
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
                Image(systemName: "thought.bubble")
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
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack { MainView().environmentObject(UserProfileViewModel()) }
    }
}


