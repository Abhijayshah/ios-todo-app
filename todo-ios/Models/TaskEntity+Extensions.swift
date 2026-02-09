import Foundation
import CoreData
import Combine

extension TaskEntity {
    
    public var taskTitle: String {
        title ?? "New Task"
    }
    
    public var taskDetails: String {
        taskDescription ?? ""
    }
    
    public var taskDueDate: Date {
        dueDate ?? Date()
    }
    
    public var taskPriority: TaskPriority {
        if let priority = priority, let p = TaskPriority(rawValue: priority) {
            return p
        }
        return .medium
    }
    
    public var taskCategory: String {
        category ?? "General"
    }
    
    public var taskCreatedAt: Date {
        createdAt ?? Date()
    }
    
    public var taskUpdatedAt: Date {
        updatedAt ?? Date()
    }
    
    // Helper to check if task is overdue
    public var isOverdue: Bool {
        if let dueDate = dueDate, !isCompleted {
            return dueDate < Date()
        }
        return false
    }
}
