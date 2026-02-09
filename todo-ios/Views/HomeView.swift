import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = TaskViewModel()
    @State private var showAddTask = false
    @State private var showSettings = false
    @State private var showStats = false
    @State private var showSmartInput = false
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(viewModel.tasks) { task in
                    NavigationLink(value: task) {
                        TaskRowView(task: task) {
                            viewModel.toggleCompletion(task)
                        }
                    }
                    .swipeActions(edge: .leading) {
                        Button {
                            viewModel.toggleCompletion(task)
                        } label: {
                            Label(task.isCompleted ? "Mark Incomplete" : "Mark Complete", systemImage: "checkmark")
                        }
                        .tint(.green)
                    }
                    .swipeActions(edge: .trailing) {
                        Button(role: .destructive) {
                            viewModel.delete(task)
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                }
            }
            .searchable(text: $viewModel.searchText, prompt: "Search tasks...")
            .navigationTitle("Tasks")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    HStack {
                        Button {
                            showSettings = true
                        } label: {
                            Image(systemName: "gear")
                        }
                        
                        Button {
                            showStats = true
                        } label: {
                            Image(systemName: "chart.bar.xaxis")
                        }
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack {
                        if viewModel.isSyncing {
                            ProgressView()
                                .scaleEffect(0.7)
                        } else {
                            Button {
                                Task { await viewModel.sync() }
                            } label: {
                                Image(systemName: "arrow.triangle.2.circlepath")
                            }
                        }
                        
                        Menu {
                            Picker("Sort", selection: $viewModel.selectedSortOption) {
                                Text("Newest First").tag(SortOption.dateDesc)
                                Text("Oldest First").tag(SortOption.dateAsc)
                                Text("Priority").tag(SortOption.priority)
                                Text("Title").tag(SortOption.title)
                            }
                            
                            Divider()
                            
                            Toggle("Show Completed", isOn: $viewModel.showCompleted)
                        } label: {
                            Image(systemName: "line.3.horizontal.decrease.circle")
                        }
                    }
                }
                
                ToolbarItem(placement: .bottomBar) {
                    HStack {
                        Button {
                            showSmartInput = true
                        } label: {
                            Image(systemName: "wand.and.stars")
                                .font(.title2)
                        }
                        
                        Spacer()
                        
                        Button {
                            showAddTask = true
                        } label: {
                            HStack {
                                Image(systemName: "plus.circle.fill")
                                Text("New Task")
                            }
                            .font(.headline)
                            .padding()
                            .background(Color.accentColor.opacity(0.1))
                            .cornerRadius(8)
                        }
                        
                        Spacer()
                        
                        // Placeholder for balance
                        Color.clear.frame(width: 44, height: 44)
                    }
                }
            }
            .navigationDestination(for: TaskEntity.self) { task in
                TaskDetailView(task: task, viewModel: viewModel)
            }
            .navigationDestination(isPresented: $showStats) {
                StatsView()
            }
            .sheet(isPresented: $showAddTask) {
                AddTaskView(viewModel: viewModel)
            }
            .sheet(isPresented: $showSettings) {
                SettingsView()
            }
            .sheet(isPresented: $showSmartInput) {
                SmartInputView(viewModel: viewModel)
            }
        }
    }
}
