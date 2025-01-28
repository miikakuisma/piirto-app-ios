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
    @State private var currentDrawingPoint: CGPoint?
    @State private var characterInitialPosition: CGPoint?
    
    var body: some View {
        NavigationStack {
            ZStack {
                CanvasView(
                    drawing: $drawing,
                    toolPickerShows: $toolPickerShows,
                    currentDrawingPoint: $currentDrawingPoint
                )
                
                if !drawing.bounds.isEmpty {
                    CharacterView(
                        currentDrawingPoint: $currentDrawingPoint,
                        drawing: $drawing,
                        processingState: $processingState
                    ) {
                        // Only allow AI request when not processing
                        if processingState == .idle {
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
                        }
                    }
                    .transition(
                        .asymmetric(
                            insertion: .opacity
                                .combined(with: .move(edge: .bottom))
                                .animation(.spring(response: 0.6, dampingFraction: 0.7)),
                            removal: .opacity
                                .combined(with: .move(edge: .bottom))
                                .animation(.easeOut(duration: 0.3))
                        )
                    )
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        drawing = PKDrawing()
                    } label: {
                        Label("Erase all", systemImage: "trash")
                    }
                    .tint(.red)
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