# mediremind

A Flutter medication reminder app to help users track their medications.

## About the Project

This app lets users add medications with dosage info, set reminders, and mark when they've taken them. It's built with Flutter for cross-platform support.

### Key Features
- Add/edit/delete medications
- Set custom reminders with time and frequency
- Track taken/pending meds
- View stats on medication adherence
- Get notifications for med times

## Tech Stack

Frontend:
- Flutter (Dart) - UI framework
- GetX - State management & dependency injection
- Responsive Sizer - For responsive layouts

Backend:
- SQFlite - Local database storage
- Flutter Local Notifications - For reminder alerts
- Timezone - For handling timezone-aware notifications

**Other Libraries:**
- Get - For navigation and snackbars
- Path Provider - For file system access

## Installation

1. **Prerequisites:**
    - Flutter SDK (v3.0+ recommended)
    - Android Studio/Xcode for emulators
    - Physical device for testing notifications

2. **Setup:**
   
   _git clone [repo-url]
   cd mediremind
   flutter pub get_
   

3. **Run the app:**
   
   flutter run
  

## Configuration

For notifications to work properly:

- On Android:
    - Ensure "Exact Alarms" permission is granted (Android 12+)
    - Battery optimization disabled for the app

- On iOS:
    - Notification permissions must be approved
    - Background app refresh enabled

## Known Issues

- Notifications might be delayed on some Android devices due to battery optimizations
- Timezone handling could be improved for travelers
- No cloud sync yet (planned for future version)


A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
