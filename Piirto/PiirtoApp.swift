//
//  PiirtoApp.swift
//  Piirto
//
//  Created by Miika Kuisma on 23.1.2025.
//

import SwiftUI
import SwiftData
import StoreKit
import PencilKit

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
        
        // Set default PencilKit settings
        let defaults = UserDefaults.standard
        if defaults.object(forKey: "PKPaletteNamedDefaults") == nil {
            defaults.set(Dictionary<String, Any>(), forKey: "PKPaletteNamedDefaults")
        }
        
        // Set initial tool (optional)
        if defaults.object(forKey: "PKDrawingToolPreferred") == nil {
            defaults.set("pen", forKey: "PKDrawingToolPreferred")
        }
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
            case "dev.tatami.piirtoapp.credits.50":
                CreditsManager.shared.remainingCredits += 50
            case "dev.tatami.piirtoapp.credits.150":
                CreditsManager.shared.remainingCredits += 150
            case "dev.tatami.piirtoapp.credits.400":
                CreditsManager.shared.remainingCredits += 400
            default:
                break
            }
            
            await transaction.finish()
        }
    }
}
