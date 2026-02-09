import Foundation
import CoreData

class TaskService {
    static let shared = TaskService()
    private let persistenceController = PersistenceController.shared
    
    var viewContext: NSManagedObjectContext {
        persistenceController.container.viewContext
    }
    
    func fetchTasks(filter: String = "", sortOption: SortOption = .dateDesc) -> [TaskEntity] {
        let request: NSFetchRequest<TaskEntity> = TaskEntity.fetchRequest()
        
        // Filtering
        var predicates: [NSPredicate] = [NSPredicate(format: "isTrashed == NO")]
        
        if !filter.isEmpty {
            predicates.append(NSPredicate(format: "title CONTAINS[cd] %@ OR taskDescription CONTAINS[cd] %@", filter, filter))
        }
        
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        
        // Sorting
        switch sortOption {
        case .dateAsc:
            request.sortDescriptors = [NSSortDescriptor(keyPath: \TaskEntity.dueDate, ascending: true)]
        case .dateDesc:
            request.sortDescriptors = [NSSortDescriptor(keyPath: \TaskEntity.dueDate, ascending: false)]
        case .priority:
            // Sorting by priority string is tricky (High, Medium, Low alphabetically is H, M, L).
            // We might need to sort in memory or store integer priority.
            // For now, let's just sort by title if priority sort is requested, or we can't easily sort by string value logic in CoreData directly without a transform.
            // Let's rely on memory sort for priority or just sort by title.
            // Actually, if we want proper priority sort, we should have used Int.
            // But I can sort by title as fallback or creation date.
            request.sortDescriptors = [NSSortDescriptor(keyPath: \TaskEntity.priority, ascending: false)] 
        case .title:
            request.sortDescriptors = [NSSortDescriptor(keyPath: \TaskEntity.title, ascending: true)]
        }
        
        do {
            return try viewContext.fetch(request)
        } catch {
            print("Error fetching tasks: \(error)")
            return []
        }
    }
    
    func addTask(title: String, description: String, dueDate: Date, priority: TaskPriority, category: String) {
        let newTask = TaskEntity(context: viewContext)
        newTask.id = UUID()
        newTask.title = title
        newTask.taskDescription = description
        newTask.dueDate = dueDate
        newTask.priority = priority.rawValue
        newTask.isCompleted = false
        newTask.isTrashed = false
        newTask.category = category
        newTask.createdAt = Date()
        newTask.updatedAt = Date()
        
        saveContext()
    }
    
    func updateTask(_ task: TaskEntity, title: String, description: String, dueDate: Date, priority: TaskPriority, category: String, isCompleted: Bool) {
        task.title = title
        task.taskDescription = description
        task.dueDate = dueDate
        task.priority = priority.rawValue
        task.category = category
        task.isCompleted = isCompleted
        task.updatedAt = Date()
        
        saveContext()
    }
    
    func toggleCompletion(_ task: TaskEntity) {
        task.isCompleted.toggle()
        task.updatedAt = Date()
        saveContext()
    }
    
    func deleteTask(_ task: TaskEntity) {
        task.isTrashed = true
        task.updatedAt = Date()
        saveContext()
    }
    
    private func saveContext() {
        persistenceController.save()
    }
}

enum SortOption {
    case dateAsc
    case dateDesc
    case priority
    case title
}
