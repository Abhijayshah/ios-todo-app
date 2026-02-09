import SwiftUI
import Charts
import CoreData
import Combine

struct DailyTaskCount: Identifiable {
    let id = UUID()
    let date: Date
    let count: Int
}

struct PriorityCount: Identifiable {
    let id = UUID()
    let priority: String
    let count: Int
    var color: Color {
        switch priority {
        case "High": return .red
        case "Medium": return .orange
        case "Low": return .green
        default: return .gray
        }
    }
}

class StatsViewModel: ObservableObject {
    @Published var completionRate: Double = 0.0
    @Published var tasksCompletedLast7Days: [DailyTaskCount] = []
    @Published var tasksByPriority: [PriorityCount] = []
    @Published var currentStreak: Int = 0
    
    private let context = PersistenceController.shared.container.viewContext
    
    func refreshStats() {
        let request: NSFetchRequest<TaskEntity> = TaskEntity.fetchRequest()
        request.predicate = NSPredicate(format: "isTrashed == NO")
        
        do {
            let tasks = try context.fetch(request)
            calculateStats(tasks: tasks)
        } catch {
            print("Error fetching stats: \(error)")
        }
    }
    
    private func calculateStats(tasks: [TaskEntity]) {
        let totalTasks = tasks.count
        guard totalTasks > 0 else {
            completionRate = 0
            tasksCompletedLast7Days = []
            tasksByPriority = []
            currentStreak = 0
            return
        }
        
        let completedTasks = tasks.filter { $0.isCompleted }
        completionRate = Double(completedTasks.count) / Double(totalTasks)
        
        // Priority Distribution
        let groupedByPriority = Dictionary(grouping: tasks, by: { $0.taskPriority.rawValue })
        tasksByPriority = groupedByPriority.map { key, value in
            PriorityCount(priority: key, count: value.count)
        }.sorted { $0.count > $1.count }
        
        // Last 7 Days Completion
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        var last7DaysCounts: [DailyTaskCount] = []
        
        for i in (0..<7).reversed() {
            if let date = calendar.date(byAdding: .day, value: -i, to: today) {
                let count = completedTasks.filter {
                    calendar.isDate($0.taskUpdatedAt, inSameDayAs: date)
                }.count
                last7DaysCounts.append(DailyTaskCount(date: date, count: count))
            }
        }
        self.tasksCompletedLast7Days = last7DaysCounts
        
        // Streak Calculation (Simple implementation)
        var streak = 0
        var checkDate = today
        
        // Check today
        if completedTasks.contains(where: { calendar.isDate($0.taskUpdatedAt, inSameDayAs: checkDate) }) {
            streak += 1
        }
        
        // Check previous days
        while true {
            guard let prevDate = calendar.date(byAdding: .day, value: -1, to: checkDate) else { break }
            if completedTasks.contains(where: { calendar.isDate($0.taskUpdatedAt, inSameDayAs: prevDate) }) {
                streak += 1
                checkDate = prevDate
            } else {
                break
            }
        }
        self.currentStreak = streak
    }
}

struct StatsView: View {
    @StateObject private var viewModel = StatsViewModel()
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Summary Cards
                    HStack(spacing: 15) {
                        StatCard(title: "Completion Rate", value: String(format: "%.0f%%", viewModel.completionRate * 100), icon: "chart.pie.fill", color: .blue)
                        StatCard(title: "Current Streak", value: "\(viewModel.currentStreak) Days", icon: "flame.fill", color: .orange)
                    }
                    .padding(.horizontal)
                    
                    // Weekly Progress Chart
                    VStack(alignment: .leading) {
                        Text("Last 7 Days Activity")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        Chart {
                            ForEach(viewModel.tasksCompletedLast7Days) { item in
                                BarMark(
                                    x: .value("Date", item.date, unit: .day),
                                    y: .value("Completed", item.count)
                                )
                                .foregroundStyle(Color.accentColor.gradient)
                            }
                        }
                        .frame(height: 200)
                        .padding()
                        .background(Color(UIColor.secondarySystemBackground))
                        .cornerRadius(12)
                        .padding(.horizontal)
                    }
                    
                    // Priority Distribution Chart
                    VStack(alignment: .leading) {
                        Text("Tasks by Priority")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        Chart {
                            ForEach(viewModel.tasksByPriority) { item in
                                SectorMark(
                                    angle: .value("Count", item.count),
                                    innerRadius: .ratio(0.618),
                                    angularInset: 1.5
                                )
                                .foregroundStyle(item.color)
                                .annotation(position: .overlay) {
                                    Text("\(item.count)")
                                        .font(.caption)
                                        .foregroundColor(.white)
                                }
                            }
                        }
                        .frame(height: 200)
                        .padding()
                        .background(Color(UIColor.secondarySystemBackground))
                        .cornerRadius(12)
                        .padding(.horizontal)
                        
                        // Legend
                        HStack {
                            ForEach(viewModel.tasksByPriority) { item in
                                HStack(spacing: 4) {
                                    Circle().fill(item.color).frame(width: 8, height: 8)
                                    Text(item.priority).font(.caption)
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("Productivity")
            .onAppear {
                viewModel.refreshStats()
            }
        }
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                Spacer()
            }
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(12)
    }
}
