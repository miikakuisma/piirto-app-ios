import SwiftUI

struct LaunchScreen: View {
    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                Image("robot-head")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 100, height: 100)
                
                Text("Piirto")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
            }
        }
    }
}

#Preview {
    LaunchScreen()
} 