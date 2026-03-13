# 🏋️ Flutter AI Fitness Tracker

A **smart mobile fitness tracker app** built using **Flutter** that uses **AI pose detection** to automatically detect and count exercises using the device camera.

This applicationtrack their workouts, monitor daily progress, and stay motivated with voice coaching and achievements.

---

# 📱 Features

### 💪 Push-Up Counter

Automatically counts push-ups using **camera pose detection**.

### 📷 Camera-Based Exercise Detection

Uses **Google ML Kit Pose Detection** to analyze body movements.

Supported exercises:

* Push-ups
* Squats
* Sit-ups
* Plank

### 🔊 Voice Coach

Provides motivational feedback using **Text-to-Speech**.

Examples:

* “Great job!”
* “Keep going!”
* “Halfway there!”

### 🏆 Achievement System

Unlock badges when reaching workout milestones.

Example badges:

* First Work
* 10 Pushups Badge
* Fitness Warrior
* 100 Pushups Champion

### 📊 Daily Progress Tracking

Displays daily workout statistics.

### 📜 Workout History

Stores and displays previous workouts.

### 🎨 Clean Modern UI

Simple and user-friendly Flutter interface.

---

# 🛠 Technologies Used

| Technology     | Purpose                |
| -------------- | ---------------------- |
| Flutter        | Mobile App Development |
| Dart           | Programming Language   |
| Camera Package | Access device camera   |
| Google ML Kit  | Pose detection         |
| Flutter TTS    | Voice coaching         |
| SQFlite        | Local database storage |

---

# 📦 Flutter Packages

```
camera
google_mlkit_pose_detection
flutter_tts
sqflite
path_provider
```

Install dependencies:

```bash
flutter pub get
```

---

# 📂 Project Structure

```
fitness_tracker/
│
├── lib/
│   ├── main.dart
│
│   ├── screens/
│   │   ├── home_screen.dart
│   │   ├── camera_workout_screen.dart
│   │   ├── progress_screen.dart
│   │   ├── achievements_screen.dart
│   │   └── history_screen.dart
│
│   ├── services/
│   │   ├── pose_detector_service.dart
│   │   ├── voice_coach_service.dart
│   │   └── database_service.dart
│
│   ├── models/
│   │   └── workout_model.dart
│
│   ├── widgets/
│   │   └── workout_card.dart
│
│   └── utils/
│       └── achievements.dart
│
├── android/
├── ios/
├── assets/
├── pubspec.yaml
└── README.md
```

---

# 📸 App Screens

### 🏠 Home Screen

Main screen for navigating to workouts, progress, achievements, and history.

### 📷 Workout Camera Screen

Uses camera and AI to detect exercises and count repetitions.

### 📊 Progress Screen

Displays daily fitness statistics.

### 🏆 Achievements Screen

Shows badges and milestones.

### 📜 Workout History Screen

Displays previously completed workouts.

---

# ⚙️ Installation

### 1️⃣ Clone the repository

```bash
git clone https://github.com/YOUR_USERNAME/fitness_tracker.git
```

### 2️⃣ Open the project

```bash
cd fitness_tracker
```

### 3️⃣ Install dependencies

```bash
flutter pub get
```

### 4️⃣ Run the application

```bash
flutter run
```

---

# 📷 Camera Permission

This app requires **camera access** for exercise detection.

Add permission in:

Android → `AndroidManifest.xml`

``` <uses-permission android:name="android.permission.CAMERA"/>
```

---

# 🚀 Future Improvements

Possible improvements:

* AI posture correction
* Workout analytics graphs
* Calories burned estimation
* Firebase cloud backup
* Leaderboard system
* Social sharing

---

# 🎓 Educational Purpose

This project is created for learning:

* Flutter mobile development
* AI pose detection
* Computer vision basics
* Mobile fitness applications

---

# 👨‍💻 Developer

**Prakash A**
Computer Science Engineering Student

---

# ⭐ Support

If you like this project, please ⭐ **star the repository** on GitHub.
