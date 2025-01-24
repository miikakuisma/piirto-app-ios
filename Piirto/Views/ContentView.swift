import SwiftUI
import PencilKit
import SwiftData

struct ContentView: View {
    @State private var drawing = PKDrawing()
    @State private var toolPickerShows = true
    @State private var processingState: ProcessingState = .idle
    @State private var showGallery = false
    @Query private var generatedImages: [GeneratedImage]
    @Environment(\.modelContext) private var modelContext
    private let openAIService = OpenAIService()
    
    enum ProcessingState {
        case idle
        case analyzing
        case generating
        
        var message: String {
            switch self {
            case .idle: return ""
            case .analyzing: return "Processing..."
            case .generating: return "Almost done..."
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            CanvasView(drawing: $drawing, toolPickerShows: $toolPickerShows)
                .overlay(
                    processingState != .idle ? 
                        ProgressView(processingState.message)
                            .padding()
                            .background(.bar)
                            .cornerRadius(8)
                        : nil
                )
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("\(toolPickerShows ? "Hide" : "Show") tool picker", systemImage: "wrench.adjustable") {
                            toolPickerShows.toggle()
                        }
                    }
                    
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Erase all", systemImage: "trash") {
                            drawing = PKDrawing()
                        }
                    }
                    
                    ToolbarItem(placement: .topBarLeading) {
                        HStack {
                            ShareLink(
                                item: drawing.image(),
                                preview: SharePreview("Drawing", image: drawing.image())
                            ) {
                                Label("Share", systemImage: "square.and.arrow.up")
                            }
                            
                            Button {
                                Task {
                                    processingState = .analyzing
                                    do {
                                        let (image, description) = try await openAIService.generateImageFromDrawing(drawing) {
                                            processingState = .generating
                                        }
                                        await MainActor.run {
                                            saveGeneratedImage(image, description: description)
                                            showGallery = true
                                        }
                                    } catch {
                                        print("Error details: \(error)")
                                    }
                                    processingState = .idle
                                }
                            } label: {
                                Label("Magic", systemImage: "wand.and.stars")
                            }
                            
                            Button {
                                showGallery.toggle()
                            } label: {
                                Label("Gallery", systemImage: "photo.stack")
                            }
                        }
                    }
                }
                .sheet(isPresented: $showGallery) {
                    GalleryView()
                }
        }
    }
    
    func saveGeneratedImage(_ uiImage: UIImage, description: String) {
        guard let imageData = uiImage.jpegData(compressionQuality: 0.8) else { return }
        let newImage = GeneratedImage(imageData: imageData, description: description)
        
        modelContext.insert(newImage)
        try? modelContext.save()
    }
} 