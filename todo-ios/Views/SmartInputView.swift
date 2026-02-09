import SwiftUI

struct SmartInputView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: TaskViewModel
    @State private var input = ""
    @State private var isProcessing = false
    @State private var suggestedTasks: [String] = []
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("Describe your task naturally")
                    .font(.headline)
                    .foregroundColor(.secondary)
                
                TextEditor(text: $input)
                    .frame(height: 100)
                    .padding()
                    .background(Color(UIColor.secondarySystemBackground))
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.accentColor.opacity(0.3), lineWidth: 1)
                    )
                
                if isProcessing {
                    ProgressView("AI is analyzing...")
                }
                
                Button(action: processInput) {
                    HStack {
                        Image(systemName: "wand.and.stars")
                        Text("Create Smart Task")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(input.isEmpty ? Color.gray : Color.purple)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                .disabled(input.isEmpty || isProcessing)
                
                if !suggestedTasks.isEmpty {
                    VStack(alignment: .leading) {
                        Text("Suggestions")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        ForEach(suggestedTasks, id: \.self) { suggestion in
                            Button(action: { input = suggestion }) {
                                Text(suggestion)
                                    .padding()
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .background(Color(UIColor.secondarySystemBackground))
                                    .cornerRadius(8)
                            }
                        }
                    }
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("AI Assistant")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
            }
            .onAppear {
                loadSuggestions()
            }
        }
    }
    
    private func processInput() {
        isProcessing = true
        Task {
            do {
                let parsedTask = try await AIService.shared.parseNaturalLanguage(input)
                
                // Convert string priority to TaskPriority enum
                let priorityEnum = TaskPriority(rawValue: parsedTask.priority ?? "Medium") ?? .medium
                
                await MainActor.run {
                    viewModel.addTask(
                        title: parsedTask.title,
                        description: parsedTask.description ?? "",
                        dueDate: parsedTask.dueDate ?? Date(),
                        priority: priorityEnum,
                        category: parsedTask.category ?? "General"
                    )
                    isProcessing = false
                    dismiss()
                }
            } catch {
                print("AI Error: \(error)")
                isProcessing = false
            }
        }
    }
    
    private func loadSuggestions() {
        Task {
            // In a real app, pass actual history
            let suggestions = try? await AIService.shared.suggestTasks(basedOn: [])
            await MainActor.run {
                self.suggestedTasks = suggestions ?? []
            }
        }
    }
}
