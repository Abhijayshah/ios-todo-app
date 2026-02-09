import Foundation
import SwiftUI

public enum TaskPriority: String, CaseIterable, Identifiable {
    case low = "Low"
    case medium = "Medium"
    case high = "High"
    
    public var id: String { self.rawValue }
    
    public var color: Color {
        switch self {
        case .low: return .green
        case .medium: return .orange
        case .high: return .red
        }
    }
    
    public var sortValue: Int {
        switch self {
        case .low: return 0
        case .medium: return 1
        case .high: return 2
        }
    }
}
