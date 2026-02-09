import SwiftUI

struct AddTaskView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: TaskViewModel
    
    @State private var title = ""
    @State private var description = ""
    @State private var dueDate = Date()
    @State private var priority: TaskPriority = .medium
    @State private var category = "General"
    
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
                }
            }
            .navigationTitle("New Task")
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
        viewModel.addTask(
            title: title,
            description: description,
            dueDate: dueDate,
            priority: priority,
            category: category
        )
        dismiss()
    }
}
