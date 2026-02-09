# Premium Productivity Platform (iOS)

A production-grade, offline-first iOS To-Do application built with SwiftUI, CoreData, and Supabase. Features AI task assistance, advanced analytics, real-time collaboration, and biometric security.

## 🚀 Features

- **Smart Task Management**: Create, edit, and organize tasks with priorities and categories.
- **✨ AI Assistant**: Natural language task creation (e.g., "Buy milk tomorrow at 5pm urgent") and smart suggestions.
- **📊 Analytics**: Visual productivity dashboard with charts and streak tracking.
- **🤝 Collaboration**: Share lists with friends/colleagues and see changes in real-time.
- **☁️ Sync**: Seamless offline-online synchronization using Supabase.
- **📅 Calendar**: Two-way sync with Apple Calendar.
- **🔒 Security**: FaceID/TouchID biometric lock.
- **💎 Monetization**: Premium subscription infrastructure (StoreKit 2).

## 🛠 Tech Stack

- **iOS**: SwiftUI, Combine, MVVM
- **Backend**: Supabase (PostgreSQL, Auth, Realtime, Storage)
- **Local Storage**: CoreData (Offline-first)
- **AI**: OpenAI API
- **Charts**: Swift Charts

## 🏁 Getting Started

### 1. Prerequisites
- Xcode 14.0+
- iOS 16.0+ Simulator or Device
- Supabase Account
- OpenAI API Key (Optional)

### 2. Supabase Setup
1. Create a new project at [supabase.com](https://supabase.com).
2. Go to the **SQL Editor** in your Supabase dashboard.
3. Copy the contents of `SUPABASE_SETUP.sql` from this project.
4. Paste it into the editor and click **Run**.
5. Copy your **Project URL** and **Anon Key** from Project Settings -> API.
6. Open `todo-ios/SupabaseConfig.swift` (create it if missing) and add your keys.

### 3. AI Configuration (Optional)
To enable the "Smart Input" feature:
1. Get an API Key from [platform.openai.com](https://platform.openai.com).
2. Open `todo-ios/Services/AIService.swift`.
3. Replace `YOUR_OPENAI_API_KEY` with your actual key.

### 4. Run the App
1. Open `todo-ios.xcodeproj` in Xcode.
2. Select your target simulator (e.g., iPhone 15 Pro).
3. Press **Cmd+R** to build and run.

## 📚 Documentation

- [User Guide](USER_GUIDE.md): How to use the app features.
- [Developer Guide](DEV_GUIDE.md): Architecture and code explanation.
- [Deployment Guide](DEPLOYMENT.md): App Store submission checklist.

## 📁 Project Structure

- `Models`: Data entities (`TaskEntity`, `UserProfile`).
- `Views`: UI screens (`HomeView`, `StatsView`, `PremiumView`).
- `ViewModels`: Logic (`TaskViewModel`, `StatsViewModel`).
- `Services`: `SupabaseManager`, `AuthService`, `SyncService`, `AIService`.
