import SwiftUI

class SettingsManager: ObservableObject {
    @AppStorage("aiFeatureEnabled") var aiFeatureEnabled: Bool = true
    @AppStorage("aiControlType") var aiControlType: AIControlType = .robot
}

enum AIControlType: String, CaseIterable {
    case robot = "Robot Assistant"
    case button = "Magic Button"
} 