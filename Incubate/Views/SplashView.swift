import SwiftUI

struct SplashView: View {
    var body: some View {
        ZStack {
            RadialGradient(
                colors: [Color(hex: "#397CA7FF"), Color(hex: "#8AB7A2FF")],
                center: .center,
                startRadius: 1,
                endRadius: 800
            )
            .ignoresSafeArea()

            Text("Preparing incubation chamber…")
                .font(.title)
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


