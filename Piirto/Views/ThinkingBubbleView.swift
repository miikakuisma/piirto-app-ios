import SwiftUI

struct ThinkingBubbleView: View {
    let message: String
    
    var body: some View {
        HStack {
            ProgressView()
                .tint(.black)
            Text(message)
                .font(.caption)
                .foregroundStyle(.black)
        }
        .padding(10)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(radius: 3)
    }
} 