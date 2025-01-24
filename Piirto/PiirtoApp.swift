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
            container = try ModelContainer(for: GeneratedImage.self)
        } catch {
            fatalError("Failed to initialize ModelContainer")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(container)
    }
}
