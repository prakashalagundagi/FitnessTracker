import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF4A90E2);
  static const Color secondary = Color(0xFF667EEA);
  static const Color accent = Color(0xFF764BA2);
  static const Color success = Color(0xFF27AE60);
  static const Color warning = Color(0xFFF39C12);
  static const Color error = Color(0xFFE74C3C);
  static const Color background = Color(0xFFF5F7FA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color onSurface = Color(0xFF2C3E50);
  static const Color onBackground = Color(0xFF7F8C8D);
}

class AppStrings {
  static const String appName = 'Fitness Tracker';
  static const String welcomeBack = 'Welcome back!';
  static const String readyToCrush = 'Ready to crush your fitness goals?';
  static const String currentStreak = 'Current Streak';
  static const String days = 'days';
  static const String todaysProgress = 'Today\'s Progress';
  static const String workouts = 'Workouts';
  static const String totalReps = 'Total Reps';
  static const String duration = 'Duration';
  static const String allTimeStats = 'All-Time Stats';
  static const String quickWorkouts = 'Quick Workouts';
  static const String start = 'START';
  static const String stop = 'STOP';
  static const String reps = 'reps';
  static const String seconds = 'seconds';
  static const String minutes = 'minutes';
}

class AppConstants {
  static const double borderRadius = 12.0;
  static const double spacing = 16.0;
  static const double smallSpacing = 8.0;
  static const double largeSpacing = 24.0;
  static const int animationDuration = 300;
  static const int poseDetectionInterval = 100;
  static const int minTimeBetweenReps = 500;
}

class ExerciseConstants {
  static const Map<String, String> displayNames = {
    'pushups': 'Push-ups',
    'squats': 'Squats',
    'situps': 'Sit-ups',
    'plank': 'Plank',
  };
  
  static const Map<String, IconData> icons = {
    'pushups': Icons.fitness_center,
    'squats': Icons.accessibility_new,
    'situps': Icons.self_improvement,
    'plank': Icons.sports_gymnastics,
  };
  
  static const Map<String, Color> colors = {
    'pushups': AppColors.primary,
    'squats': AppColors.success,
    'situps': AppColors.error,
    'plank': AppColors.warning,
  };
}

class AchievementConstants {
  static const List<Map<String, dynamic>> defaultAchievements = [
    {
      'title': 'First Steps',
      'description': 'Complete your first push-up',
      'iconName': 'emoji_events',
      'requiredReps': 1,
      'exerciseType': 'pushups',
    },
    {
      'title': 'Getting Started',
      'description': 'Complete 10 push-ups in one session',
      'iconName': 'military_tech',
      'requiredReps': 10,
      'exerciseType': 'pushups',
    },
    {
      'title': 'Push-up Warrior',
      'description': 'Complete 25 push-ups in one session',
      'iconName': 'workspace_premium',
      'requiredReps': 25,
      'exerciseType': 'pushups',
    },
    {
      'title': 'Push-up Master',
      'description': 'Complete 50 push-ups in one session',
      'iconName': 'stars',
      'requiredReps': 50,
      'exerciseType': 'pushups',
    },
    {
      'title': 'Squat Champion',
      'description': 'Complete 30 squats in one session',
      'iconName': 'fitness_center',
      'requiredReps': 30,
      'exerciseType': 'squats',
    },
    {
      'title': 'Core Strength',
      'description': 'Complete 20 sit-ups in one session',
      'iconName': 'sports_gymnastics',
      'requiredReps': 20,
      'exerciseType': 'situps',
    },
    {
      'title': 'Plank Holder',
      'description': 'Hold plank for 60 seconds',
      'iconName': 'timer',
      'requiredReps': 60,
      'exerciseType': 'plank',
    },
    {
      'title': 'Daily Warrior',
      'description': 'Workout for 7 consecutive days',
      'iconName': 'calendar_today',
      'requiredReps': 7,
      'exerciseType': 'daily',
    },
  ];
}
