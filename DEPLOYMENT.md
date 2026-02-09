# Deployment & App Store Submission

## Pre-Submission Checklist

### 1. App Store Optimization (ASO)
- **App Name**: Productivity Pro - AI To-Do List
- **Subtitle**: Organize, Plan & Collaborate
- **Keywords**: todo, task manager, productivity, ai, calendar, sync, collaboration
- **Description**: Highlight key features (AI, Offline-first, Analytics).

### 2. Assets
- **App Icon**: 1024x1024 png.
- **Screenshots**: Capture `HomeView`, `StatsView`, `SmartInputView`, and `PremiumView` on 6.5" and 5.5" displays.

### 3. Privacy Policy
- Update `Info.plist` with usage descriptions:
  - `NSCalendarsUsageDescription`: "We sync your tasks with your calendar."
  - `NSFaceIDUsageDescription`: "Secure your tasks."
- Provide a URL to your privacy policy in App Store Connect.

### 4. In-App Purchases
- Set up products in App Store Connect.
- Create a "Paid Applications Agreement".
- Upload a binary to test IAP in TestFlight.

## Build Process

1. **Archive**:
   - Select "Any iOS Device (arm64)".
   - Product -> Archive.
2. **Validate**:
   - In the Organizer, click "Validate App".
   - Fix any signing or asset issues.
3. **Distribute**:
   - Click "Distribute App" -> "App Store Connect" -> "Upload".

## Post-Release
- Monitor crash reports in Xcode Organizer.
- Check analytics in App Store Connect.
- Reply to user reviews.
