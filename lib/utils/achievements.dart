import '../models/workout_model.dart';

class Achievement {
  final String id;
  final String title;
  final String description;
  final String iconName;
  final String condition;
  final bool isUnlocked;
  final DateTime? unlockedAt;

  Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.iconName,
    required this.condition,
    this.isUnlocked = false,
    this.unlockedAt,
  });

  Achievement copyWith({
    String? id,
    String? title,
    String? description,
    String? iconName,
    String? condition,
    bool? isUnlocked,
    DateTime? unlockedAt,
  }) {
    return Achievement(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      iconName: iconName ?? this.iconName,
      condition: condition ?? this.condition,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      unlockedAt: unlockedAt ?? this.unlockedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'iconName': iconName,
      'condition': condition,
      'isUnlocked': isUnlocked ? 1 : 0,
      'unlockedAt': unlockedAt?.toIso8601String(),
    };
  }

  factory Achievement.fromMap(Map<String, dynamic> map) {
    return Achievement(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      iconName: map['iconName'],
      condition: map['condition'],
      isUnlocked: (map['isUnlocked'] ?? 0) == 1,
      unlockedAt: map['unlockedAt'] != null ? DateTime.parse(map['unlockedAt']) : null,
    );
  }
}

class AchievementManager {
  static List<Achievement> getAllAchievements() {
    return [
      // First workout achievements
      Achievement(
        id: 'first_pushup',
        title: 'First Push-up',
        description: 'Complete your first push-up',
        iconName: 'fitness_center',
        condition: 'Complete 1 push-up',
      ),
      Achievement(
        id: 'first_squat',
        title: 'First Squat',
        description: 'Complete your first squat',
        iconName: 'accessibility_new',
        condition: 'Complete 1 squat',
      ),
      Achievement(
        id: 'first_situp',
        title: 'First Sit-up',
        description: 'Complete your first sit-up',
        iconName: 'self_improvement',
        condition: 'Complete 1 sit-up',
      ),
      Achievement(
        id: 'first_plank',
        title: 'Plank Beginner',
        description: 'Hold a plank for 30 seconds',
        iconName: 'sports_gymnastics',
        condition: 'Hold plank for 30 seconds',
      ),

      // Milestone achievements
      Achievement(
        id: 'pushup_10',
        title: 'Push-up Pro',
        description: 'Complete 10 push-ups in one session',
        iconName: 'military_tech',
        condition: 'Complete 10 push-ups',
      ),
      Achievement(
        id: 'pushup_25',
        title: 'Push-up Master',
        description: 'Complete 25 push-ups in one session',
        iconName: 'emoji_events',
        condition: 'Complete 25 push-ups',
      ),
      Achievement(
        id: 'pushup_50',
        title: 'Push-up Legend',
        description: 'Complete 50 push-ups in one session',
        iconName: 'workspace_premium',
        condition: 'Complete 50 push-ups',
      ),
      Achievement(
        id: 'squat_20',
        title: 'Squat Champion',
        description: 'Complete 20 squats in one session',
        iconName: 'military_tech',
        condition: 'Complete 20 squats',
      ),
      Achievement(
        id: 'squat_50',
        title: 'Squat Master',
        description: 'Complete 50 squats in one session',
        iconName: 'emoji_events',
        condition: 'Complete 50 squats',
      ),
      Achievement(
        id: 'situp_15',
        title: 'Core Strength',
        description: 'Complete 15 sit-ups in one session',
        iconName: 'military_tech',
        condition: 'Complete 15 sit-ups',
      ),
      Achievement(
        id: 'situp_30',
        title: 'Core Master',
        description: 'Complete 30 sit-ups in one session',
        iconName: 'emoji_events',
        condition: 'Complete 30 sit-ups',
      ),
      Achievement(
        id: 'plank_60',
        title: 'Plank Expert',
        description: 'Hold a plank for 60 seconds',
        iconName: 'military_tech',
        condition: 'Hold plank for 60 seconds',
      ),
      Achievement(
        id: 'plank_120',
        title: 'Plank Master',
        description: 'Hold a plank for 120 seconds',
        iconName: 'emoji_events',
        condition: 'Hold plank for 120 seconds',
      ),

      // Consistency achievements
      Achievement(
        id: 'daily_3',
        title: '3-Day Streak',
        description: 'Workout for 3 consecutive days',
        iconName: 'local_fire_department',
        condition: 'Workout 3 days in a row',
      ),
      Achievement(
        id: 'daily_7',
        title: 'Week Warrior',
        description: 'Workout for 7 consecutive days',
        iconName: 'local_fire_department',
        condition: 'Workout 7 days in a row',
      ),
      Achievement(
        id: 'daily_30',
        title: 'Monthly Champion',
        description: 'Workout for 30 consecutive days',
        iconName: 'workspace_premium',
        condition: 'Workout 30 days in a row',
      ),

      // Total workout achievements
      Achievement(
        id: 'total_10',
        title: 'Getting Started',
        description: 'Complete 10 total workouts',
        iconName: 'stars',
        condition: 'Complete 10 workouts',
      ),
      Achievement(
        id: 'total_50',
        title: 'Fitness Enthusiast',
        description: 'Complete 50 total workouts',
        iconName: 'stars',
        condition: 'Complete 50 workouts',
      ),
      Achievement(
        id: 'total_100',
        title: 'Fitness Expert',
        description: 'Complete 100 total workouts',
        iconName: 'stars',
        condition: 'Complete 100 workouts',
      ),

      // Calorie achievements
      Achievement(
        id: 'calories_100',
        title: 'Calorie Burner',
        description: 'Burn 100 total calories',
        iconName: 'local_fire_department',
        condition: 'Burn 100 calories',
      ),
      Achievement(
        id: 'calories_500',
        title: 'Fitness Furnace',
        description: 'Burn 500 total calories',
        iconName: 'local_fire_department',
        condition: 'Burn 500 calories',
      ),
      Achievement(
        id: 'calories_1000',
        title: 'Calorie Crusher',
        description: 'Burn 1000 total calories',
        iconName: 'workspace_premium',
        condition: 'Burn 1000 calories',
      ),

      // Special achievements
      Achievement(
        id: 'variety_3',
        title: 'All-Rounder',
        description: 'Complete 3 different exercise types in one day',
        iconName: 'diversity_3',
        condition: 'Try 3 exercises in one day',
      ),
      Achievement(
        id: 'morning_person',
        title: 'Early Bird',
        description: 'Complete 5 workouts before 8 AM',
        iconName: 'wb_sunny',
        condition: '5 morning workouts',
      ),
      Achievement(
        id: 'night_owl',
        title: 'Night Owl',
        description: 'Complete 5 workouts after 8 PM',
        iconName: 'nightlight',
        condition: '5 evening workouts',
      ),
    ];
  }

