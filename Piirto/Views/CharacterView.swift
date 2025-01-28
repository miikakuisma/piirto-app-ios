import SwiftUI
import PencilKit

struct CharacterView: View {
    @Binding var currentDrawingPoint: CGPoint?
    @Binding var drawing: PKDrawing
    @Binding var processingState: ProcessingState
    var onAIRequest: () -> Void
    
    @State private var position: CGPoint = {
        let screen = UIScreen.main
        let isPortrait = screen.bounds.height > screen.bounds.width
        
        if isPortrait {
            return CGPoint(x: screen.bounds.width / 2, y: screen.bounds.height - 260)
        } else {
            return CGPoint(x: screen.bounds.width - 100, y: screen.bounds.height - 150) 
        }
    }()
    @State private var isDragging = false
    @State private var eyePosition: CGPoint = .zero
    @State private var eyeScale: CGFloat = 1.0
    let characterSize: CGFloat = 150
    
    // Timer for random eye movements during analysis
    let timer = Timer.publish(every: 0.5, on: .main, in: .common).autoconnect()
    
    // Add new timer for pulsing
    let pulseTimer = Timer.publish(every: 0.7, on: .main, in: .common).autoconnect()
    @State private var isPulsing = false
    
    @State private var isVisible = false
    private let hiddenYOffset: CGFloat = 200
    
    private func updatePositionForCurrentOrientation() {
        let screen = UIScreen.main
        let isPortrait = screen.bounds.height > screen.bounds.width
        
        withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
            if isPortrait {
                position = CGPoint(x: screen.bounds.width / 2, y: screen.bounds.height - 260)
            } else {
                position = CGPoint(x: screen.bounds.width - 100, y: screen.bounds.height - 150)
            }
        }
    }
    
    var body: some View {
        ZStack {
            // Robot face background
            Image("robot-head")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: characterSize, height: characterSize)
                .onTapGesture {
                    if !drawing.bounds.isEmpty && processingState == .idle {
                        onAIRequest()
                    }
                }
            
            // Left eye
            Circle()
                .fill(.black)
                .frame(width: 12, height: 12)
                .offset(x: -27 + eyePosition.x * 8, y: -6 + eyePosition.y * 8)
                .scaleEffect(eyeScale)
                .animation(.spring(response: 0.2), value: eyePosition)
                .animation(.easeInOut(duration: 0.3), value: eyeScale)
            
            // Right eye
            Circle()
                .fill(.black)
                .frame(width: 12, height: 12)
                .offset(x: 27 + eyePosition.x * 8, y: -6 + eyePosition.y * 8)
                .scaleEffect(eyeScale)
                .animation(.spring(response: 0.2), value: eyePosition)
                .animation(.easeInOut(duration: 0.3), value: eyeScale)
            
            // Thinking bubble
            if processingState != .idle {
                ThinkingBubbleView(message: processingState.message)
                    .offset(y: -characterSize)
                    .transition(.scale.combined(with: .opacity))
            }
        }
        .position(x: position.x, y: position.y)
        .offset(y: isVisible ? 0 : hiddenYOffset)
        .opacity(isVisible ? 1 : 0)
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
        .onAppear {
            // Slight delay before showing to allow view to be ready
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                    isVisible = !drawing.bounds.isEmpty
                }
            }
        }
        .onChange(of: drawing) { _, newDrawing in
            withAnimation(
                .spring(
                    response: 0.6,
                    dampingFraction: 0.7,
                    blendDuration: 0.3
                )
            ) {
                isVisible = !newDrawing.bounds.isEmpty
            }
        }
        .onChange(of: currentDrawingPoint) { _, point in
            if let point = point, !isDragging {
                updateEyePosition(to: point)
            } else if point == nil {
                resetEyes()
            }
        }
        .onChange(of: processingState) { _, state in
            switch state {
            case .analyzing, .generating:  // Handle both states the same way
                moveEyesRandomly()
            case .idle:
                withAnimation {
                    eyeScale = 1.0
                    eyePosition = .zero
                }
            }
        }
        .onReceive(timer) { _ in
            // Move eyes randomly during both analyzing and generating
            if processingState == .analyzing || processingState == .generating {
                moveEyesRandomly()
            }
        }
        .onReceive(pulseTimer) { _ in
            if processingState == .generating {
                withAnimation(.easeInOut(duration: 0.4
                                        )) {
                    eyeScale = isPulsing ? 1.0 : 0.9
                }
                isPulsing.toggle()
            }
        }
        .animation(.spring(response: 0.3), value: processingState)
        .onOrientationChange {
            updatePositionForCurrentOrientation()
        }
    }
    
    private func moveEyesRandomly() {
        withAnimation(.spring(response: 0.3)) {
            eyePosition = CGPoint(
                x: CGFloat.random(in: -1...1),
                y: CGFloat.random(in: -1...1)
            )
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
