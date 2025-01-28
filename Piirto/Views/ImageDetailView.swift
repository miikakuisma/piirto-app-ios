import SwiftUI

struct ImageDetailView: View {
    let image: GeneratedImage
    @Environment(\.dismiss) private var dismiss
    @State private var scale: CGFloat = 1.0
    @State private var showingOriginal = false
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Rectangle()
                    .fill(.ultraThinMaterial)
                    .ignoresSafeArea()
                
                (showingOriginal ? image.originalDrawing : image.image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: geometry.size.width * 0.9)
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
                    .overlay(alignment: .topLeading) {
                        Button {
                            withAnimation {
                                showingOriginal.toggle()
                            }
                        } label: {
                            Image(systemName: showingOriginal ? "wand.and.stars.inverse" : "scribble")
                                .font(.title)
                                .foregroundStyle(.white)
                                .shadow(radius: 2)
                        }
                        .padding()
                    }
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
        .presentationCornerRadius(16)
    }
} 