#if DEBUG
import Foundation

enum DBSmokeTest {
    static func runOnce() {
        let flagKey = "didRunDBSmokeTestOnce"
        if UserDefaults.standard.bool(forKey: flagKey) { return }
        UserDefaults.standard.set(true, forKey: flagKey)

        do {
            let inserted = try DatabaseManager.shared.insertDummyEntry()
            print("DBSmokeTest inserted:", inserted.id, inserted.type.rawValue)

            let list = try DatabaseManager.shared.fetchAllActive(limit: 10)
            print("DBSmokeTest fetched count:", list.count)
        } catch {
            print("DBSmokeTest error:", error)
        }
    }
}
#endif


