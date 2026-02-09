import SwiftUI

struct TaskRowView: View {
    @ObservedObject var task: TaskEntity
    var onToggle: () -> Void
    
    var body: some View {
        HStack {
            Button(action: onToggle) {
                Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(task.isCompleted ? .green : .gray)
                    .font(.title2)
            }
            .buttonStyle(PlainButtonStyle())
            
            VStack(alignment: .leading, spacing: 4) {
                Text(task.taskTitle)
                    .font(.headline)
                    .strikethrough(task.isCompleted)
                    .foregroundColor(task.isCompleted ? .gray : .primary)
                
                if !task.taskDetails.isEmpty {
                    Text(task.taskDetails)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .lineLimit(1)
                }
                
                HStack {
                    Image(systemName: "calendar")
                        .font(.caption)
                        .foregroundColor(task.isOverdue ? .red : .secondary)
                    Text(task.taskDueDate, style: .date)
                        .font(.caption)
                        .foregroundColor(task.isOverdue ? .red : .secondary)
                    
                    Spacer()
                    
                    Text(task.taskPriority.rawValue)
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(task.taskPriority.color.opacity(0.2))
                        .foregroundColor(task.taskPriority.color)
                        .cornerRadius(4)
                }
            }
        }
        .padding(.vertical, 4)
    }
}
