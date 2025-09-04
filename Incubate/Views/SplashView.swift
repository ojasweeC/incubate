import SwiftUI

struct SplashView: View {
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [AppColors.seaMoss, AppColors.teal],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            Text("Preparing incubation chamber…")
                .font(.system(size: 24, weight: .light, design: .default))
                .foregroundColor(.white)
                .shadow(color: .black.opacity(0.2), radius: 6, x: 0, y: 2)
        }
    }
}

struct SplashView_Previews: PreviewProvider {
    static var previews: some View {
        SplashView()
    }
}


