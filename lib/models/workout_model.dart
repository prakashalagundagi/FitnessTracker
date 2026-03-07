class WorkoutModel {
  final int? id;
  final String exerciseType;
  final int reps;
  final int duration; // in seconds
  final DateTime timestamp;
  final String? notes;
  final double? calories; // optional calories burned
  final bool isCompleted;

  WorkoutModel({
    this.id,
    required this.exerciseType,
    required this.reps,
    required this.duration,
    required this.timestamp,
    this.notes,
    this.calories,
    this.isCompleted = true,
  });

  // Create a copy with updated values
  WorkoutModel copyWith({
    int? id,
    String? exerciseType,
    int? reps,
    int? duration,
    DateTime? timestamp,
    String? notes,
    double? calories,
    bool? isCompleted,
  }) {
    return WorkoutModel(
      id: id ?? this.id,
      exerciseType: exerciseType ?? this.exerciseType,
      reps: reps ?? this.reps,
      duration: duration ?? this.duration,
      timestamp: timestamp ?? this.timestamp,
      notes: notes ?? this.notes,
      calories: calories ?? this.calories,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  // Convert to database map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'exerciseType': exerciseType,
      'reps': reps,
      'duration': duration,
      'timestamp': timestamp.toIso8601String(),
      'notes': notes,
      'calories': calories,
      'isCompleted': isCompleted ? 1 : 0,
    };
  }

  // Create from database map
  factory WorkoutModel.fromMap(Map<String, dynamic> map) {
    return WorkoutModel(
      id: map['id'],
      exerciseType: map['exerciseType'] ?? '',
      reps: map['reps'] ?? 0,
      duration: map['duration'] ?? 0,
      timestamp: DateTime.parse(map['timestamp'] ?? DateTime.now().toIso8601String()),
      notes: map['notes'],
      calories: map['calories']?.toDouble(),
      isCompleted: (map['isCompleted'] ?? 1) == 1,
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'exerciseType': exerciseType,
      'reps': reps,
      'duration': duration,
      'timestamp': timestamp.toIso8601String(),
      'notes': notes,
      'calories': calories,
      'isCompleted': isCompleted,
    };
  }

  // Create from JSON
  factory WorkoutModel.fromJson(Map<String, dynamic> json) {
    return WorkoutModel(
      id: json['id'],
      exerciseType: json['exerciseType'] ?? '',
      reps: json['reps'] ?? 0,
      duration: json['duration'] ?? 0,
      timestamp: DateTime.parse(json['timestamp'] ?? DateTime.now().toIso8601String()),
      notes: json['notes'],
      calories: json['calories']?.toDouble(),
      isCompleted: json['isCompleted'] ?? true,
    );
  }

  // Get formatted duration string
  String get formattedDuration {
    final minutes = duration ~/ 60;
    final seconds = duration % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  // Get formatted date string
  String get formattedDate {
    return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
  }

  // Get formatted time string
  String get formattedTime {
    return '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
  }

  // Calculate calories burned (approximate)
  double get calculatedCalories {
    // Simple calculation based on exercise type and duration
    switch (exerciseType.toLowerCase()) {
      case 'pushups':
        return (reps * 0.3) + (duration * 0.08);
      case 'squats':
        return (reps * 0.4) + (duration * 0.1);
      case 'situps':
        return (reps * 0.2) + (duration * 0.06);
      case 'plank':
        return duration * 0.05;
      default:
        return duration * 0.07;
    }
  }

  @override
  String toString() {
    return 'WorkoutModel(id: $id, exerciseType: $exerciseType, reps: $reps, duration: $duration, timestamp: $timestamp, isCompleted: $isCompleted)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is WorkoutModel &&
        other.id == id &&
        other.exerciseType == exerciseType &&
        other.reps == reps &&
        other.duration == duration &&
        other.timestamp == timestamp &&
        other.isCompleted == isCompleted;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        exerciseType.hashCode ^
        reps.hashCode ^
        duration.hashCode ^
        timestamp.hashCode ^
        isCompleted.hashCode;
  }
}

// Enum for exercise types
enum ExerciseType {
  pushups,
  squats,
  situps,
  plank,
}

extension ExerciseTypeExtension on ExerciseType {
  String get displayName {
    switch (this) {
      case ExerciseType.pushups:
        return 'Push-ups';
      case ExerciseType.squats:
        return 'Squats';
      case ExerciseType.situps:
        return 'Sit-ups';
      case ExerciseType.plank:
        return 'Plank';
    }
  }

  String get iconName {
    switch (this) {
      case ExerciseType.pushups:
        return 'fitness_center';
      case ExerciseType.squats:
        return 'accessibility_new';
      case ExerciseType.situps:
        return 'self_improvement';
      case ExerciseType.plank:
        return 'sports_gymnastics';
    }
  }
}
