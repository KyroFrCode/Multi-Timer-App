# Multi Timer App

> A modern multi-timer application for Android built with **Flutter** and **Dart**. Features timer groups, Tabata HIIT sequences, stopwatch, and customizable alarms — all with a clean Material Design UI and Provider state management.

![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart&logoColor=white)
![Android](https://img.shields.io/badge/Android-platform-3DDC84?logo=android&logoColor=white)
![License](https://img.shields.io/badge/license-GPL--3.0-blue)

---

## Description

**Multi Timer App** is a mobile application that lets you run multiple countdown timers simultaneously, organize them into groups, follow Tabata workout sequences, and use a multi-stopwatch — all from a single screen with bottom tab navigation.

Built entirely with AI-assisted development using **[OpenCode](https://opencode.ai)** with free open-source models including **Big Pickle** and others.

### Main Features

- Create and manage **multiple countdown timers** simultaneously
- Organize timers into **groups** for simultaneous start/pause/reset
- **Tabata** HIIT interval training with customizable presets and sequences
- **Multi-stopwatch** with badge showing running count
- **Customizable alarms** with audio playback via `audioplayers`
- **Settings** screen with theme customization
- **Local storage** persistence via `shared_preferences`
- **Local notifications** for timer completion

---

## Project Structure

```
multi_timer_app_new/
├── android/                 # Android platform config (Gradle, manifest)
├── assets/sounds/           # Alarm sound files
├── lib/
│   ├── main.dart            # App entry point, MultiProvider setup, bottom nav
│   ├── models/              # Data models
│   │   ├── alarm_sound.dart
│   │   ├── stopwatch_model.dart
│   │   ├── tabata_preset.dart
│   │   ├── tabata_sequence.dart
│   │   ├── timer_group.dart
│   │   └── timer_model.dart
│   ├── providers/           # State management (Provider)
│   │   ├── stopwatch_provider.dart
│   │   ├── theme_provider.dart
│   │   └── timer_provider.dart
│   ├── screens/             # UI screens
│   │   ├── create_group_screen.dart
│   │   ├── create_timer_screen.dart
│   │   ├── groups_screen.dart
│   │   ├── settings_screen.dart
│   │   ├── stopwatch_screen.dart
│   │   ├── tabata_screen.dart
│   │   └── timers_screen.dart
│   ├── services/            # Business logic & storage
│   │   ├── storage_service.dart
│   │   └── timer_service.dart
│   ├── utils/               # Utilities & themes
│   │   └── app_theme.dart
│   └── widgets/             # Reusable UI components
│       ├── stopwatch_display.dart
│       └── timer_card.dart
├── test/                    # Widget tests
├── pubspec.yaml             # Dependencies & project manifest
├── pubspec.lock             # Locked dependency versions
└── analysis_options.yaml    # Dart linter config
```

---

## Prerequisites

- **Flutter SDK** `>=3.0.0 <4.0.0`
- **Dart SDK** `>=3.0.0`
- **Android SDK** with platform tools and an emulator or physical device
- **Android Studio** or **VS Code** with Flutter/Dart plugins

---

## Installation

```bash
# 1. Clone the repository
git clone https://github.com/<your-username>/multi_timer_app_new.git

# 2. Navigate into the project
cd multi_timer_app_new

# 3. Install dependencies
flutter pub get
```

---

## Running the App

```bash
# Run on connected device or emulator
flutter run
```

Or press **F5** in Android Studio / VS Code with the project open.

---

## Building

### Debug APK
```bash
flutter build apk --debug
```

### Release APK
```bash
flutter build apk --release
```

The built APK will be available at:
```
build/app/outputs/flutter-apk/app-release.apk
```

> **Note:** iOS builds (IPA) require a Mac with Xcode. Run `flutter create --platforms=ios .` to add iOS support, then build with `flutter build ios`.

---

## Usage

1. **Timers tab** — Create new timers with custom names, durations, and alarm sounds. Start, pause, or reset individual timers.
2. **Groups tab** — Group multiple timers together and control them all at once.
3. **Tabata tab** — Set up HIIT workouts with configurable work/rest intervals, rounds, and warm-up/cool-down.
4. **Stopwatch tab** — Run multiple stopwatches simultaneously. A badge shows how many are running.
5. **Settings tab** — Switch between light and dark theme.

---

## Dependencies

| Package | Purpose |
|---|---|
| `provider` | State management |
| `shared_preferences` | Local key-value storage |
| `audioplayers` | Audio playback for alarm sounds |
| `uuid` | Unique ID generation |
| `flutter_local_notifications` | Local notifications |
| `cupertino_icons` | iOS-style icons |

---

## Troubleshooting

- **`flutter pub get` fails** — Ensure Flutter SDK is installed and `flutter doctor` passes.
- **Build fails with Gradle errors** — Run `flutter clean` then `flutter pub get` and try again.
- **No alarm sound plays** — Place `.mp3` or `.wav` files in `assets/sounds/` and ensure they are declared in `pubspec.yaml`.
- **Notifications not showing** — Grant notification permission on the device (required for Android 13+).

---

## License

This project is distributed under the **GPL-3.0** license (see the `LICENSE` file).
