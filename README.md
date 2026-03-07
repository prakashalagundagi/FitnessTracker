# FitnessTracker
FitnessTracker
# 🏋️ AI Fitness Tracker App (Flutter)

A smart **AI-powered fitness tracker mobile application** built using **Flutter**.
The app uses **camera-based pose detection** to automatically count exercises like push-ups and provides **voice coaching, workout tracking, achievements, and progress monitoring**.

This project demonstrates the use of **Computer Vision + Mobile App Development** for fitness tracking.

---

# 📱 Features

## 1️⃣ Push-up Counter

Automatically counts push-ups using **camera pose detection**.

## 2️⃣ Camera-based Exercise Detection

Uses **Google ML Kit Pose Detection** to detect body movements.

Exercises supported:

* Push-ups
* Squats
* Sit-ups
* Plank

## 3️⃣ Voice Coach

Motivational voice feedback using **Text-to-Speech**.

Examples:

* "Great job!"
* "Keep going!"
* "Halfway done!"

## 4️⃣ Workout Recorder

Records exercise data including:

* Exercise type
* Repetition count
* Date and time

## 5️⃣ Achievement System

Users unlock badges when reaching fitness milestones.

Examples:

* First Workout
* 10 Push-ups Badge
* Fitness Warrior
* 100 Push-ups Champion

## 6️⃣ Daily Progress Tracking

Displays daily fitness statistics.

Example:

* Push-ups today
* Squats today
* Plank duration

## 7️⃣ Workout History

Stores and displays past workout sessions.

## 8️⃣ Clean Modern UI

Simple and user-friendly Flutter interface.

---

# 🛠️ Technologies Used

| Technology                   | Purpose                |
| ---------------------------- | ---------------------- |
| Flutter                      | Mobile App Development |
| Dart                         | Programming Language   |
| Camera Package               | Access phone camera    |
| Google ML Kit Pose Detection | AI body pose detection |
| Flutter TTS                  | Voice coach            |
| SQFlite                      | Local database storage |

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

```
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
```

---

# 📸 App Screens

## 🏠 Home Screen

Main navigation screen where users can access workouts, progress, achievements, and history.

## 📷 Workout Camera Screen

Uses the device camera to detect exercise movements and count repetitions.

## 📊 Progress Screen

Displays daily workout statistics.

## 🏆 Achievements Screen

Shows earned badges and fitness milestones.

## 📜 Workout History Screen

Displays previous workout sessions.

---

# ⚙️ Installation Guide

### 1️⃣ Clone the repository

```
git clone https://github.com/yourusername/fitness-tracker.git
```

### 2️⃣ Navigate to project folder

```
cd fitness-tracker
```

### 3️⃣ Install dependencies

```
flutter pub get
```

### 4️⃣ Run the app

```
flutter run
```

---

# 📷 Camera Permission

The app requires **camera permission** to detect exercises.

Add permission in:

### Android

`AndroidManifest.xml`

```
<uses-permission android:name="android.permission.CAMERA"/>
```

---

# 🚀 Future Improvements

Planned improvements:

* AI exercise form correction
* Workout analytics graphs
* Calories burned estimation
* Leaderboard system
* Social fitness sharing
* Cloud database integration

---

# 🎓 Educational Purpose

This project is designed for:

* Flutter learning
* Computer Vision practice
* Mobile app portfolio projects
* Fitness technology development

---

# 🤝 Contribution

Contributions are welcome!

You can contribute by:

* Improving pose detection
* Adding new workouts
* Enhancing UI design
* Adding workout analytics

---

# 📄 License

This project is open-source and available under the **MIT License**.

---

# 👨‍💻 Developer

**Prakash A**
Computer Science Student
Flutter Developer | Cybersecurity Enthusiast

---

# ⭐ Support

If you like this project, please **star the repository** on GitHub ⭐