  static List<Achievement> checkUnlockedAchievements(List<WorkoutModel> workouts, List<Achievement> currentAchievements) {
    List<Achievement> updatedAchievements = List.from(currentAchievements);
    
    // Calculate workout statistics
    final Map<String, int> exerciseCounts = {};
    final Map<String, int> dailyCounts = {};
    final Map<String, List<String>> dailyExerciseTypes = {};
    final Map<int, int> hourlyCounts = {};
    double totalCalories = 0;
    int currentStreak = 0;
    int maxStreak = 0;

    // Process workouts
    for (final workout in workouts) {
      // Count exercises by type
      exerciseCounts[workout.exerciseType] = (exerciseCounts[workout.exerciseType] ?? 0) + workout.reps;
      
      // Count daily workouts
      final dateKey = workout.formattedDate;
      dailyCounts[dateKey] = (dailyCounts[dateKey] ?? 0) + 1;
      
      // Track exercise types per day
      dailyExerciseTypes[dateKey] = (dailyExerciseTypes[dateKey] ?? [])..add(workout.exerciseType);
      dailyExerciseTypes[dateKey] = dailyExerciseTypes[dateKey]!.toSet().toList();
      
      // Count hourly workouts
      final hour = workout.timestamp.hour;
      hourlyCounts[hour] = (hourlyCounts[hour] ?? 0) + 1;
      
      // Calculate calories
      totalCalories += workout.calculatedCalories;
    }

    // Calculate streak
    final sortedDates = dailyCounts.keys.toList()..sort();
    currentStreak = _calculateCurrentStreak(sortedDates);

    // Check each achievement
    for (int i = 0; i < updatedAchievements.length; i++) {
      if (updatedAchievements[i].isUnlocked) continue;

      final achievement = updatedAchievements[i];
      bool shouldUnlock = false;

      switch (achievement.id) {
        // First workout achievements
        case 'first_pushup':
          shouldUnlock = (exerciseCounts['pushups'] ?? 0) >= 1;
          break;
        case 'first_squat':
          shouldUnlock = (exerciseCounts['squats'] ?? 0) >= 1;
          break;
        case 'first_situp':
          shouldUnlock = (exerciseCounts['situps'] ?? 0) >= 1;
          break;
        case 'first_plank':
          shouldUnlock = workouts.any((w) => w.exerciseType == 'plank' && w.duration >= 30);
          break;

        // Milestone achievements
        case 'pushup_10':
          shouldUnlock = (exerciseCounts['pushups'] ?? 0) >= 10;
          break;
        case 'pushup_25':
          shouldUnlock = (exerciseCounts['pushups'] ?? 0) >= 25;
          break;
        case 'pushup_50':
          shouldUnlock = (exerciseCounts['pushups'] ?? 0) >= 50;
          break;
        case 'squat_20':
          shouldUnlock = (exerciseCounts['squats'] ?? 0) >= 20;
          break;
        case 'squat_50':
          shouldUnlock = (exerciseCounts['squats'] ?? 0) >= 50;
          break;
        case 'situp_15':
          shouldUnlock = (exerciseCounts['situps'] ?? 0) >= 15;
          break;
        case 'situp_30':
          shouldUnlock = (exerciseCounts['situps'] ?? 0) >= 30;
          break;
        case 'plank_60':
          shouldUnlock = workouts.any((w) => w.exerciseType == 'plank' && w.duration >= 60);
          break;
        case 'plank_120':
          shouldUnlock = workouts.any((w) => w.exerciseType == 'plank' && w.duration >= 120);
          break;

        // Consistency achievements
        case 'daily_3':
          shouldUnlock = currentStreak >= 3;
          break;
        case 'daily_7':
          shouldUnlock = currentStreak >= 7;
          break;
        case 'daily_30':
          shouldUnlock = currentStreak >= 30;
          break;

        // Total workout achievements
        case 'total_10':
          shouldUnlock = workouts.length >= 10;
          break;
        case 'total_50':
          shouldUnlock = workouts.length >= 50;
          break;
        case 'total_100':
          shouldUnlock = workouts.length >= 100;
          break;

        // Calorie achievements
        case 'calories_100':
          shouldUnlock = totalCalories >= 100;
          break;
        case 'calories_500':
          shouldUnlock = totalCalories >= 500;
          break;
        case 'calories_1000':
          shouldUnlock = totalCalories >= 1000;
          break;

        // Special achievements
        case 'variety_3':
          shouldUnlock = dailyExerciseTypes.values.any((types) => types.length >= 3);
          break;
        case 'morning_person':
          shouldUnlock = (hourlyCounts[7] ?? 0) + (hourlyCounts[6] ?? 0) >= 5;
          break;
        case 'night_owl':
          shouldUnlock = (hourlyCounts[20] ?? 0) + (hourlyCounts[21] ?? 0) + (hourlyCounts[22] ?? 0) >= 5;
          break;
      }

      if (shouldUnlock) {
        updatedAchievements[i] = achievement.copyWith(
          isUnlocked: true,
          unlockedAt: DateTime.now(),
        );
      }
    }

    return updatedAchievements;
  }

