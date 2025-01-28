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
        .overlay(
            Path { path in
                path.move(to: CGPoint(x: 20, y: 35))
                path.addQuadCurve(
                    to: CGPoint(x: 5, y: 45),
                    control: CGPoint(x: 15, y: 40)
                )
                path.addQuadCurve(
                    to: CGPoint(x: 15, y: 35),
                    control: CGPoint(x: 10, y: 35)
                )
            }
            .fill(.white)
            .offset(y: 15)
        )
        .shadow(radius: 3)
    }
} 