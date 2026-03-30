# WealthTrack

A personal finance tracking app built with Flutter. Track your assets, liabilities, and net worth with gamification elements like coins, milestones, and streaks.

## Features

- Track assets and liabilities
- Net worth dashboard with charts
- Gamification (coins, milestones, daily streaks, check-ins)
- Multiple themes (light, dark, neon)
- Firebase authentication (email, Google, Apple)
- Data export
- PIN lock security

## Requirements

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (version 3.5.0 or higher)
- [Firebase](https://firebase.google.com/) project (already configured in this repo)
- Android Studio / Xcode (for mobile builds)

## Setup

**1. Install dependencies**
```bash
flutter pub get
```

**2. Run the app**
```bash
flutter run
```

To target a specific device:
```bash
flutter devices                  # list available devices
flutter run -d <device-id>       # run on a specific device
```

## Supported Platforms

| Platform | Status |
|----------|--------|
| Android  | Supported |
| iOS      | Supported |
| Windows  | Supported |
| Web      | Supported |

## Tech Stack

- **Framework:** Flutter + Dart
- **State Management:** Riverpod
- **Backend:** Firebase (Auth + Firestore)
- **Navigation:** go_router
- **Charts:** fl_chart
- **Fonts:** Google Fonts
