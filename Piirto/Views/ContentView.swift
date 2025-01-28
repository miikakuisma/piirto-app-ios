import SwiftUI
import PencilKit
import SwiftData

struct ContentView: View {
    @State private var drawing = PKDrawing()
    @State private var toolPickerShows = true
    @State private var processingState: ProcessingState = .idle
    @State private var showGallery = false
    @State private var selectedImage: GeneratedImage?
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
            case .analyzing: return "Analyzing..."
            case .generating: return "Generating..."
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
                        Button {
                            Task {
                                processingState = .analyzing
                                do {
                                    let (image, description) = try await openAIService.generateImageFromDrawing(drawing) {
                                        processingState = .generating
                                    }
                                    await MainActor.run {
                                        saveGeneratedImage(image, description: description)
                                    }
                                } catch {
                                    print("Error details: \(error)")
                                }
                                processingState = .idle
                            }
                        } label: {
                            Text("AI Magic")
                                .fontWeight(.medium)
                                .foregroundColor(.white)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(drawing.bounds.isEmpty ? Color.gray : Color.blue)
                                .clipShape(RoundedRectangle(cornerRadius: 20))
                        }
                        .disabled(drawing.bounds.isEmpty)
                    }
                    
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            drawing = PKDrawing()
                        } label: {
                            Label("Erase all", systemImage: "trash")
                        }
                        .tint(.red) // Add button tint
                    }
                    
                    ToolbarItem(placement: .topBarLeading) {
                        HStack {
                            ShareLink(
                                item: drawing.image(),
                                preview: SharePreview("Drawing", image: drawing.image())
                            ) {
                                Label("Share", systemImage: "square.and.arrow.up")
                                    .foregroundColor(.white)
                            }
                            Button {
                                showGallery.toggle()
                            } label: {
                                Label("Gallery", systemImage: "photo.stack")
                                    .foregroundColor(.white)
                            }
                        }
                    }
                }
                .toolbarBackground(.black.opacity(0.8), for: .navigationBar)
                .toolbarBackground(.visible, for: .navigationBar)
                .sheet(isPresented: $showGallery, onDismiss: {
                    toolPickerShows = true  // Show tools again when gallery closes
                }) {
                    GalleryView(selectedImage: $selectedImage)
                }
                .fullScreenCover(item: $selectedImage, onDismiss: {
                    toolPickerShows = true  // Show tools again when detail view closes
                }) {
                    ImageDetailView(image: $0)
                }
                .onChange(of: showGallery) { _, isShowing in
                    if isShowing {
                        toolPickerShows = false  // Hide tools when gallery opens
                    }
                }
        }
    }
    
    func saveGeneratedImage(_ uiImage: UIImage, description: String) {
        guard let imageData = uiImage.jpegData(compressionQuality: 0.8),
              let originalDrawingData = drawing.image(from: drawing.bounds, scale: 1).jpegData(compressionQuality: 0.8) else { return }
        
        let newImage = GeneratedImage(
            imageData: imageData,
            originalDrawingData: originalDrawingData,
            description: description
        )
        
        modelContext.insert(newImage)
        try? modelContext.save()
        
        selectedImage = newImage
        showGallery = true
    }
} 