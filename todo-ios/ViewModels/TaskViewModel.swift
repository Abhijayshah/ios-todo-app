import Foundation
import Combine
import SwiftUI

class TaskViewModel: ObservableObject {
    @Published var tasks: [TaskEntity] = []
    @Published var searchText: String = ""
    @Published var selectedSortOption: SortOption = .dateDesc
    @Published var showCompleted: Bool = true
    @Published var isSyncing = false
    
    private let taskService = TaskService.shared
    private let syncService = SyncService.shared
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        fetchTasks()
        
        // Debounce search
        $searchText
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .removeDuplicates()
            .sink { [weak self] _ in
                self?.fetchTasks()
            }
            .store(in: &cancellables)
            
        $selectedSortOption
            .sink { [weak self] _ in
                DispatchQueue.main.async {
                    self?.fetchTasks()
                }
            }
            .store(in: &cancellables)
            
        $showCompleted
            .sink { [weak self] _ in
                DispatchQueue.main.async {
                    self?.fetchTasks()
                }
            }
            .store(in: &cancellables)
            
        // Observe Sync Status
        syncService.$isSyncing
            .receive(on: RunLoop.main)
            .assign(to: \.isSyncing, on: self)
            .store(in: &cancellables)
            
        // Initial Sync
        Task {
            await sync()
        }
    }
    
    func fetchTasks() {
        var fetchedTasks = taskService.fetchTasks(filter: searchText, sortOption: selectedSortOption)
        
        // Post-fetch filtering
        if !showCompleted {
            fetchedTasks = fetchedTasks.filter { !$0.isCompleted }
        }
        
        // In-memory sort for Priority (High > Medium > Low)
        if selectedSortOption == .priority {
            fetchedTasks.sort { task1, task2 in
                task1.taskPriority.sortValue > task2.taskPriority.sortValue
            }
        }
        
        self.tasks = fetchedTasks
    }
    
    func addTask(title: String, description: String, dueDate: Date, priority: TaskPriority, category: String) {
        taskService.addTask(title: title, description: description, dueDate: dueDate, priority: priority, category: category)
        fetchTasks()
        triggerSync()
    }
    
    func updateTask(_ task: TaskEntity, title: String, description: String, dueDate: Date, priority: TaskPriority, category: String, isCompleted: Bool) {
        taskService.updateTask(task, title: title, description: description, dueDate: dueDate, priority: priority, category: category, isCompleted: isCompleted)
        fetchTasks()
        triggerSync()
    }
    
    func toggleCompletion(_ task: TaskEntity) {
        taskService.toggleCompletion(task)
        fetchTasks()
        triggerSync()
    }
    
    func deleteTask(at offsets: IndexSet) {
        offsets.forEach { index in
            let task = tasks[index]
            taskService.deleteTask(task)
        }
        fetchTasks()
        triggerSync()
    }
    
    func delete(_ task: TaskEntity) {
        taskService.deleteTask(task)
        fetchTasks()
        triggerSync()
    }
    
    func sync() async {
        await syncService.sync()
        await MainActor.run {
            fetchTasks()
        }
    }
    
    private func triggerSync() {
        Task {
            await sync()
        }
    }
    
    func signOut() {
        Task {
            try? await AuthService.shared.signOut()
            // Clear local data if needed, or keep it
        }
    }
}
