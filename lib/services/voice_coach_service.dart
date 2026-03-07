import 'package:flutter_tts/flutter_tts.dart';
import 'dart:math';

class VoiceCoachService {
  static final VoiceCoachService _instance = VoiceCoachService._internal();
  factory VoiceCoachService() => _instance;
  VoiceCoachService._internal();

  final FlutterTts _flutterTts = FlutterTts();
  bool _isInitialized = false;

  // Motivational messages
  final List<String> _motivationalMessages = [
    "You're doing great! Keep pushing!",
    "Excellent form! Don't give up!",
    "You're stronger than you think!",
    "Almost there! Keep going!",
    "Fantastic work! Stay focused!",
    "You've got this! Push through!",
    "Incredible effort! Keep it up!",
    "You're on fire! Don't stop now!",
    "Strong work! You're making progress!",
    "Amazing! Keep that energy going!",
  ];

  // Exercise-specific messages
  final Map<String, List<String>> _exerciseMessages = {
    'pushups': [
      "Lower down slowly, and push up with power!",
      "Keep your core tight and body straight!",
      "Great push-up form! Keep it steady!",
      "Chest to the ground, full range of motion!",
    ],
    'squats': [
      "Keep your back straight and chest up!",
      "Go down to parallel if you can!",
      "Perfect squat depth! Drive up through your heels!",
      "Keep your weight on your heels, not toes!",
    ],
    'situps': [
      "Engage your core, don't use momentum!",
      "Control the movement up and down!",
      "Breathe out as you come up!",
      "Keep your chin off your chest!",
    ],
    'plank': [
      "Keep your body in a straight line!",
      "Engage your core and glutes!",
      "Don't let your hips drop!",
      "Breathe steadily and hold strong!",
    ],
  };

  // Count messages
  final List<String> _countMessages = [
    "One!",
    "Two!",
    "Three!",
    "Four!",
    "Five!",
    "Six!",
    "Seven!",
    "Eight!",
    "Nine!",
    "Ten!",
    "Eleven!",
    "Twelve!",
    "Thirteen!",
    "Fourteen!",
    "Fifteen!",
    "Sixteen!",
    "Seventeen!",
    "Eighteen!",
    "Nineteen!",
    "Twenty!",
  ];

  // Milestone messages
  final Map<int, String> _milestoneMessages = {
    5: "Five reps! You're warming up nicely!",
    10: "Ten reps! Great endurance!",
    15: "Fifteen! You're building strength!",
    20: "Twenty reps! Incredible work!",
    25: "Twenty-five! You're a beast!",
    30: "Thirty reps! Unbelievable!",
    50: "Fifty reps! You're a champion!",
  };

  Future<void> initialize() async {
    if (_isInitialized) return;

    await _flutterTts.setLanguage("en-US");
    await _flutterTts.setPitch(1.0);
    await _flutterTts.setSpeechRate(0.9);
    await _flutterTts.setVolume(1.0);
    
    _isInitialized = true;
  }

  Future<void> speak(String text) async {
    if (!_isInitialized) await initialize();
    
    try {
      await _flutterTts.speak(text);
    } catch (e) {
      print("Error speaking: $e");
    }
  }

  Future<void> stop() async {
    try {
      await _flutterTts.stop();
    } catch (e) {
      print("Error stopping TTS: $e");
    }
  }

  void announceCount(int count) {
    if (count <= _countMessages.length) {
      speak(_countMessages[count - 1]);
    } else {
      speak(count.toString());
    }
  }

  void announceMilestone(int count) {
    if (_milestoneMessages.containsKey(count)) {
      speak(_milestoneMessages[count]!);
    }
  }

  void giveMotivation() {
    Random random = Random();
    String message = _motivationalMessages[random.nextInt(_motivationalMessages.length)];
    speak(message);
  }

  void giveExerciseTip(String exerciseType) {
    if (_exerciseMessages.containsKey(exerciseType)) {
      List<String> messages = _exerciseMessages[exerciseType]!;
      Random random = Random();
      String message = messages[random.nextInt(messages.length)];
      speak(message);
    }
  }

  void announceWorkoutStart(String exerciseType) {
    String displayName = _getExerciseDisplayName(exerciseType);
    speak("Starting $displayName! Let's do this!");
  }

  void announceWorkoutEnd(String exerciseType, int reps) {
    String displayName = _getExerciseDisplayName(exerciseType);
    speak("Great job! You completed $reps $displayName! Take a well-deserved rest!");
  }

  void announcePlankTime(int seconds) {
    if (seconds % 10 == 0 && seconds > 0) {
      speak("$seconds seconds! Hold strong!");
    } else if (seconds == 30) {
      speak("30 seconds! Halfway there!");
    } else if (seconds == 60) {
      speak("One minute! You're doing amazing!");
    }
  }

  void announcePlankEnd(int seconds) {
    speak("Excellent! You held the plank for $seconds seconds! Core of steel!");
  }

  String _getExerciseDisplayName(String exerciseType) {
    switch (exerciseType) {
      case 'pushups':
        return 'push-ups';
      case 'squats':
        return 'squats';
      case 'situps':
        return 'sit-ups';
      case 'plank':
        return 'plank';
      default:
        return exerciseType;
    }
  }

  void announceDailyGoal(int currentWorkouts, int goalWorkouts) {
    if (currentWorkouts >= goalWorkouts) {
      speak("Congratulations! You've completed your daily workout goal!");
    } else {
      int remaining = goalWorkouts - currentWorkouts;
      speak("Great progress! $remaining more workouts to reach your daily goal!");
    }
  }

  void announceAchievement(String achievementTitle) {
    speak("Achievement unlocked: $achievementTitle! You're making incredible progress!");
  }

  void announceStreak(int days) {
    if (days == 1) {
      speak("Welcome back! Let's start a new streak!");
    } else {
      speak("Amazing! You've worked out for $days consecutive days! Keep the streak alive!");
    }
  }
}
