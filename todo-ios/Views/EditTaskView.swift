import SwiftUI

struct EditTaskView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: TaskViewModel
    @ObservedObject var task: TaskEntity
    
    @State private var title: String
    @State private var description: String
    @State private var dueDate: Date
    @State private var priority: TaskPriority
    @State private var category: String
    @State private var isCompleted: Bool
    
    init(viewModel: TaskViewModel, task: TaskEntity) {
        self.viewModel = viewModel
        self.task = task
        _title = State(initialValue: task.taskTitle)
        _description = State(initialValue: task.taskDetails)
        _dueDate = State(initialValue: task.taskDueDate)
        _priority = State(initialValue: task.taskPriority)
        _category = State(initialValue: task.taskCategory)
        _isCompleted = State(initialValue: task.isCompleted)
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Task Info")) {
                    TextField("Title", text: $title)
                    TextField("Description", text: $description, axis: .vertical)
                        .lineLimit(3...6)
                }
                
                Section(header: Text("Details")) {
                    DatePicker("Due Date", selection: $dueDate, displayedComponents: [.date, .hourAndMinute])
                    
                    Picker("Priority", selection: $priority) {
                        ForEach(TaskPriority.allCases) { priority in
                            Text(priority.rawValue).tag(priority)
                                .foregroundColor(priority.color)
                        }
                    }
                    
                    TextField("Category", text: $category)
                    
                    Toggle("Completed", isOn: $isCompleted)
                }
            }
            .navigationTitle("Edit Task")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveTask()
                    }
                    .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
    
    private func saveTask() {
        viewModel.updateTask(
            task,
            title: title,
            description: description,
            dueDate: dueDate,
            priority: priority,
            category: category,
            isCompleted: isCompleted
        )
        dismiss()
    }
}
