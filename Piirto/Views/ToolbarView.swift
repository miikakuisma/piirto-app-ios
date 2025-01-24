import SwiftUI
import PencilKit

struct ToolbarView: View {
    @Bindable var drawingState: DrawingState
    
    var body: some View {
        HStack {
            // Undo/Redo buttons
            HStack(spacing: 20) {
                Button(action: drawingState.undo) {
                    Image(systemName: "arrow.uturn.backward")
                        .foregroundColor(drawingState.undoManager.canUndo ? .primary : .secondary)
                }
                .disabled(!drawingState.undoManager.canUndo)
                
                Button(action: drawingState.redo) {
                    Image(systemName: "arrow.uturn.forward")
                        .foregroundColor(drawingState.undoManager.canRedo ? .primary : .secondary)
                }
                .disabled(!drawingState.undoManager.canRedo)
            }
            .padding(.horizontal)
            
            Spacer()
            
            // Clear canvas button
            Button(action: drawingState.clearCanvas) {
                Image(systemName: "trash")
                    .foregroundColor(.red)
            }
            .padding(.horizontal)
        }
        .frame(height: 60)
        .background(.bar)
    }
} 