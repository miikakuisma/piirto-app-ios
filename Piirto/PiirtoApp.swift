//
//  PiirtoApp.swift
//  Piirto
//
//  Created by Miika Kuisma on 23.1.2025.
//

import SwiftUI
import SwiftData

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
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(sharedModelContainer)
        }
    }
}
