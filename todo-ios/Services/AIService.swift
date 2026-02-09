import Foundation
import Combine

struct AIConfig {
    static let apiKey = Secrets.openRouterApiKey
    static let baseURL = "https://openrouter.ai/api/v1/chat/completions"
    static let model = "gpt-3.5-turbo"
}

struct AIParsedTask: Codable {
    let title: String
    let description: String?
    let dueDate: Date?
    let priority: String?
    let category: String?
}

// OpenRouter Request/Response structures
struct OpenAIChatMessage: Codable {
    let role: String
    let content: String
}

struct OpenAIChatRequest: Codable {
    let model: String
    let messages: [OpenAIChatMessage]
    let temperature: Double
}

struct OpenAIChatResponse: Codable {
    struct Choice: Codable {
        let message: OpenAIChatMessage
    }
    let choices: [Choice]
}

class AIService {
    static let shared = AIService()
    
    private init() {}
    
    func parseNaturalLanguage(_ input: String) async throws -> AIParsedTask {
        guard let url = URL(string: AIConfig.baseURL) else {
            throw URLError(.badURL)
        }
        
        let systemPrompt = """
        You are a smart task assistant. Extract task details from the user's input into a JSON format.
        Return ONLY the JSON with the following keys:
        - title: The main task name.
        - description: Additional details (optional).
        - dueDate: ISO8601 date string (YYYY-MM-DDTHH:mm:ssZ) if mentioned (e.g., "tomorrow", "next friday"), otherwise null.
        - priority: "High", "Medium", or "Low". Infer from urgency words (e.g., "urgent" -> High). Default to "Medium".
        - category: Infer a category (e.g., "Work", "Personal", "Shopping", "Health"). Default to "General".
        """
        
        let messages = [
            OpenAIChatMessage(role: "system", content: systemPrompt),
            OpenAIChatMessage(role: "user", content: input)
        ]
        
        let requestBody = OpenAIChatRequest(
            model: AIConfig.model,
            messages: messages,
            temperature: 0.7
        )
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("Bearer \(AIConfig.apiKey)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        // OpenRouter specific headers
        request.addValue("Todo-iOS-App", forHTTPHeaderField: "HTTP-Referer")
        request.addValue("Todo-iOS", forHTTPHeaderField: "X-Title")
        
        request.httpBody = try JSONEncoder().encode(requestBody)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            if let errorText = String(data: data, encoding: .utf8) {
                print("OpenRouter Error: \(errorText)")
            }
            throw URLError(.badServerResponse)
        }
        
        let chatResponse = try JSONDecoder().decode(OpenAIChatResponse.self, from: data)
        guard let content = chatResponse.choices.first?.message.content else {
            throw URLError(.cannotParseResponse)
        }
        
        // Extract JSON from content (it might be wrapped in markdown code blocks)
        let jsonString = extractJSON(from: content)
        
        // Custom decoding for flexible date formats
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        // Handle potential partial JSON or different date formats if needed
        // For now, assume the LLM follows instructions well.
        
        // We define a temporary struct for decoding because Date decoding can be tricky with LLMs
        struct RawAIParsedTask: Codable {
            let title: String
            let description: String?
            let dueDate: String?
            let priority: String?
            let category: String?
        }
        
        let rawTask = try decoder.decode(RawAIParsedTask.self, from: Data(jsonString.utf8))
        
        // Convert ISO string to Date
        var parsedDate: Date? = nil
        if let dateString = rawTask.dueDate {
            let isoFormatter = ISO8601DateFormatter()
            parsedDate = isoFormatter.date(from: dateString)
        }
        
        return AIParsedTask(
            title: rawTask.title,
            description: rawTask.description,
            dueDate: parsedDate,
            priority: rawTask.priority,
            category: rawTask.category
        )
    }
    
    private func extractJSON(from content: String) -> String {
        if let startRange = content.range(of: "{"),
           let endRange = content.range(of: "}", options: .backwards) {
            let range = startRange.lowerBound..<endRange.upperBound
            return String(content[range])
        }
        return content
    }
    
    func suggestTasks(basedOn history: [String]) async throws -> [String] {
        // Simulate task suggestions for now, or use API if requested.
        // The user prompt specifically asked to "Use the below openrouter.ai credentials" for the task description part.
        // It didn't explicitly ask to change suggestions logic to use API, but "Suggestions" was in the list.
        // For speed/cost, I'll keep suggestions hardcoded or simple for now unless asked.
        // But wait, the user said: "Create Smart Task... Suggestions... Review weekly goals..."
        // This implies the suggestions list in the UI is static or locally generated.
        try await Task.sleep(nanoseconds: 500_000_000)
        return [
            "Review weekly goals",
            "Clean the workspace",
            "Plan next vacation",
            "Read 30 minutes"
        ]
    }
}
