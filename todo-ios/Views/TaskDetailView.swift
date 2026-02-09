import SwiftUI

struct TaskDetailView: View {
    @ObservedObject var task: TaskEntity
    @ObservedObject var viewModel: TaskViewModel
    @State private var showEditTask = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                HStack {
                    Text(task.taskTitle)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    Spacer()
                    if task.isCompleted {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                            .font(.title)
                    }
                }
                
                HStack {
                    Label(task.taskPriority.rawValue, systemImage: "flag.fill")
                        .foregroundColor(task.taskPriority.color)
                        .padding(8)
                        .background(task.taskPriority.color.opacity(0.2))
                        .cornerRadius(8)
                    
                    Label(task.taskCategory, systemImage: "folder.fill")
                        .foregroundColor(.blue)
                        .padding(8)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(8)
                }
                
                Divider()
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Due Date")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    HStack {
                        Image(systemName: "calendar")
                        Text(task.taskDueDate, style: .date)
                        Text(task.taskDueDate, style: .time)
                    }
                    .foregroundColor(task.isOverdue ? .red : .primary)
                }
                
                if !task.taskDetails.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Description")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        Text(task.taskDetails)
                            .font(.body)
                    }
                }
                
                Spacer()
                
                Button(action: {
                    viewModel.toggleCompletion(task)
                }) {
                    Text(task.isCompleted ? "Mark as Incomplete" : "Mark as Complete")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(task.isCompleted ? Color.gray : Color.accentColor)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
            .padding()
        }
        .navigationTitle("Details")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("Edit") {
                    showEditTask = true
                }
            }
        }
        .sheet(isPresented: $showEditTask) {
            EditTaskView(viewModel: viewModel, task: task)
        }
    }
}
