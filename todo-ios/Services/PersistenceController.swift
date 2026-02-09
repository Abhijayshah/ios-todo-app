import CoreData
import Combine

struct PersistenceController {
    static let shared = PersistenceController()

    @MainActor
    static let preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        for i in 0..<10 {
            let newTask = TaskEntity(context: viewContext)
            newTask.id = UUID()
            newTask.title = "Task \(i)"
            newTask.taskDescription = "Description for task \(i)"
            newTask.dueDate = Date()
            newTask.priority = ["Low", "Medium", "High"].randomElement()
            newTask.isCompleted = Bool.random()
            newTask.category = "General"
            newTask.createdAt = Date()
            newTask.updatedAt = Date()
        }
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return result
    }()

    let container: NSPersistentCloudKitContainer

    init(inMemory: Bool = false) {
        container = NSPersistentCloudKitContainer(name: "todo_ios")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
    
    func save() {
        let context = container.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // In production, handle this error properly
                let nsError = error as NSError
                print("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}
