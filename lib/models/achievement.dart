class Achievement {
  final int? id;
  final String title;
  final String description;
  final String iconName;
  final int requiredReps;
  final String exerciseType;
  final bool isUnlocked;
  final DateTime? unlockedAt;

  Achievement({
    this.id,
    required this.title,
    required this.description,
    required this.iconName,
    required this.requiredReps,
    required this.exerciseType,
    this.isUnlocked = false,
    this.unlockedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'iconName': iconName,
      'requiredReps': requiredReps,
      'exerciseType': exerciseType,
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
      requiredReps: map['requiredReps'],
      exerciseType: map['exerciseType'],
      isUnlocked: map['isUnlocked'] == 1,
      unlockedAt: map['unlockedAt'] != null ? DateTime.parse(map['unlockedAt']) : null,
    );
  }

  static List<Achievement> getDefaultAchievements() {
    return [
      Achievement(
        title: 'First Steps',
        description: 'Complete your first push-up',
        iconName: 'emoji_events',
        requiredReps: 1,
        exerciseType: 'pushups',
      ),
      Achievement(
        title: 'Getting Started',
        description: 'Complete 10 push-ups in one session',
        iconName: 'military_tech',
        requiredReps: 10,
        exerciseType: 'pushups',
      ),
      Achievement(
        title: 'Push-up Warrior',
        description: 'Complete 25 push-ups in one session',
        iconName: 'workspace_premium',
        requiredReps: 25,
        exerciseType: 'pushups',
      ),
      Achievement(
        title: 'Push-up Master',
        description: 'Complete 50 push-ups in one session',
        iconName: 'stars',
        requiredReps: 50,
        exerciseType: 'pushups',
      ),
      Achievement(
        title: 'Squat Champion',
        description: 'Complete 30 squats in one session',
        iconName: 'fitness_center',
        requiredReps: 30,
        exerciseType: 'squats',
      ),
      Achievement(
        title: 'Core Strength',
        description: 'Complete 20 sit-ups in one session',
        iconName: 'sports_gymnastics',
        requiredReps: 20,
        exerciseType: 'situps',
      ),
      Achievement(
        title: 'Plank Holder',
        description: 'Hold plank for 60 seconds',
        iconName: 'timer',
        requiredReps: 60,
        exerciseType: 'plank',
      ),
      Achievement(
        title: 'Daily Warrior',
        description: 'Workout for 7 consecutive days',
        iconName: 'calendar_today',
        requiredReps: 7,
        exerciseType: 'daily',
      ),
    ];
  }
}
