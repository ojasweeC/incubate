import Foundation

enum AppPrefsKeys: String {
    case firstName
    case biometricsEnabled
    case pinSalt
    case pinHash
}

enum AppPrefs {
    static func set<T>(_ value: T, for key: AppPrefsKeys) {
        UserDefaults.standard.set(value, forKey: key.rawValue)
    }

    static func bool(for key: AppPrefsKeys) -> Bool {
        UserDefaults.standard.bool(forKey: key.rawValue)
    }

    static func string(for key: AppPrefsKeys) -> String? {
        UserDefaults.standard.string(forKey: key.rawValue)
    }

    static func int(for key: AppPrefsKeys) -> Int {
        UserDefaults.standard.integer(forKey: key.rawValue)
    }
}


