import Foundation
import Combine

struct SupabaseTask: Codable, Identifiable {
    var id: UUID
    var userId: UUID
    var title: String
    var description: String?
    var dueDate: Date?
    var priority: String?
    var isCompleted: Bool
    var category: String?
    var createdAt: Date
    var updatedAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case title
        case description
        case dueDate = "due_date"
        case priority
        case isCompleted = "is_completed"
        case category
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}
