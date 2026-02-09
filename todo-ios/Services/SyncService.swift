import Foundation
import CoreData
import Combine

#if canImport(Supabase)
import Supabase
#endif

class SyncService: ObservableObject {
    static let shared = SyncService()
    
    @Published var isSyncing = false
    @Published var lastSyncTime: Date?
    
    #if canImport(Supabase)
    private let client = SupabaseManager.shared.client
    private let context = PersistenceController.shared.container.viewContext
    #endif
    
    private init() {}
    
    #if canImport(Supabase)
    func sync() async {
        guard let userId = AuthService.shared.currentUserId else { return }
        
        await MainActor.run { isSyncing = true }
        defer { Task { await MainActor.run { isSyncing = false } } }
        
        do {
            // 1. Push Local Changes
            try await pushLocalChanges(userId: userId)
            
            // 2. Pull Remote Changes
            try await pullRemoteChanges(userId: userId)
            
            await MainActor.run { lastSyncTime = Date() }
        } catch {
            print("Sync error: \(error)")
        }
    }
    
    private func pushLocalChanges(userId: UUID) async throws {
        let request: NSFetchRequest<TaskEntity> = TaskEntity.fetchRequest()
        // Fetch items modified since last sync or never synced
        // Simpler: Fetch all where updatedAt > syncedAt OR syncedAt is nil
        request.predicate = NSPredicate(format: "updatedAt > syncedAt OR syncedAt == nil")
        
        let localTasks = try context.fetch(request)
        
        for task in localTasks {
            let supabaseTask = SupabaseTask(
                id: task.id ?? UUID(),
                userId: userId,
                title: task.taskTitle,
                description: task.taskDescription,
                dueDate: task.taskDueDate,
                priority: task.taskPriority.rawValue,
                isCompleted: task.isCompleted,
                category: task.taskCategory,
                createdAt: task.taskCreatedAt,
                updatedAt: task.taskUpdatedAt
            )
            
            if task.isTrashed {
                try await client
                    .from("tasks")
                    .delete()
                    .eq("id", value: supabaseTask.id)
                    .execute()
                
                // Hard delete from local
                context.delete(task)
            } else {
                try await client
                    .from("tasks")
                    .upsert(supabaseTask)
                    .execute()
                
                task.syncedAt = Date()
            }
        }
        
        if context.hasChanges {
            try context.save()
        }
    }
    
    private func pullRemoteChanges(userId: UUID) async throws {
        // In a real app, use 'lastSyncTime' to only fetch new changes
        // For now, fetch all tasks for user to ensure consistency
        let tasks: [SupabaseTask] = try await client
            .from("tasks")
            .select()
            .eq("user_id", value: userId)
            .execute()
            .value
        
        try await MainActor.run {
            for remoteTask in tasks {
                let request: NSFetchRequest<TaskEntity> = TaskEntity.fetchRequest()
                request.predicate = NSPredicate(format: "id == %@", remoteTask.id as CVarArg)
                request.fetchLimit = 1
                
                let existingTasks = try context.fetch(request)
                let localTask = existingTasks.first ?? TaskEntity(context: context)
                
                // Conflict Resolution: Server wins if remote is newer
                if existingTasks.isEmpty || remoteTask.updatedAt > (localTask.updatedAt ?? Date.distantPast) {
                    localTask.id = remoteTask.id
                    localTask.title = remoteTask.title
                    localTask.taskDescription = remoteTask.description
                    localTask.dueDate = remoteTask.dueDate
                    localTask.priority = remoteTask.priority
                    localTask.isCompleted = remoteTask.isCompleted
                    localTask.category = remoteTask.category
                    localTask.createdAt = remoteTask.createdAt
                    localTask.updatedAt = remoteTask.updatedAt
                    localTask.syncedAt = Date() // Mark as synced
                }
            }
            
            if context.hasChanges {
                try context.save()
            }
        }
    }
    
    func startRealtimeListener() {
        // Implement Realtime subscription here
        let channel = client.channel("public:tasks")
        
        let changeStream = channel.postgresChange(
            AnyAction.self,
            schema: "public",
            table: "tasks"
        )
        
        Task {
            for await _ in changeStream {
                // On any change, trigger a sync
                // Optimization: parse the change payload and update locally directly
                await sync()
            }
        }
        
        Task {
            await channel.subscribe()
        }
    }
    #endif
    
    #if !canImport(Supabase)
    func sync() async { }
    private func pushLocalChanges(userId: UUID) async throws { }
    private func pullRemoteChanges(userId: UUID) async throws { }
    func startRealtimeListener() { }
    #endif
}
