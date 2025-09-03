import SwiftUI

@main
struct IncubateApp: App {
    @StateObject private var appLockViewModel = AppLockViewModel()
    @StateObject private var userProfileViewModel = UserProfileViewModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appLockViewModel)
                .environmentObject(userProfileViewModel)
                .onAppear {
#if DEBUG
                    DBSmokeTest.runOnce()
#endif
                }
        }
    }
}
