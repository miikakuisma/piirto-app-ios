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
    @StateObject private var settings = SettingsManager()
    @State private var showSettings = false
    @State private var showPurchaseView = false
    @State private var showClearConfirmation = false
    let creditsManager = CreditsManager.shared
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @State private var orientation = UIDevice.current.orientation
    @State private var showError = false
    @State private var errorMessage = ""
    
    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                ZStack {
                    CanvasView(
                        drawing: $drawing,
                        toolPickerShows: $toolPickerShows,
                        currentDrawingPoint: $currentDrawingPoint
                    )
                    
                    if !drawing.bounds.isEmpty && settings.aiFeatureEnabled {
                        if settings.aiControlType == .robot {
                            CharacterView(
                                currentDrawingPoint: $currentDrawingPoint,
                                drawing: $drawing,
                                processingState: $processingState
                            ) {
                                startAITask()
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
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    HStack {
                        if settings.aiControlType == .button && !drawing.bounds.isEmpty {
                            Button {
                                handleAIRequest()
                            } label: {
                                Label("AI Magic", systemImage: "sparkles")
                                    .font(.headline)
                                    .foregroundStyle(.white)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 3)
                                    .background(.ultraThinMaterial)
                                    .clipShape(Capsule())
                                    .opacity(processingState != .idle ? 0.6 : 1.0)
                                    .animation(processingState != .idle ? .easeInOut(duration: 0.6).repeatForever() : .default, value: processingState)
                                    .scaleEffect(processingState != .idle ? 0.95 : 1.0)
                            }
                            .disabled(drawing.bounds.isEmpty || processingState != .idle)
                        }
                        
                        Button {
                            showPurchaseView = true
                        } label: {
                            Text("\(creditsManager.remainingCredits) credits")
                                .font(.subheadline)
                                .foregroundStyle(.white)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(.ultraThinMaterial)
                                .clipShape(Capsule())
                        }
                        
                        Button {
                            showSettings.toggle()
                        } label: {
                            Label("Settings", systemImage: "gear")
                                .foregroundColor(.white)
                        }
                        
                        Button {
                            showClearConfirmation = true  // Show confirmation instead of clearing directly
                        } label: {
                            Label("Erase all", systemImage: "trash")
                        }
                        .tint(.red)
                    }
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
            .onChange(of: showPurchaseView) { _, isShowing in
                if isShowing {
                    toolPickerShows = false  // Hide tools when purchase view opens
                } else {
                    toolPickerShows = true   // Show tools again when purchase view closes
                }
            }
            .alert("Clear Canvas", isPresented: $showClearConfirmation) {
                Button("Cancel", role: .cancel) { }
                Button("Clear", role: .destructive) {
                    drawing = PKDrawing()
                }
            } message: {
                Text("Are you sure you want to clear your drawing? This action cannot be undone.")
            }
        }
        .sheet(isPresented: $showSettings) {
            SettingsView(settings: settings)
        }
        .sheet(isPresented: $showPurchaseView, onDismiss: {
            toolPickerShows = true  // Show tools again when purchase view closes
        }) {
            PurchaseCreditsView()
        }
        .alert("Error", isPresented: $showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
        .onOrientationChange {
            orientation = UIDevice.current.orientation
        }
    }
    
    private func startAITask() {
        guard processingState == .idle else { return }
        
        // Check if user has credits
        guard creditsManager.useCredit() else {
            showPurchaseView = true
            return
        }
        
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
        
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
                await MainActor.run {
                    errorMessage = error.localizedDescription
                    showError = true
                    processingState = .idle
                }
            }
            processingState = .idle
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
    
    // Helper function to determine orientation based on size
    private func isPortrait(_ size: CGSize) -> Bool {
        size.height > size.width
    }
    
    private func handleAIRequest() {
        startAITask()
    }
}
