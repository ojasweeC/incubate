import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var appLockViewModel: AppLockViewModel
    @State private var showSplash = true
    @State private var fadeOut = false

    var body: some View {
        ZStack {
            Group {
                if appLockViewModel.isUnlocked {
                    NavigationStack { MainView() }
                } else {
                    LockView()
                }
            }
            .opacity(showSplash ? 0 : 1)

            if showSplash {
                SplashView()
                    .opacity(fadeOut ? 0 : 1)
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                            withAnimation(.easeInOut(duration: 0.6)) {
                                fadeOut = true
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                                showSplash = false
                            }
                        }
                    }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(AppLockViewModel())
            .environmentObject(UserProfileViewModel())
    }
}


