import Foundation

final class UserProfileViewModel: ObservableObject {
    @Published var profile: UserProfile {
        didSet { saveProfile() }
    }

    init() {
        if let name = AppPrefs.string(for: .firstName) {
            profile = UserProfile(firstName: name, streakCount: 5)
        } else {
            profile = .default
        }
    }

    var firstName: String {
        get { profile.firstName }
        set { profile.firstName = newValue }
    }

    var streakCount: Int { profile.streakCount }

    private func saveProfile() {
        AppPrefs.set(profile.firstName, for: .firstName)
    }
}


