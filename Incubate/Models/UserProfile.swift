import Foundation

struct UserProfile: Codable, Equatable {
    var firstName: String
    var streakCount: Int

    static let `default` = UserProfile(firstName: "friend", streakCount: 5)
}


