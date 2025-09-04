import UIKit

enum HapticsService {
    static func success() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }

    static func error() {
        UINotificationFeedbackGenerator().notificationOccurred(.error)
    }

    static func soft() {
        UIImpactFeedbackGenerator(style: .soft).impactOccurred()
    }
    
    static func playCompletionHaptic() {
        // Play a sequence of haptics for completion celebration
        UINotificationFeedbackGenerator().notificationOccurred(.success)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
        }
    }
}


