import SwiftUI

struct InsightsView: View {
    @StateObject private var vm = InsightsViewModel()

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                SoftCard {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("High moments of the year")
                            .font(AppFonts.headline)
                            .foregroundColor(AppColors.ink)
                        HStack {
                            ForEach(vm.monthlyHighMoments) { item in
                                VStack {
                                    RoundedRectangle(cornerRadius: 6)
                                        .fill(AppColors.seaMoss)
                                        .frame(width: 18, height: CGFloat(item.score))
                                    Text(item.month)
                                        .font(.caption)
                                        .foregroundColor(AppColors.ink)
                                }
                            }
                        }
                    }
                }

                SoftCard {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Top themes")
                            .font(AppFonts.headline)
                            .foregroundColor(AppColors.ink)
                        ForEach(vm.topThemes, id: \.self) { theme in
                            HStack {
                                Image(systemName: "tag")
                                    .foregroundColor(AppColors.seaMoss)
                                Text(theme)
                                    .foregroundColor(AppColors.ink)
                            }
                        }
                    }
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
    }
}

struct InsightsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack { InsightsView() }
    }
}


