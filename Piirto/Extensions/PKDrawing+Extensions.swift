import PencilKit
import SwiftUI

extension PKDrawing {
    func saveToPhotoLibrary() {
        // Generate a UIImage from the drawing
        let uiImage = self.image(from: self.bounds, scale: 1)
        
        // Save to photo library
        UIImageWriteToSavedPhotosAlbum(uiImage, nil, nil, nil)
    }
    
    func image() -> Image {
        let uiImage = self.image(from: self.bounds, scale: 1)
        return Image(uiImage: uiImage)
    }
} 