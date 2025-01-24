import SwiftUI
import PencilKit

@Observable
class DrawingState {
    var drawing: PKDrawing = PKDrawing()
    var undoManager = UndoManager()
    
    func undo() {
        undoManager.undo()
    }
    
    func redo() {
        undoManager.redo()
    }
    
    func clearCanvas() {
        let oldDrawing = drawing
        undoManager.registerUndo(withTarget: self) { state in
            state.drawing = oldDrawing
        }
        drawing = PKDrawing()
    }
} 