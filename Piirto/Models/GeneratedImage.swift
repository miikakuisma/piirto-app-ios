import SwiftUI
import SwiftData

@Model
class GeneratedImage {
    let id: UUID
    let imageData: Data  // AI generated image
    let originalDrawingData: Data  // Original drawing
    let imageDescription: String
    let date: Date
    
    var image: Image {
        if let uiImage = UIImage(data: imageData) {
            return Image(uiImage: uiImage)
        }
        return Image(systemName: "photo.fill")
    }
    
    var originalDrawing: Image {
        if let uiImage = UIImage(data: originalDrawingData) {
            return Image(uiImage: uiImage)
        }
        return Image(systemName: "scribble")
    }
    
    init(imageData: Data, originalDrawingData: Data, description: String, date: Date = Date()) {
        self.id = UUID()
        self.imageData = imageData
        self.originalDrawingData = originalDrawingData
        self.imageDescription = description
        self.date = date
    }
} 