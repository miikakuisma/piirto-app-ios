import StoreKit

@Observable
class StoreService {
    static let shared = StoreService()
    private var products: [Product] = []
    private(set) var purchaseInProgress = false
    
    @MainActor
    func loadProducts() async {
        do {
            let productIds = [
                "com.yourapp.piirto.credits.50",
                "com.yourapp.piirto.credits.150",
                "com.yourapp.piirto.credits.400"
            ]
            products = try await Product.products(for: productIds)
            print("Loaded products:", products)  // Debug info
        } catch {
            print("Failed to load products:", error.localizedDescription)
        }
    }
    
    @MainActor
    func purchase(_ productId: String) async throws {
        guard !products.isEmpty else {
            print("No products loaded")
            throw StoreError.productNotFound
        }
        
        guard let product = products.first(where: { $0.id == productId }) else {
            print("Product not found:", productId)
            print("Available products:", products.map { $0.id })
            throw StoreError.productNotFound
        }
        
        purchaseInProgress = true
        defer { purchaseInProgress = false }
        
        do {
            let result = try await product.purchase()
            
            switch result {
            case .success(let verification):
                switch verification {
                case .verified(let transaction):
                    // Add credits based on the product
                    switch product.id {
                    case "com.yourapp.piirto.credits.50":
                        CreditsManager.shared.remainingCredits += 50
                    case "com.yourapp.piirto.credits.150":
                        CreditsManager.shared.remainingCredits += 150
                    case "com.yourapp.piirto.credits.400":
                        CreditsManager.shared.remainingCredits += 400
                    default:
                        break
                    }
                    await transaction.finish()
                case .unverified:
                    throw StoreError.verificationFailed
                }
            case .userCancelled:
                throw StoreError.userCancelled
            case .pending:
                throw StoreError.pending
            @unknown default:
                throw StoreError.unknown
            }
        } catch {
            print("Purchase failed with error:", error.localizedDescription)
            throw error
        }
    }
    
    enum StoreError: LocalizedError {
        case productNotFound
        case purchaseFailed
        case verificationFailed
        case userCancelled
        case pending
        case unknown
        
        var errorDescription: String? {
            switch self {
            case .productNotFound:
                return "Product not found in the store"
            case .purchaseFailed:
                return "Purchase failed"
            case .verificationFailed:
                return "Purchase verification failed"
            case .userCancelled:
                return "Purchase was cancelled"
            case .pending:
                return "Purchase is pending"
            case .unknown:
                return "An unknown error occurred"
            }
        }
    }
} 