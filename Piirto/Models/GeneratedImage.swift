import SwiftUI
import SwiftData

@Model
class GeneratedImage {
    let id: UUID
    let imageData: Data  // Store image as Data
    let imageDescription: String  // Renamed from description
    let date: Date
    
    var image: Image {  // Computed property to convert Data back to Image
        if let uiImage = UIImage(data: imageData) {
            return Image(uiImage: uiImage)
        }
        return Image(systemName: "photo.fill")  // Fallback image
    }
    
    init(imageData: Data, description: String, date: Date = Date()) {
        self.id = UUID()
        self.imageData = imageData
        self.imageDescription = description
        self.date = date
    }
} 