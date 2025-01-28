import SwiftUI
import SwiftData

struct GalleryView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedImage: GeneratedImage?
    @Query private var images: [GeneratedImage]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                if images.isEmpty {
                    ContentUnavailableView(
                        "No Generated Images",
                        systemImage: "photo.stack",
                        description: Text("Use the magic wand to generate AI images from your drawings")
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
            .fullScreenCover(item: $selectedImage) { item in
                ImageDetailView(image: item)
            }
        }
    }
} 