import SwiftUI

struct PrivacyPolicyView: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    header
                    introduction
                    informationCollection
                    informationUsage
                    dataStorage
                    dataSharing
                    childrenPrivacy
                    userRights
                    aiProcessing
                    contact
                }
                .padding()
            }
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Privacy Policy")
                .font(.largeTitle.bold())
            Text("Last Updated: February 4, 2025")
                .foregroundStyle(.secondary)
        }
    }
    
    private var introduction: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("1. Introduction")
                .font(.title2.bold())
            Text("This Privacy Policy explains how Piirto collects, uses, and protects your information when you use our iOS application.")
        }
    }
    
    private var informationCollection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("2. Information We Collect")
                .font(.title2.bold())
            
            VStack(alignment: .leading, spacing: 8) {
                Text("2.1. Information You Provide")
                    .font(.headline)
                bulletPoint("User-created drawings and artwork")
                bulletPoint("In-app purchase transactions")
                bulletPoint("App usage preferences")
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("2.2. Automatically Collected Information")
                    .font(.headline)
                bulletPoint("Device information (model, iOS version)")
                bulletPoint("App usage statistics")
                bulletPoint("Performance data")
            }
        }
    }
    
    private var informationUsage: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("3. How We Use Your Information")
                .font(.title2.bold())
            
            VStack(alignment: .leading, spacing: 8) {
                Text("3.1. Your Artwork")
                    .font(.headline)
                bulletPoint("To provide AI enhancement features")
                bulletPoint("Artwork is processed temporarily and not permanently stored on Open AI servers")
                bulletPoint("Original and enhanced images are stored locally on your device")
            }
        }
    }
    
    private var dataStorage: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("4. Data Storage and Security")
                .font(.title2.bold())
            
            VStack(alignment: .leading, spacing: 8) {
                Text("4.1. Local Storage")
                    .font(.headline)
                bulletPoint("Your artwork is stored locally on your device")
                bulletPoint("Credit balance is stored securely on your device")
                bulletPoint("App preferences are stored locally")
            }
        }
    }
    
    private var dataSharing: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("5. Data Sharing")
                .font(.title2.bold())
            Text("We do not sell or share your personal data. Your artwork is only processed for the purpose of providing AI enhancements.")
        }
    }
    
    private var childrenPrivacy: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("6. Children's Privacy")
                .font(.title2.bold())
            Text("The App is not intended for children under 4.")
        }
    }
    
    private var userRights: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("7. Your Rights")
                .font(.title2.bold())
            Text("You have the right to:")
            bulletPoint("Delete your data by uninstalling the App")
            bulletPoint("Request information about your data usage")
        }
    }
    
    private var aiProcessing: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("8. AI Processing")
                .font(.title2.bold())
            
            VStack(alignment: .leading, spacing: 8) {
                Text("How Our AI Processing Works")
                    .font(.headline)
                bulletPoint("When you submit a drawing for enhancement, it is temporarily uploaded to Open AI secure servers")
                bulletPoint("The image is processed using OpenAI's API")
                bulletPoint("The enhanced result is returned to your device")
                bulletPoint("Original and processed images are stored only on your device")
                bulletPoint("Server-side data is automatically deleted after processing")
            }
        }
    }
    
    private var contact: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("9. Contact Us")
                .font(.title2.bold())
            Text("If you have questions about this Privacy Policy, please contact us at: piirto@tatami.dev")
        }
    }
    
    private func bulletPoint(_ text: String) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Text("•")
            Text(text)
        }
        .foregroundStyle(.secondary)
    }
} 