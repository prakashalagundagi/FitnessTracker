import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/daily_progress.dart';
import '../models/workout.dart';
import '../services/database_service.dart';
import 'dart:ui' as ui;

class ProgressScreen extends StatefulWidget {
  @override
  _ProgressScreenState createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  List<DailyProgress> progressHistory = [];
  List<Workout> recentWorkouts = [];
  Map<String, int> totalStats = {};
  bool isLoading = true;
  String _selectedPeriod = 'week'; // week, month, year

  @override
  void initState() {
    super.initState();
    _loadProgressData();
  }

  Future<void> _loadProgressData() async {
    setState(() {
      isLoading = true;
    });

    try {
      int days = _getDaysForPeriod(_selectedPeriod);
      
      // Load progress history
      final history = await DatabaseService.getProgressHistory(days);
      
      // Load recent workouts
      final workouts = await DatabaseService.getWorkoutsByDateRange(
        DateTime.now().subtract(Duration(days: days)),
        DateTime.now(),
      );
      
      // Load total stats
      final stats = await DatabaseService.getTotalStats();
      
      setState(() {
        progressHistory = history;
        recentWorkouts = workouts;
        totalStats = stats;
        isLoading = false;
      });
    } catch (e) {
      print('Error loading progress data: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  int _getDaysForPeriod(String period) {
    switch (period) {
      case 'week':
        return 7;
      case 'month':
        return 30;
      case 'year':
        return 365;
      default:
        return 7;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Progress'),
        backgroundColor: Color(0xFF4A90E2),
      ),
      body: RefreshIndicator(
        onRefresh: _loadProgressData,
        child: isLoading
            ? Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildPeriodSelector(),
                    SizedBox(height: 20),
                    _buildSummaryCards(),
                    SizedBox(height: 20),
                    _buildProgressChart(),
                    SizedBox(height: 20),
                    _buildExerciseBreakdown(),
                    SizedBox(height: 20),
                    _buildRecentWorkouts(),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildPeriodSelector() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildPeriodButton('week', 'Week'),
          ),
          Expanded(
            child: _buildPeriodButton('month', 'Month'),
          ),
          Expanded(
            child: _buildPeriodButton('year', 'Year'),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodButton(String period, String label) {
    final isSelected = _selectedPeriod == period;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPeriod = period;
        });
        _loadProgressData();
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Color(0xFF4A90E2) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isSelected ? Colors.white : Color(0xFF7F8C8D),
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCards() {
    int totalWorkouts = recentWorkouts.length;
    int totalReps = recentWorkouts.fold(0, (sum, workout) => sum + workout.reps);
    int totalDuration = recentWorkouts.fold(0, (sum, workout) => sum + workout.duration);
    
    return Row(
      children: [
        Expanded(
          child: _buildSummaryCard(
            'Workouts',
            totalWorkouts.toString(),
            Icons.fitness_center,
            Color(0xFF4A90E2),
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: _buildSummaryCard(
            'Total Reps',
            totalReps.toString(),
            Icons.repeat,
            Color(0xFF27AE60),
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: _buildSummaryCard(
            'Duration',
            '${(totalDuration / 60).toStringAsFixed(0)}m',
            Icons.timer,
            Color(0xFFE74C3C),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2C3E50),
            ),
          ),
          SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              color: Color(0xFF7F8C8D),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressChart() {
    if (progressHistory.isEmpty) {
      return Card(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            children: [
              Icon(Icons.show_chart, size: 48, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                'No progress data yet',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
              Text(
                'Start working out to see your progress!',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Progress Chart',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2C3E50),
              ),
            ),
            SizedBox(height: 16),
            Container(
              height: 200,
              child: _buildBarChart(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBarChart() {
    return CustomPaint(
      size: Size.infinite,
      painter: BarChartPainter(progressHistory),
    );
  }

  Widget _buildExerciseBreakdown() {
    if (totalStats.isEmpty) {
      return SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Exercise Breakdown',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2C3E50),
              ),
            ),
            SizedBox(height: 16),
            ...totalStats.entries.map((entry) {
              return _buildExerciseStat(entry.key, entry.value);
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildExerciseStat(String exerciseType, int reps) {
    final displayName = _getExerciseDisplayName(exerciseType);
    final totalReps = totalStats.values.fold(0, (sum, val) => sum + val);
    final percentage = totalReps > 0 ? (reps / totalReps * 100) : 0.0;
    
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                displayName,
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF2C3E50),
                ),
              ),
              Text(
                '$reps reps',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4A90E2),
                ),
              ),
            ],
          ),
          SizedBox(height: 4),
          LinearProgressIndicator(
            value: percentage / 100,
            backgroundColor: Color(0xFFECF0F1),
            valueColor: AlwaysStoppedAnimation<Color>(_getExerciseColor(exerciseType)),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentWorkouts() {
    if (recentWorkouts.isEmpty) {
      return Card(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            children: [
              Icon(Icons.history, size: 48, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                'No recent workouts',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recent Workouts',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2C3E50),
              ),
            ),
            SizedBox(height: 16),
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: recentWorkouts.take(10).length,
              itemBuilder: (context, index) {
                final workout = recentWorkouts[index];
                return _buildWorkoutItem(workout);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWorkoutItem(Workout workout) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Color(0xFFF8F9FA),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _getExerciseColor(workout.exerciseType).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                _getExerciseIcon(workout.exerciseType),
                color: _getExerciseColor(workout.exerciseType),
                size: 20,
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _getExerciseDisplayName(workout.exerciseType),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2C3E50),
                    ),
                  ),
                  Text(
                    DateFormat('MMM dd, yyyy - hh:mm a').format(workout.timestamp),
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF7F8C8D),
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  workout.exerciseType == 'plank' 
                      ? '${workout.duration}s'
                      : '${workout.reps} reps',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF4A90E2),
                  ),
                ),
                if (workout.duration > 0)
                  Text(
                    '${(workout.duration / 60).toStringAsFixed(1)}m',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF7F8C8D),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
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

  Color _getExerciseColor(String exerciseType) {
    switch (exerciseType) {
      case 'pushups':
        return Color(0xFF4A90E2);
      case 'squats':
        return Color(0xFF27AE60);
      case 'situps':
        return Color(0xFFE74C3C);
      case 'plank':
        return Color(0xFFF39C12);
      default:
        return Color(0xFF4A90E2);
    }
  }

  IconData _getExerciseIcon(String exerciseType) {
    switch (exerciseType) {
      case 'pushups':
        return Icons.fitness_center;
      case 'squats':
        return Icons.accessibility_new;
      case 'situps':
        return Icons.self_improvement;
      case 'plank':
        return Icons.sports_gymnastics;
      default:
        return Icons.fitness_center;
    }
  }
}

class BarChartPainter extends CustomPainter {
  final List<DailyProgress> data;
  
  BarChartPainter(this.data);
  
  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;
    
    final paint = Paint()
      ..color = Color(0xFF4A90E2)
      ..style = PaintingStyle.fill;
    
    final textPainter = TextPainter(
      textDirection: ui.TextDirection.ltr,
    );
    
    double maxReps = data.map((d) => d.totalReps.toDouble()).reduce((a, b) => a > b ? a : b);
    if (maxReps == 0) maxReps = 1;
    
    double barWidth = size.width / (data.length * 2);
    double spacing = barWidth;
    
    for (int i = 0; i < data.length; i++) {
      final progress = data[i];
      double barHeight = (progress.totalReps / maxReps) * (size.height - 40);
      double x = i * (barWidth + spacing) + spacing;
      double y = size.height - barHeight - 20;
      
      // Draw bar
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x, y, barWidth, barHeight),
          Radius.circular(4),
        ),
        paint,
      );
      
      // Draw date label
      textPainter.text = TextSpan(
        text: DateFormat('MM/dd').format(progress.date),
        style: TextStyle(
          color: Color(0xFF7F8C8D),
          fontSize: 10,
        ),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(x + (barWidth - textPainter.width) / 2, size.height - 15),
      );
      
      // Draw value label
      if (progress.totalReps > 0) {
        textPainter.text = TextSpan(
          text: progress.totalReps.toString(),
          style: TextStyle(
            color: Color(0xFF2C3E50),
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        );
        textPainter.layout();
        textPainter.paint(
          canvas,
          Offset(x + (barWidth - textPainter.width) / 2, y - 15),
        );
      }
    }
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
