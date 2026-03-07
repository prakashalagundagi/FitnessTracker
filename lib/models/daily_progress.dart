import 'workout.dart';

class DailyProgress {
  final int? id;
  final DateTime date;
  final int totalReps;
  final int totalDuration;
  final int workoutsCompleted;
  final Map<String, int> exerciseBreakdown;

  DailyProgress({
    this.id,
    required this.date,
    this.totalReps = 0,
    this.totalDuration = 0,
    this.workoutsCompleted = 0,
    Map<String, int>? exerciseBreakdown,
  }) : exerciseBreakdown = exerciseBreakdown ?? {};

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'totalReps': totalReps,
      'totalDuration': totalDuration,
      'workoutsCompleted': workoutsCompleted,
      'exerciseBreakdown': exerciseBreakdown.toString(),
    };
  }

  factory DailyProgress.fromMap(Map<String, dynamic> map) {
    // Parse the exerciseBreakdown string back to Map
    Map<String, int> breakdown = {};
    if (map['exerciseBreakdown'] != null) {
      String breakdownStr = map['exerciseBreakdown'];
      // Simple parsing - in production, you might want to use JSON
      breakdownStr = breakdownStr.replaceAll('{', '').replaceAll('}', '');
      List<String> pairs = breakdownStr.split(',');
      for (String pair in pairs) {
        List<String> keyValue = pair.split(':');
        if (keyValue.length == 2) {
          String key = keyValue[0].trim().replaceAll(' ', '');
          int value = int.tryParse(keyValue[1].trim()) ?? 0;
          breakdown[key] = value;
        }
      }
    }

    return DailyProgress(
      id: map['id'],
      date: DateTime.parse(map['date']),
      totalReps: map['totalReps'] ?? 0,
      totalDuration: map['totalDuration'] ?? 0,
      workoutsCompleted: map['workoutsCompleted'] ?? 0,
      exerciseBreakdown: breakdown,
    );
  }

  DailyProgress addWorkout(Workout workout) {
    Map<String, int> newBreakdown = Map.from(exerciseBreakdown);
    String exerciseKey = workout.exerciseType;
    newBreakdown[exerciseKey] = (newBreakdown[exerciseKey] ?? 0) + workout.reps;
    
    return DailyProgress(
      id: id,
      date: date,
      totalReps: totalReps + workout.reps,
      totalDuration: totalDuration + workout.duration,
      workoutsCompleted: workoutsCompleted + 1,
      exerciseBreakdown: newBreakdown,
    );
  }

  String getFormattedDate() {
    return '${date.day}/${date.month}/${date.year}';
  }

  double getCompletionPercentage() {
    return workoutsCompleted > 0 ? (workoutsCompleted / 3.0 * 100).clamp(0.0, 100.0) : 0.0;
  }
}
