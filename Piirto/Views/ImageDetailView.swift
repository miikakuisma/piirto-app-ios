import SwiftUI

struct ImageDetailView: View {
    let image: GeneratedImage
    @Environment(\.dismiss) private var dismiss
    @State private var scale: CGFloat = 1.0
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Blurred background
                Rectangle()
                    .fill(.ultraThinMaterial)  // System material with blur
                    .ignoresSafeArea()
                
                image.image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: geometry.size.width * 0.9)  // 90% of screen width
                    .scaleEffect(scale)
                    .gesture(
                        MagnificationGesture()
                            .onChanged { value in
                                scale = value
                            }
                            .onEnded { _ in
                                withAnimation {
                                    scale = 1.0
                                }
                            }
                    )
            }
            .overlay(alignment: .topTrailing) {
                HStack(spacing: 20) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title)
                            .foregroundStyle(.white)
                            .shadow(radius: 2)
                    }
                    
                    ShareLink(
                        item: image.image,
                        preview: SharePreview("AI Generated Image", image: image.image)
                    ) {
                        Image(systemName: "square.and.arrow.up.circle.fill")
                            .font(.title)
                            .foregroundStyle(.white)
                            .shadow(radius: 2)
                    }
                }
                .padding()
            }
            .onTapGesture {
                dismiss()
            }
        }
        .presentationBackground(.clear)
        .presentationCornerRadius(16)  // Add rounded corners
    }
} 