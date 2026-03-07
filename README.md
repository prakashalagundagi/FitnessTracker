# Fitness Tracker App

A complete mobile fitness tracker app built with Flutter, featuring AI-powered pose detection, voice coaching, and comprehensive workout tracking.

## Features

### Core Features
- **Push-up Counter**: Manual and automatic counting with pose detection
- **Camera-based Pose Detection**: Real-time exercise form tracking using Google ML Kit
- **Voice Coach**: Motivational messages and exercise guidance
- **Workout Recorder**: Track pushups, squats, situps, and plank exercises
- **Achievement System**: Unlock badges and milestones
- **Daily Progress Tracking**: Monitor your fitness journey
- **Workout History**: Complete log of all your workouts
- **Modern UI**: Clean, intuitive interface with smooth animations

### Screens
1. **Home Screen**: Dashboard with stats, streak counter, and quick workout access
2. **Workout Camera Screen**: Real-time pose detection and exercise counting
3. **Progress Screen**: Charts, statistics, and performance analytics
4. **Achievements Screen**: Badge collection and milestone tracking
5. **Workout History Screen**: Complete workout log with filtering options

## Technical Stack

### Flutter Packages
- `camera`: Camera access for pose detection
- `google_mlkit_pose_detection`: AI-powered pose detection
- `flutter_tts`: Text-to-speech for voice coaching
- `sqflite`: Local database for data persistence
- `provider`: State management
- `intl`: Date formatting and localization
- `google_fonts`: Custom typography
- `lottie`: Animations

### Architecture
- **MVC Pattern**: Separation of concerns with models, views, and controllers
- **Service Layer**: Centralized business logic
- **Database Service**: SQLite operations with helper methods
- **Voice Coach Service**: TTS management with motivational content
- **Pose Detection Service**: ML Kit integration and exercise counting

## Project Structure

```
lib/
├── main.dart                 # App entry point and navigation
├── models/                   # Data models
│   ├── workout.dart         # Workout data structure
│   ├── achievement.dart     # Achievement system
│   └── daily_progress.dart  # Daily tracking
├── services/                # Business logic
│   ├── database_service.dart    # SQLite operations
│   ├── voice_coach_service.dart # TTS and coaching
│   └── pose_detection_service.dart # ML Kit integration
├── screens/                 # UI screens
│   ├── home_screen.dart     # Main dashboard
│   ├── workout_camera_screen.dart # Camera workout
│   ├── progress_screen.dart # Progress analytics
│   ├── achievements_screen.dart  # Badge system
│   └── workout_history_screen.dart # Workout log
├── widgets/                 # Reusable UI components
└── utils/                   # Helper utilities
```

## Getting Started

### Prerequisites
- Flutter SDK (>=3.10.0)
- Dart SDK (>=3.0.0)
- Android Studio / VS Code
- Physical device or emulator with camera

### Installation

1. Clone the repository:
```bash
git clone <repository-url>
cd fitness_tracker
```

2. Install dependencies:
```bash
flutter pub get
```

3. Run the app:
```bash
flutter run
```

### Permissions
The app requires the following permissions:
- **Camera**: For pose detection and exercise tracking
- **Microphone**: For voice coaching (optional)
- **Storage**: For database and local data

## Usage

### Starting a Workout
1. Tap the floating action button on the home screen
2. Select exercise type (pushups, squats, situps, or plank)
3. Position yourself in front of the camera
4. Press START to begin counting
5. Press STOP to finish and save your workout

### Tracking Progress
- View daily stats on the home screen
- Check progress charts on the Progress screen
- Monitor achievements and unlock new badges
- Review complete workout history

### Voice Coaching
- Enable voice coaching for real-time motivation
- Get exercise tips and form corrections
- Receive milestone announcements
- Hear achievement unlocks

## Pose Detection

### Supported Exercises
- **Push-ups**: Tracks elbow angle and rep counting
- **Squats**: Monitors knee angle and depth
- **Sit-ups**: Detects torso movement
- **Plank**: Timer-based with form monitoring

### Detection Accuracy
- Ensure good lighting conditions
- Position camera to capture full body
- Wear contrasting clothing for better detection
- Maintain consistent exercise form

## Database Schema

### Workouts Table
- `id`: Primary key
- `exerciseType`: Type of exercise
- `reps`: Number of repetitions
- `duration`: Duration in seconds
- `timestamp`: Workout date/time
- `notes`: Optional notes

### Achievements Table
- `id`: Primary key
- `title`: Achievement name
- `description`: Achievement details
- `iconName`: Icon identifier
- `requiredReps`: Requirement for unlock
- `exerciseType`: Associated exercise
- `isUnlocked`: Unlock status
- `unlockedAt`: Unlock timestamp

### Daily Progress Table
- `id`: Primary key
- `date`: Date of progress
- `totalReps`: Total repetitions
- `totalDuration`: Total workout time
- `workoutsCompleted`: Number of workouts
- `exerciseBreakdown`: Exercise-specific stats

## Customization

### Adding New Exercises
1. Update `ExerciseType` enum in `workout.dart`
2. Add pose detection logic in `pose_detection_service.dart`
3. Update UI components and icons
4. Add achievement definitions

### Voice Messages
- Edit motivational messages in `voice_coach_service.dart`
- Add exercise-specific tips
- Customize milestone announcements

### UI Themes
- Modify color schemes in `main.dart`
- Update app icons and fonts
- Customize card styles and animations

## Troubleshooting

### Common Issues
- **Camera not working**: Check camera permissions
- **Pose detection inaccurate**: Improve lighting and positioning
- **Voice not working**: Check TTS settings and permissions
- **Database errors**: Clear app data and restart

### Performance Tips
- Close camera when not in use
- Limit pose detection frequency
- Optimize database queries
- Use efficient state management

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

For issues and questions:
- Create an issue on GitHub
- Check the troubleshooting section
- Review the documentation

---

Built with ❤️ using Flutter
