import Foundation
import SwiftUI

enum DrawingTool: String, CaseIterable {
    case pencil
    case eraser
    
    var defaultLineWidth: CGFloat {
        switch self {
        case .pencil: return 4
        case .eraser: return 20
        }
    }
    
    var defaultOpacity: Double {
        switch self {
        case .pencil: return 0.6
        case .eraser: return 1.0
        }
    }
    
    var lineWidthRange: ClosedRange<CGFloat> {
        switch self {
        case .pencil: return 1...12
        case .eraser: return 10...50
        }
    }
    
    var opacityRange: ClosedRange<Double> {
        switch self {
        case .pencil: return 0.3...0.8
        case .eraser: return 1.0...1.0  // Eraser always fully opaque
        }
    }
    
    var contextBlendMode: GraphicsContext.BlendMode {
        switch self {
        case .pencil: return .plusLighter
        case .eraser: return .clear
        }
    }
} 