import SwiftUI

struct CharacterView: View {
    @Binding var currentDrawingPoint: CGPoint?
    @State private var position: CGPoint = CGPoint(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height - 260)
    @State private var isDragging = false
    @State private var eyePosition: CGPoint = .zero
    let characterSize: CGFloat = 150
    
    var body: some View {
        ZStack {
            // Robot face background
            Image("robot-head")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: characterSize, height: characterSize)
            
            // Left eye
            Circle()
                .fill(.black)
                .frame(width: 12, height: 12)
                .offset(x: -27 + eyePosition.x * 8, y: -6 + eyePosition.y * 8)
                .animation(.spring(response: 0.2), value: eyePosition)
            
            // Right eye
            Circle()
                .fill(.black)
                .frame(width: 12, height: 12)
                .offset(x: 27 + eyePosition.x * 8, y: -6 + eyePosition.y * 8)
                .animation(.spring(response: 0.2), value: eyePosition)
        }
        .position(x: position.x, y: position.y)
        .gesture(
            DragGesture()
                .onChanged { value in
                    isDragging = true
                    position = value.location
                }
                .onEnded { _ in
                    isDragging = false
                }
        )
        .onChange(of: currentDrawingPoint) { _, point in
            if let point = point, !isDragging {
                updateEyePosition(to: point)
            } else if point == nil {
                resetEyes()
            }
        }
    }
    
    private func updateEyePosition(to point: CGPoint) {
        let dx = point.x - position.x
        let dy = point.y - position.y
        let distance = sqrt(dx * dx + dy * dy)
        
        let scale = min(distance / 200, 1.0)
        let normalizedX = (dx / max(distance, 1)) * scale
        let normalizedY = (dy / max(distance, 1)) * scale
        
        eyePosition = CGPoint(x: normalizedX, y: normalizedY)
    }
    
    private func resetEyes() {
        eyePosition = .zero
    }
} 