import SwiftUI

struct Line: Identifiable, Equatable {
    let id = UUID()
    var points: [CGPoint]
    var color: Color
    var lineWidth: CGFloat
    var opacity: Double
    var tool: DrawingTool
    
    init(points: [CGPoint], color: Color, lineWidth: CGFloat, opacity: Double, tool: DrawingTool) {
        self.points = points
        self.color = color
        self.lineWidth = lineWidth
        self.opacity = opacity
        self.tool = tool
    }
    
    // Add Equatable conformance
    static func == (lhs: Line, rhs: Line) -> Bool {
        lhs.id == rhs.id &&
        lhs.points == rhs.points &&
        lhs.color == rhs.color &&
        lhs.lineWidth == rhs.lineWidth &&
        lhs.opacity == rhs.opacity &&
        lhs.tool == rhs.tool
    }
    
    // Returns interpolated points for smoother curves
    var interpolatedPoints: [CGPoint] {
        guard points.count > 1 else { return points }
        
        var result: [CGPoint] = []
        
        // Add first point
        result.append(points[0])
        
        // Interpolate between each pair of points
        for i in 0..<points.count - 1 {
            let current = points[i]
            let next = points[i + 1]
            
            // Calculate control points for Catmull-Rom spline
            let previousPoint = i > 0 ? points[i - 1] : current
            let nextPoint = i < points.count - 2 ? points[i + 2] : next
            
            // Add interpolated points between current and next
            let tension: CGFloat = 0.5
            let numberOfSegments = 8
            
            for t in 1..<numberOfSegments {
                let t = CGFloat(t) / CGFloat(numberOfSegments)
                let interpolatedPoint = catmullRomPoint(
                    p0: previousPoint,
                    p1: current,
                    p2: next,
                    p3: nextPoint,
                    t: t,
                    tension: tension
                )
                result.append(interpolatedPoint)
            }
            
            // Add the endpoint
            if i == points.count - 2 {
                result.append(next)
            }
        }
        
        return result
    }
    
    // Catmull-Rom spline interpolation
    private func catmullRomPoint(
        p0: CGPoint,
        p1: CGPoint,
        p2: CGPoint,
        p3: CGPoint,
        t: CGFloat,
        tension: CGFloat
    ) -> CGPoint {
        let t2 = t * t
        let t3 = t2 * t
        
        let m1 = (p2.x - p0.x) * tension
        let m2 = (p3.x - p1.x) * tension
        let x = (2 * p1.x - 2 * p2.x + m1 + m2) * t3 +
                (-3 * p1.x + 3 * p2.x - 2 * m1 - m2) * t2 +
                m1 * t + p1.x
        
        let n1 = (p2.y - p0.y) * tension
        let n2 = (p3.y - p1.y) * tension
        let y = (2 * p1.y - 2 * p2.y + n1 + n2) * t3 +
                (-3 * p1.y + 3 * p2.y - 2 * n1 - n2) * t2 +
                n1 * t + p1.y
        
        return CGPoint(x: x, y: y)
    }
} 