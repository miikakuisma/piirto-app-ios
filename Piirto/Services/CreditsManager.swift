import SwiftUI
import StoreKit
import KeychainAccess

@Observable
class CreditsManager {
    static let shared = CreditsManager()
    
    private let keychain = Keychain(service: "dev.tatami.piirtoapp.credits")
        .synchronizable(true)
        .accessibility(.whenUnlocked)
    
    private let creditsKey = "remaining_credits"
    private let firstLaunchKey = "is_first_launch"
    
    let basicPack = Product(
        id: "dev.tatami.piirtoapp.credits.50",
        title: "50 Generations",
        description: "Generate 50 AI images",
        price: "4.99€",
        pricePerGen: "0.10€"
    )
    
    let proPack = Product(
        id: "dev.tatami.piirtoapp.credits.150",
        title: "150 Generations",
        description: "Generate 150 AI images",
        price: "9.99€",
        pricePerGen: "0.07€"
    )
    
    let premiumPack = Product(
        id: "dev.tatami.piirtoapp.credits.400",
        title: "400 Generations",
        description: "Generate 400 AI images",
        price: "19.99€",
        pricePerGen: "0.05€"
    )
    
    var remainingCredits: Int {
        get {
            guard let creditsString = try? keychain.get(creditsKey),
                  let credits = Int(creditsString) else {
                return 0
            }
            return credits
        }
        set {
            try? keychain.set(String(newValue), key: creditsKey)
        }
    }
    
    init() {
        // Check if first launch
        if !UserDefaults.standard.bool(forKey: firstLaunchKey) {
            remainingCredits = 5
            UserDefaults.standard.set(true, forKey: firstLaunchKey)
        }
    }
    
    func useCredit() -> Bool {
        guard remainingCredits > 0 else { return false }
        remainingCredits -= 1
        return true
    }
    
    func addCredits(_ amount: Int) {
        remainingCredits += amount
    }
    
    // Add restore functionality
    func restorePurchases() async throws {
        try await AppStore.sync()
        
        for try await transaction in Transaction.currentEntitlements {
            switch transaction {
            case .verified(let transaction):
                switch transaction.productID {
                case "dev.tatami.piirtoapp.credits.50":
                    await MainActor.run { remainingCredits += 50 }
                case "dev.tatami.piirtoapp.credits.150":
                    await MainActor.run { remainingCredits += 150 }
                case "dev.tatami.piirtoapp.credits.400":
                    await MainActor.run { remainingCredits += 400 }
                default: break
                }
            case .unverified: break
            }
        }
    }
    
    struct Product {
        let id: String
        let title: String
        let description: String
        let price: String
        let pricePerGen: String
    }
} 