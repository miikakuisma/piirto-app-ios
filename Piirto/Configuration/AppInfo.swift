import Foundation

struct AppInfo {
    static let appVersion: String = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
    static let buildNumber: String = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
    static let appName: String = Bundle.main.infoDictionary?["CFBundleName"] as? String ?? "Piirto"
    
    // App Store ID - replace with your actual App ID once created
    static let appStoreId = "6741417307"
} 