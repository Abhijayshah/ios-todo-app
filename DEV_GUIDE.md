# Developer Guide

## Project Structure

- **Models**: `TaskEntity`, `UserProfile`, `AIParsedTask`
- **Views**: SwiftUI Views (`HomeView`, `StatsView`, `SmartInputView`, `PremiumView`)
- **ViewModels**: `TaskViewModel`, `StatsViewModel`
- **Services**: 
  - `SupabaseManager`: Handles all Supabase interactions.
  - `AuthService`: Manages user authentication.
  - `SyncService`: Offline-first synchronization logic.
  - `AIService`: Mocked OpenAI integration (requires API Key).
  - `CalendarService`: EventKit integration.
  - `StoreKitManager`: IAP management.

## Setup Instructions

1. **Prerequisites**:
   - Xcode 14.0+
   - iOS 16.0+
   - Supabase Account
   - OpenAI API Key (Optional)

2. **Supabase Configuration**:
   - Create a project at [supabase.com](https://supabase.com).
   - Run the SQL scripts in `SUPABASE_SETUP.sql` in your Supabase SQL Editor.
   - Update `SupabaseConfig.swift` with your URL and Anon Key.

3. **StoreKit Configuration**:
   - Create a StoreKit Configuration file in Xcode for local testing.
   - Add products: `com.todo.premium.monthly`, `com.todo.premium.yearly`.

4. **Running the App**:
   - Open `todo-ios.xcodeproj`.
   - Select your target simulator or device.
   - Press Run (Cmd+R).

## Architecture

The app follows the **MVVM** pattern with an **Offline-First** approach.
- **CoreData** is the single source of truth for the UI.
- **SyncService** synchronizes CoreData with Supabase in the background.
- **Combine** is used for reactive updates.

## Key APIs

- **OpenAI**: Used in `AIService.swift`. Replace the placeholder key with your own.
- **EventKit**: Used in `CalendarService.swift` for calendar syncing.
- **LocalAuthentication**: Used in `BiometricAuthService.swift`.
