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
    let container: ModelContainer
    
    init() {
        do {
            let schema = Schema([GeneratedImage.self])
            let modelConfiguration = ModelConfiguration(
                schema: schema,
                isStoredInMemoryOnly: false
            )
            
            container = try ModelContainer(
                for: schema,
                configurations: [modelConfiguration]
            )
        } catch {
            fatalError("Failed to initialize ModelContainer: \(error)")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(container)
    }
}
