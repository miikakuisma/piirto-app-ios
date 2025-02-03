import SwiftUI

struct PrivacyPolicyView: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Group {
                        Text("Privacy Policy")
                            .font(.title.bold())
                        
                        Text("Last updated: \(Date.now.formatted(date: .long, time: .omitted))")
                            .foregroundStyle(.secondary)
                        
                        Text("Your privacy is important to us. This Privacy Policy explains how we collect, use, and protect your personal information.")
                        
                        Text("Data Collection")
                            .font(.headline)
                        Text("We collect minimal data necessary for the app's functionality. Your drawings and generated images are stored locally on your device.")
                        
                        Text("OpenAI Integration")
                            .font(.headline)
                        Text("When you use the AI features, your drawings are sent to OpenAI's servers for processing. This data is handled according to OpenAI's privacy policy.")
                        
                        Text("Data Storage")
                            .font(.headline)
                        Text("All generated images are stored locally on your device. You can delete them at any time through the gallery.")
                    }
                    
                    Group {
                        Text("Contact")
                            .font(.headline)
                        Text("If you have any questions about this Privacy Policy, please contact us at: [Your Contact Email]")
                    }
                }
                .padding()
            }
            .navigationBarTitleDisplayMode(.inline)
        }
    }
} 