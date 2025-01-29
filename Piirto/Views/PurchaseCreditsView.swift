import SwiftUI

struct PurchaseCreditsView: View {
    @Environment(\.dismiss) private var dismiss
    let creditsManager = CreditsManager.shared
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Text("Get More Generations")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("Choose a package below to continue creating amazing art.")
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal)
                
                VStack(spacing: 16) {
                    PurchaseOptionCard(
                        product: creditsManager.basicPack,
                        action: { /* Implement purchase */ }
                    )
                    
                    PurchaseOptionCard(
                        product: creditsManager.proPack,
                        isBestValue: false,
                        action: { /* Implement purchase */ }
                    )
                    
                    PurchaseOptionCard(
                        product: creditsManager.premiumPack,
                        isBestValue: true,
                        action: { /* Implement purchase */ }
                    )
                }
                .padding()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
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