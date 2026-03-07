import 'package:flutter/material.dart';
import '../models/achievement.dart';
import '../services/database_service.dart';

class AchievementsScreen extends StatefulWidget {
  @override
  _AchievementsScreenState createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen> {
  List<Achievement> achievements = [];
  bool isLoading = true;
  String _selectedFilter = 'all'; // all, unlocked, locked

  @override
  void initState() {
    super.initState();
    _loadAchievements();
  }

  Future<void> _loadAchievements() async {
    setState(() {
      isLoading = true;
    });

    try {
      final allAchievements = await DatabaseService.getAllAchievements();
      setState(() {
        achievements = allAchievements;
        isLoading = false;
      });
    } catch (e) {
      print('Error loading achievements: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  List<Achievement> get _filteredAchievements {
    switch (_selectedFilter) {
      case 'unlocked':
        return achievements.where((a) => a.isUnlocked).toList();
      case 'locked':
        return achievements.where((a) => !a.isUnlocked).toList();
      default:
        return achievements;
    }
  }

  int get _unlockedCount {
    return achievements.where((a) => a.isUnlocked).length;
  }

  double get _completionPercentage {
    if (achievements.isEmpty) return 0.0;
    return (_unlockedCount / achievements.length) * 100;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Achievements'),
        backgroundColor: Color(0xFF4A90E2),
      ),
      body: RefreshIndicator(
        onRefresh: _loadAchievements,
        child: isLoading
            ? Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildProgressHeader(),
                    SizedBox(height: 20),
                    _buildFilterButtons(),
                    SizedBox(height: 20),
                    _buildAchievementsGrid(),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildProgressHeader() {
    return Container(
      padding: EdgeInsets.all(24),
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
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Achievement Progress',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '$_unlockedCount / ${achievements.length}',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Icon(
                  Icons.emoji_events,
                  color: Colors.white,
                  size: 32,
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          LinearProgressIndicator(
            value: _completionPercentage / 100,
            backgroundColor: Colors.white.withOpacity(0.3),
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
          SizedBox(height: 8),
          Text(
            '${_completionPercentage.toStringAsFixed(1)}% Complete',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterButtons() {
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
            child: _buildFilterButton('all', 'All'),
          ),
          Expanded(
            child: _buildFilterButton('unlocked', 'Unlocked'),
          ),
          Expanded(
            child: _buildFilterButton('locked', 'Locked'),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterButton(String filter, String label) {
    final isSelected = _selectedFilter == filter;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = filter;
        });
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

  Widget _buildAchievementsGrid() {
    final filteredAchievements = _filteredAchievements;
    
    if (filteredAchievements.isEmpty) {
      return Card(
        child: Padding(
          padding: EdgeInsets.all(40),
          child: Column(
            children: [
              Icon(
                _selectedFilter == 'locked' ? Icons.lock : Icons.emoji_events_outlined,
                size: 64,
                color: Colors.grey,
              ),
              SizedBox(height: 16),
              Text(
                _selectedFilter == 'locked' 
                    ? 'No locked achievements'
                    : _selectedFilter == 'unlocked'
                        ? 'No unlocked achievements yet'
                        : 'No achievements available',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey,
                ),
              ),
              SizedBox(height: 8),
              Text(
                _selectedFilter == 'locked'
                    ? 'You\'ve unlocked everything!'
                    : _selectedFilter == 'unlocked'
                        ? 'Start working out to unlock achievements'
                        : 'Complete workouts to earn achievements',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.8,
      ),
      itemCount: filteredAchievements.length,
      itemBuilder: (context, index) {
        final achievement = filteredAchievements[index];
        return _buildAchievementCard(achievement);
      },
    );
  }

  Widget _buildAchievementCard(Achievement achievement) {
    final isUnlocked = achievement.isUnlocked;
    
    return Card(
      elevation: isUnlocked ? 8 : 2,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: isUnlocked
              ? LinearGradient(
                  colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: isUnlocked ? null : Colors.grey[100],
        ),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isUnlocked 
                      ? Colors.white.withOpacity(0.2)
                      : Colors.grey[300],
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Icon(
                  _getIconData(achievement.iconName),
                  color: isUnlocked ? Colors.white : Colors.grey[600],
                  size: 32,
                ),
              ),
              SizedBox(height: 12),
              Text(
                achievement.title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: isUnlocked ? Colors.white : Color(0xFF2C3E50),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 8),
              Text(
                achievement.description,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  color: isUnlocked 
                      ? Colors.white.withOpacity(0.9)
                      : Color(0xFF7F8C8D),
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 8),
              if (!isUnlocked)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _getRequirementText(achievement),
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey[700],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              if (isUnlocked && achievement.unlockedAt != null)
                Text(
                  'Unlocked ${_formatDate(achievement.unlockedAt!)}',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'emoji_events':
        return Icons.emoji_events;
      case 'military_tech':
        return Icons.military_tech;
      case 'workspace_premium':
        return Icons.workspace_premium;
      case 'stars':
        return Icons.stars;
      case 'fitness_center':
        return Icons.fitness_center;
      case 'sports_gymnastics':
        return Icons.sports_gymnastics;
      case 'timer':
        return Icons.timer;
      case 'calendar_today':
        return Icons.calendar_today;
      default:
        return Icons.emoji_events;
    }
  }

  String _getRequirementText(Achievement achievement) {
    if (achievement.exerciseType == 'daily') {
      return '${achievement.requiredReps} days';
    } else if (achievement.exerciseType == 'plank') {
      return '${achievement.requiredReps}s plank';
    } else {
      return '${achievement.requiredReps} reps';
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) {
      return 'today';
    } else if (difference.inDays == 1) {
      return 'yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else if (difference.inDays < 30) {
      return '${(difference.inDays / 7).floor()} weeks ago';
    } else {
      return '${(difference.inDays / 30).floor()} months ago';
    }
  }
}
