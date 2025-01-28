import SwiftUI
import SwiftData

struct GalleryView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Binding var selectedImage: GeneratedImage?
    @Query private var images: [GeneratedImage]
    @State private var imageToDelete: GeneratedImage?
    
    var body: some View {
        NavigationStack {
            ScrollView {
                if images.isEmpty {
                    ContentUnavailableView(
                        "No Generated Images",
                        systemImage: "photo.stack",
                        description: Text("Use the AI magic to generate AI images from your drawings")
                    )
                } else {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 150))], spacing: 20) {
                        ForEach(images.sorted { $0.date > $1.date }) { item in
                            VStack {
                                item.image
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 150)
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                                
                                // Text(item.imageDescription)
                                //     .font(.caption)
                                //     .lineLimit(2)
                                //     .multilineTextAlignment(.center)
                            }
                            .onTapGesture {
                                selectedImage = item
                            }
                            .onLongPressGesture {
                                imageToDelete = item
                            }
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("AI Gallery")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .alert("Delete Image", isPresented: .init(
                get: { imageToDelete != nil },
                set: { if !$0 { imageToDelete = nil } }
            )) {
                Button("Delete", role: .destructive) {
                    if let image = imageToDelete {
                        modelContext.delete(image)
                        try? modelContext.save()
                    }
                    imageToDelete = nil
                }
                Button("Cancel", role: .cancel) {
                    imageToDelete = nil
                }
            } message: {
                Text("Are you sure you want to delete this image? This action cannot be undone.")
            }
            .fullScreenCover(item: $selectedImage) { item in
                ImageDetailView(image: item)
            }
        }
    }
} 