import SwiftUI
import StoreKit

@Observable
class CreditsManager {
    static let shared = CreditsManager()
    
    private let creditsKey = "remaining_credits"
    private let firstLaunchKey = "is_first_launch"
    
    let basicPack = Product(
        id: "com.yourapp.piirto.credits.50",
        title: "50 Generations",
        description: "Generate 50 AI images",
        price: "4.99€",
        pricePerGen: "0.10€"
    )
    
    let proPack = Product(
        id: "com.yourapp.piirto.credits.150",
        title: "150 Generations",
        description: "Generate 150 AI images",
        price: "9.99€",
        pricePerGen: "0.07€"
    )
    
    let premiumPack = Product(
        id: "com.yourapp.piirto.credits.400",
        title: "400 Generations",
        description: "Generate 400 AI images",
        price: "19.99€",
        pricePerGen: "0.05€"
    )
    
    var remainingCredits: Int {
        get { UserDefaults.standard.integer(forKey: creditsKey) }
        set { UserDefaults.standard.set(newValue, forKey: creditsKey) }
    }
    
    init() {
        // Give 5 free credits on first launch
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
    
    struct Product {
        let id: String
        let title: String
        let description: String
        let price: String
        let pricePerGen: String
    }
} 