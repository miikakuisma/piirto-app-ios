import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var settings: SettingsManager
    @State private var showPrivacyPolicy = false
    @State private var showRestoreAlert = false
    @State private var restoreResult: (success: Bool, message: String)? = nil
    
    var body: some View {
        NavigationStack {
            Form {
                Section("AI Features") {
                    Toggle("Enable AI Features", isOn: $settings.aiFeatureEnabled)
                    
                    Picker("Control Style", selection: $settings.aiControlType) {
                        ForEach(AIControlType.allCases, id: \.self) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                }
                
                Section("Account") {
                    Button("Restore Purchases") {
                        Task {
                            do {
                                try await CreditsManager.shared.restorePurchases()
                                restoreResult = (true, "Successfully restored purchases!")
                            } catch {
                                restoreResult = (false, "Restore failed: \(error.localizedDescription)")
                            }
                            showRestoreAlert = true
                        }
                    }
                    
                    NavigationLink("Privacy Policy") {
                        PrivacyPolicyView()
                    }
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
            .alert("Restore Purchases", isPresented: $showRestoreAlert) {
                Button("OK") { }
            } message: {
                Text(restoreResult?.message ?? "")
            }
        }
    }
} 