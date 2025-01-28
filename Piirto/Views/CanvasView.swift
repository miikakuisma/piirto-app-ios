import SwiftUI
import PencilKit

struct CanvasView: UIViewRepresentable {
    @Binding var drawing: PKDrawing
    @Binding var toolPickerShows: Bool
    @Binding var currentDrawingPoint: CGPoint?
    
    private let canvasView = PKCanvasView()
    private let toolPicker = PKToolPicker()
    
    func makeUIView(context: Context) -> PKCanvasView {
        canvasView.drawingPolicy = .anyInput
        canvasView.drawing = drawing
        
        toolPicker.setVisible(toolPickerShows, forFirstResponder: canvasView)
        toolPicker.addObserver(canvasView)
        
        if toolPickerShows {
            canvasView.becomeFirstResponder()
        }
        
        canvasView.delegate = context.coordinator
        
        // Add touch handling
        canvasView.isMultipleTouchEnabled = false
        canvasView.addGestureRecognizer(context.coordinator.touchesGesture)
        
        return canvasView
    }
    
    func updateUIView(_ canvasView: PKCanvasView, context: Context) {
        // Called when SwiftUI updates the view
        // For example, called when toolPickerShows is toggled
        
        toolPicker.setVisible(toolPickerShows, forFirstResponder: canvasView)
        toolPicker.addObserver(canvasView)
        
        if toolPickerShows {
            canvasView.becomeFirstResponder()
        } else {
            canvasView.resignFirstResponder()
        }
        
        // Update drawing if it changed externally
        if drawing != canvasView.drawing {
            canvasView.drawing = drawing
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(drawing: $drawing, currentDrawingPoint: $currentDrawingPoint)
    }
    
    class Coordinator: NSObject, PKCanvasViewDelegate {
        var drawing: Binding<PKDrawing>
        var currentDrawingPoint: Binding<CGPoint?>
        
        lazy var touchesGesture: TouchesGestureRecognizer = {
            let gesture = TouchesGestureRecognizer(
                target: self,
                action: #selector(handleTouches(_:))
            )
            gesture.delegate = self
            return gesture
        }()
        
        init(drawing: Binding<PKDrawing>, currentDrawingPoint: Binding<CGPoint?>) {
            self.drawing = drawing
            self.currentDrawingPoint = currentDrawingPoint
        }
        
        func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
            drawing.wrappedValue = canvasView.drawing
        }
        
        @objc func handleTouches(_ gesture: TouchesGestureRecognizer) {
            switch gesture.state {
            case .began, .changed:
                if let touch = gesture.touches?.first {
                    let location = touch.location(in: gesture.view)
                    currentDrawingPoint.wrappedValue = location
                }
            case .ended, .cancelled:
                currentDrawingPoint.wrappedValue = nil
            default:
                break
            }
        }
    }
}

// Custom gesture recognizer to track touches
class TouchesGestureRecognizer: UIGestureRecognizer {
    var touches: Set<UITouch>?
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        self.touches = touches
        state = .began
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent) {
        self.touches = touches
        state = .changed
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent) {
        self.touches = nil
        state = .ended
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent) {
        self.touches = nil
        state = .cancelled
    }
}

extension CanvasView.Coordinator: UIGestureRecognizerDelegate {
    func gestureRecognizer(
        _ gestureRecognizer: UIGestureRecognizer,
        shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer
    ) -> Bool {
        return true
    }
} 