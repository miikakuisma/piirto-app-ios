import SwiftUI

struct PurchaseCreditsView: View {
    @Environment(\.dismiss) private var dismiss
    let creditsManager = CreditsManager.shared
    @State private var storeService = StoreService.shared
    @State private var errorMessage: String?
    @State private var showError = false
    
    var body: some View {
        NavigationStack {
            Group {
                if storeService.purchaseInProgress {
                    ProgressView("Processing purchase...")
                } else {
                    VStack(spacing: 24) {
                        Text("Get More Generations")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        Text("Choose a package below to continue creating amazing art.")
                            .multilineTextAlignment(.center)
                            .foregroundStyle(.secondary)
                            .padding(.horizontal)
                            .foregroundColor(.white)
                        
                        VStack(spacing: 16) {
                            PurchaseOptionCard(
                                product: creditsManager.basicPack,
                                action: { purchase(creditsManager.basicPack.id) }
                            )
                            
                            PurchaseOptionCard(
                                product: creditsManager.proPack,
                                isBestValue: false,
                                action: { purchase(creditsManager.proPack.id) }
                            )
                            
                            PurchaseOptionCard(
                                product: creditsManager.premiumPack,
                                isBestValue: true,
                                action: { purchase(creditsManager.premiumPack.id) }
                            )
                        }
                        .padding()
                    }
                    .padding()
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            LinearGradient(
                gradient: Gradient(colors: [.blue.opacity(0.8), .purple.opacity(0.8)]),
                startPoint: .top,
                endPoint: .bottom
            )
        )
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Done") {
                    dismiss()
                }
            }
        }
        .presentationBackground(.clear)
        .alert("Purchase Failed", isPresented: $showError, actions: {
            Button("OK", role: .cancel) { }
        }, message: {
            Text(errorMessage ?? "Unknown error occurred")
        })
        .task {
            await storeService.loadProducts()
        }
    }
    
    private func purchase(_ productId: String) {
        Task {
            do {
                try await storeService.purchase(productId)
                await MainActor.run {
                    dismiss()
                }
            } catch {
                await MainActor.run {
                    errorMessage = error.localizedDescription
                    showError = true
                }
            }
        }
    }
}

struct PurchaseOptionCard: View {
    let product: CreditsManager.Product
    var isBestValue: Bool = false
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                if isBestValue {
                    Text("Best Deal")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundStyle(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 4)
                        .background(.blue)
                        .clipShape(Capsule())
                }
                
                Text(product.title)
                    .font(.title3)
                    .fontWeight(.semibold)
                
                Text(product.description)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                
                HStack {
                    Text(product.price)
                        .font(.headline)
                    Text("(\(product.pricePerGen) per generation)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(.top, 4)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color(.systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .buttonStyle(.plain)
    }
} 