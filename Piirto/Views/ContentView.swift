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
    let creditsManager = CreditsManager.shared
    
    var body: some View {
        NavigationStack {
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
            .overlay(alignment: .bottom) {
                if settings.aiFeatureEnabled && settings.aiControlType == .button && !drawing.bounds.isEmpty {
                    Button {
                        startAITask()
                    } label: {
                        Label(processingState == .idle ? "AI Magic" : processingState.message,
                              systemImage: processingState == .idle ? "sparkles" : "clock.arrow.circlepath")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(height: 44)
                            .frame(maxWidth: 160)
                            .background(
                                processingState == .idle ? Color.blue : Color.gray
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 22))
                            .frame(maxWidth: .infinity, alignment: .trailing)
                            .padding(.trailing)
                    }
                    .disabled(processingState != .idle)
                    .padding()
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    HStack {
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
                            drawing = PKDrawing()
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
        }
        .sheet(isPresented: $showSettings) {
            SettingsView(settings: settings)
        }
        .sheet(isPresented: $showPurchaseView, onDismiss: {
            toolPickerShows = true  // Show tools again when purchase view closes
        }) {
            PurchaseCreditsView()
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
                print("Error details: \(error)")
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
} 