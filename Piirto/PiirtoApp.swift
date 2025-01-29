//
//  PiirtoApp.swift
//  Piirto
//
//  Created by Miika Kuisma on 23.1.2025.
//

import SwiftUI
import SwiftData
import StoreKit

@main
struct PiirtoApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            GeneratedImage.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    
    init() {
        // Start observing transactions
        PiirtoApp.setupTransactionObserver()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(sharedModelContainer)
                .preferredColorScheme(.light)  // Force light theme
        }
    }
    
    static func setupTransactionObserver() {
        Task {
            await observeTransactions()
        }
    }
    
    static func observeTransactions() async {
        for await verification in Transaction.updates {
            guard case .verified(let transaction) = verification else {
                continue
            }
            
            // Handle the transaction
            switch transaction.productID {
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
        }
    }
}
