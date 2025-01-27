import SwiftUI

struct ImageDetailView: View {
    let image: GeneratedImage
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                ScrollView {
                    VStack(spacing: 20) {
                        image.image
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: geometry.size.width)
                        
                        // Text(image.imageDescription)
                        //     .font(.body)
                        //     .padding(.horizontal)
                        
                        Text(image.date.formatted())
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .frame(minHeight: geometry.size.height)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    ShareLink(
                        item: image.image,
                        preview: SharePreview("AI Generated Image", image: image.image)
                    )
                }
            }
            .ignoresSafeArea(.container, edges: .bottom)
        }
    }
} 