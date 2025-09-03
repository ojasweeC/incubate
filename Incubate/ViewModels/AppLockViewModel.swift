import Foundation
import LocalAuthentication

final class AppLockViewModel: ObservableObject {
    @Published var isUnlocked: Bool = false
    @Published var pinSet: Bool = false
    @Published var biometricsEnabled: Bool = false
    @Published var failedAttempts: Int = 0
    @Published var isLockedOut: Bool = false
    @Published var lockoutRemainingSeconds: Int = 0

    private var lockoutTimer: Timer?
    private let keychain = KeychainService.shared

    init() {
        biometricsEnabled = AppPrefs.bool(for: .biometricsEnabled)
        pinSet = (keychain.data(for: AppPrefsKeys.pinHash.rawValue) != nil)
    }

    func attemptBiometricUnlock() {
        guard biometricsEnabled else { return }
        let context = LAContext()
        var error: NSError?
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: "Unlock Incubate") { [weak self] success, _ in
                DispatchQueue.main.async {
                    if success {
                        HapticsService.success()
                        self?.unlock()
                    }
                }
            }
        }
    }

    func verifyPIN(_ pin: String) -> Bool {
        guard !isLockedOut else { return false }
        guard let salt = keychain.data(for: AppPrefsKeys.pinSalt.rawValue),
              let storedHash = keychain.data(for: AppPrefsKeys.pinHash.rawValue) else {
            // No pin set; accept any pin for scaffold
            unlock()
            return true
        }
        let candidateHash = Self.hash(pin: pin, salt: salt)
        if candidateHash == storedHash {
            failedAttempts = 0
            HapticsService.success()
            unlock()
            return true
        } else {
            failedAttempts += 1
            HapticsService.error()
            if failedAttempts >= 5 {
                beginLockout(seconds: 60)
            }
            return false
        }
    }

    func setPIN(_ pin: String) {
        let salt = Self.generateSalt()
        let hash = Self.hash(pin: pin, salt: salt)
        keychain.set(salt, for: AppPrefsKeys.pinSalt.rawValue)
        keychain.set(hash, for: AppPrefsKeys.pinHash.rawValue)
        pinSet = true
    }

    func lock() {
        isUnlocked = false
    }

    func unlock() {
        isUnlocked = true
    }

    func setBiometricsEnabled(_ enabled: Bool) {
        biometricsEnabled = enabled
        AppPrefs.set(enabled, for: .biometricsEnabled)
    }

    private func beginLockout(seconds: Int) {
        isLockedOut = true
        lockoutRemainingSeconds = seconds
        lockoutTimer?.invalidate()
        lockoutTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] timer in
            guard let self = self else { return }
            self.lockoutRemainingSeconds -= 1
            if self.lockoutRemainingSeconds <= 0 {
                timer.invalidate()
                self.isLockedOut = false
                self.failedAttempts = 0
            }
        }
    }

    private static func generateSalt() -> Data {
        UUID().uuidString.data(using: .utf8) ?? Data()
    }

    private static func hash(pin: String, salt: Data) -> Data {
        let combined = (pin.data(using: .utf8) ?? Data()) + salt
        // Simple non-cryptographic hash for scaffold purposes only
        var hash = UInt64(5381)
        for byte in combined {
            hash = ((hash << 5) &+ hash) &+ UInt64(byte)
        }
        var bigEndian = hash.bigEndian
        return Data(bytes: &bigEndian, count: MemoryLayout<UInt64>.size)
    }
}


