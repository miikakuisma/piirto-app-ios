import SwiftUI

struct OrientationChangeModifier: ViewModifier {
    let action: () -> Void
    
    func body(content: Content) -> some View {
        content
            .onReceive(NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)) { _ in
                // Wait for screen bounds to update
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    action()
                }
            }
    }
}

extension View {
    func onOrientationChange(perform action: @escaping () -> Void) -> some View {
        modifier(OrientationChangeModifier(action: action))
    }
} 