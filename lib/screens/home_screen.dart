import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import '../models/workout.dart';
import '../models/daily_progress.dart';
import '../services/database_service.dart';
import '../services/voice_coach_service.dart';
import 'workout_camera_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  DailyProgress? todayProgress;
  Map<String, int> totalStats = {};
  bool isLoading = true;
  int streak = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final today = DateTime.now();
      final todayStart = DateTime(today.year, today.month, today.day);
      final todayEnd = todayStart.add(Duration(days: 1));
      
      // Initialize default data
      final defaultProgress = DailyProgress(date: todayStart);
      
      // Get today's progress
      DailyProgress? progress;
      Map<String, int> stats = {};
      List<Workout> workouts = [];
      
      try {
        progress = await DatabaseService.getDailyProgress(todayStart);
      } catch (e) {
        print('Error getting daily progress: $e');
      }
      
      try {
        stats = await DatabaseService.getTotalStats();
      } catch (e) {
        print('Error getting total stats: $e');
      }
      
      try {
        workouts = await DatabaseService.getWorkoutsByDateRange(
          todayStart.subtract(Duration(days: 30)),
          todayEnd,
        );
      } catch (e) {
        print('Error getting workouts: $e');
      }
      
      // Calculate streak
      int currentStreak = _calculateStreak(workouts);
      
      setState(() {
        todayProgress = progress ?? defaultProgress;
        totalStats = stats;
        streak = currentStreak;
        isLoading = false;
      });
    } catch (e) {
      print('Error loading home data: $e');
      setState(() {
        todayProgress = DailyProgress(date: DateTime.now());
        totalStats = {};
        streak = 0;
        isLoading = false;
      });
    }
  }

  int _calculateStreak(List<Workout> workouts) {
    if (workouts.isEmpty) return 0;
    
    final today = DateTime.now();
    final todayStart = DateTime(today.year, today.month, today.day);
    
    // Check if there's a workout today
    bool hasWorkoutToday = workouts.any((w) => 
      w.timestamp.isAfter(todayStart) && w.timestamp.isBefore(todayStart.add(Duration(days: 1)))
    );
    
    if (!hasWorkoutToday) {
      // Check if there was a workout yesterday
      final yesterday = todayStart.subtract(Duration(days: 1));
      bool hasWorkoutYesterday = workouts.any((w) => 
        w.timestamp.isAfter(yesterday) && w.timestamp.isBefore(todayStart)
      );
      
      if (!hasWorkoutYesterday) return 0;
    }
    
    // Calculate consecutive days with workouts
    int streak = 0;
    DateTime checkDate = hasWorkoutToday ? todayStart : todayStart.subtract(Duration(days: 1));
    
    while (true) {
      bool hasWorkoutOnDate = workouts.any((w) => 
        w.timestamp.year == checkDate.year &&
        w.timestamp.month == checkDate.month &&
        w.timestamp.day == checkDate.day
      );
      
      if (hasWorkoutOnDate) {
        streak++;
        checkDate = checkDate.subtract(Duration(days: 1));
      } else {
        break;
      }
    }
    
    return streak;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: isLoading
            ? Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),
                    SizedBox(height: 24),
                    _buildStreakCard(),
                    SizedBox(height: 16),
                    _buildTodayProgressCard(),
                    SizedBox(height: 16),
                    _buildQuickStats(),
                    SizedBox(height: 16),
                    _buildQuickActions(),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Color(0xFF4A90E2),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                Icons.fitness_center,
                color: Colors.white,
                size: 30,
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome back!',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2C3E50),
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Ready to crush your fitness goals?',
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFF7F8C8D),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStreakCard() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF667EEA).withOpacity(0.3),
            blurRadius: 15,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Current Streak',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 14,
                ),
              ),
              SizedBox(height: 4),
              Text(
                '$streak days',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Icon(
            Icons.local_fire_department,
            color: Colors.white,
            size: 40,
          ),
        ],
      ),
    );
  }

  Widget _buildTodayProgressCard() {
    if (todayProgress == null) {
      return Card(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Text('Loading progress...'),
        ),
      );
    }
    
    return Card(
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Today\'s Progress',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C3E50),
                  ),
                ),
                Text(
                  todayProgress!.getFormattedDate(),
                  style: TextStyle(
                    color: Color(0xFF7F8C8D),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    'Workouts',
                    todayProgress!.workoutsCompleted.toString(),
                    Icons.fitness_center,
                    Color(0xFF4A90E2),
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    'Total Reps',
                    todayProgress!.totalReps.toString(),
                    Icons.repeat,
                    Color(0xFF27AE60),
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    'Duration',
                    '${(todayProgress!.totalDuration / 60).toStringAsFixed(1)}m',
                    Icons.timer,
                    Color(0xFFE74C3C),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            LinearProgressIndicator(
              value: todayProgress!.getCompletionPercentage() / 100,
              backgroundColor: Color(0xFFECF0F1),
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4A90E2)),
            ),
            SizedBox(height: 8),
            Text(
              '${todayProgress!.getCompletionPercentage().toStringAsFixed(0)}% of daily goal',
              style: TextStyle(
                color: Color(0xFF7F8C8D),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2C3E50),
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Color(0xFF7F8C8D),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickStats() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'All-Time Stats',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2C3E50),
              ),
            ),
            SizedBox(height: 16),
            if (totalStats.isEmpty)
              Text(
                'No workouts yet. Start your fitness journey!',
                style: TextStyle(
                  color: Color(0xFF7F8C8D),
                  fontStyle: FontStyle.italic,
                ),
              )
            else
              Column(
                children: totalStats.entries.map((entry) {
                  String displayName = _getExerciseDisplayName(entry.key);
                  return Padding(
                    padding: EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          displayName,
                          style: TextStyle(
                            color: Color(0xFF2C3E50),
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          '${entry.value} reps',
                          style: TextStyle(
                            color: Color(0xFF4A90E2),
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Workouts',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2C3E50),
          ),
        ),
        SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.2,
          children: [
            _buildWorkoutCard(
              'Push-ups',
              'fitness_center',
              Color(0xFF4A90E2),
              ExerciseType.pushups,
            ),
            _buildWorkoutCard(
              'Squats',
              'accessibility_new',
              Color(0xFF27AE60),
              ExerciseType.squats,
            ),
            _buildWorkoutCard(
              'Sit-ups',
              'self_improvement',
              Color(0xFFE74C3C),
              ExerciseType.situps,
            ),
            _buildWorkoutCard(
              'Plank',
              'sports_gymnastics',
              Color(0xFFF39C12),
              ExerciseType.plank,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildWorkoutCard(String title, String iconName, Color color, ExerciseType exerciseType) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          '/workout',
          arguments: {'exerciseType': exerciseType},
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _getIconData(iconName),
              color: color,
              size: 32,
            ),
            SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                color: Color(0xFF2C3E50),
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'fitness_center':
        return Icons.fitness_center;
      case 'accessibility_new':
        return Icons.accessibility_new;
      case 'self_improvement':
        return Icons.self_improvement;
      case 'sports_gymnastics':
        return Icons.sports_gymnastics;
      default:
        return Icons.fitness_center;
    }
  }

  String _getExerciseDisplayName(String exerciseType) {
    switch (exerciseType) {
      case 'pushups':
        return 'Push-ups';
      case 'squats':
        return 'Squats';
      case 'situps':
        return 'Sit-ups';
      case 'plank':
        return 'Plank';
      default:
        return exerciseType;
    }
  }
}
