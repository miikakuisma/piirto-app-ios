import Foundation

enum ProcessingState {
    case idle
    case analyzing
    case generating
    
    var message: String {
        switch self {
        case .idle: return ""
        case .analyzing: return "Analyzing..."
        case .generating: return "Generating..."
        }
    }
} 