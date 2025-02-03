import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var settings: SettingsManager
    @State private var showPrivacyPolicy = false
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Toggle("AI Features", isOn: $settings.aiFeatureEnabled)
                } footer: {
                    Text("When enabled, allows transforming your drawings with AI")
                }
                
                if settings.aiFeatureEnabled {
                    Section {
                        Picker("Control Type", selection: $settings.aiControlType) {
                            ForEach(AIControlType.allCases, id: \.self) { type in
                                Text(type.rawValue).tag(type)
                            }
                        }
                    } footer: {
                        Text("Choose between a friendly robot assistant or a simple magic button")
                    }
                }
                
                Button {
                    showPrivacyPolicy = true
                } label: {
                    Label("Privacy Policy", systemImage: "lock.shield")
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showPrivacyPolicy) {
                PrivacyPolicyView()
            }
        }
    }
} 