  static int _calculateCurrentStreak(List<String> sortedDates) {
    if (sortedDates.isEmpty) return 0;

    int streak = 0;
    final today = DateTime.now();
    final todayStr = '${today.day}/${today.month}/${today.year}';
    
    // Check if there's a workout today
    if (sortedDates.last != todayStr) {
      // Check if there's a workout yesterday
      final yesterday = today.subtract(const Duration(days: 1));
      final yesterdayStr = '${yesterday.day}/${yesterday.month}/${yesterday.year}';
      if (sortedDates.last != yesterdayStr) {
        return 0; // No recent workouts
      }
    }

    // Count consecutive days
    DateTime currentDate = sortedDates.last == todayStr ? today : today.subtract(const Duration(days: 1));
    
    for (int i = sortedDates.length - 1; i >= 0; i--) {
      final dateStr = sortedDates[i];
      final currentDateStr = '${currentDate.day}/${currentDate.month}/${currentDate.year}';
      
      if (dateStr == currentDateStr) {
        streak++;
        currentDate = currentDate.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }

    return streak;
  }

  static int getUnlockedCount(List<Achievement> achievements) {
    return achievements.where((a) => a.isUnlocked).length;
  }

  static double getProgressPercentage(List<Achievement> achievements) {
    if (achievements.isEmpty) return 0.0;
    return (getUnlockedCount(achievements) / achievements.length) * 100;
  }
}
