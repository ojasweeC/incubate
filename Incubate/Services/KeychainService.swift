import Foundation

final class KeychainService {
    static let shared = KeychainService()

    private let storageKeyPrefix = "com.incubate.keychain.mock."

    private init() {}

    func set(_ value: Data, for key: String) {
        let storageKey = storageKeyPrefix + key
        UserDefaults.standard.set(value, forKey: storageKey)
    }

    func data(for key: String) -> Data? {
        let storageKey = storageKeyPrefix + key
        return UserDefaults.standard.data(forKey: storageKey)
    }

    func remove(_ key: String) {
        let storageKey = storageKeyPrefix + key
        UserDefaults.standard.removeObject(forKey: storageKey)
    }
}


