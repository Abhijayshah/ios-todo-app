# Project Details & Security Setup

## 🔒 API Key Management
This project uses a secure method to manage sensitive API keys (OpenAI/OpenRouter, Supabase, etc.) to prevent accidental leaks to version control systems like Git.

### How it works
1.  **`Secrets.swift`**: This file contains the **real** API keys.
    *   **Location**: `todo-ios/Services/Secrets.swift`
    *   **Status**: Ignored by Git (via `.gitignore`).
    *   **Action**: NEVER commit or share this file.

2.  **`Secrets.example.swift`**: This file contains **placeholder** keys.
    *   **Location**: `todo-ios/Services/Secrets.example.swift`
    *   **Status**: Tracked by Git.
    *   **Action**: This serves as a template for other developers.

### ⚠️ Important for New Developers
When cloning this repository or setting it up on a new machine:

1.  Navigate to `todo-ios/Services/`.
2.  Duplicate `Secrets.example.swift`.
3.  Rename the copy to `Secrets.swift`.
4.  Open `Secrets.swift` and replace the placeholder strings with your actual API credentials:
    ```swift
    struct Secrets {
        static let openRouterApiKey = "sk-..."
        static let supabaseURL = URL(string: "https://...")!
        static let supabaseAnonKey = "eyJ..."
    }
    ```
5.  Build the project.

## 🛡️ .gitignore Configuration
The `.gitignore` file has been configured to automatically exclude sensitive files and system-generated artifacts:
- `todo-ios/Services/Secrets.swift` (API Keys)
- `DerivedData/` (Xcode build artifacts)
- `xcuserdata/` (User-specific Xcode settings)
- `.DS_Store` (macOS system files)

Always verify you are not committing sensitive data before pushing changes.
