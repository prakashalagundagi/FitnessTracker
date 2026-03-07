import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/workout.dart';
import '../services/database_service.dart';

class WorkoutHistoryScreen extends StatefulWidget {
  @override
  _WorkoutHistoryScreenState createState() => _WorkoutHistoryScreenState();
}

class _WorkoutHistoryScreenState extends State<WorkoutHistoryScreen> {
  List<Workout> workouts = [];
  List<Workout> filteredWorkouts = [];
  bool isLoading = true;
  String _selectedFilter = 'all';
  String _selectedExercise = 'all';
  DateTime? _startDate;
  DateTime? _endDate;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadWorkouts();
    _searchController.addListener(_filterWorkouts);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadWorkouts() async {
    setState(() {
      isLoading = true;
    });

    try {
      final allWorkouts = await DatabaseService.getAllWorkouts();
      setState(() {
        workouts = allWorkouts;
        filteredWorkouts = allWorkouts;
        isLoading = false;
      });
    } catch (e) {
      print('Error loading workouts: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  void _filterWorkouts() {
    setState(() {
      filteredWorkouts = workouts.where((workout) {
        // Filter by exercise type
        if (_selectedExercise != 'all' && workout.exerciseType != _selectedExercise) {
          return false;
        }

        // Filter by time period
        if (_startDate != null && workout.timestamp.isBefore(_startDate!)) {
          return false;
        }
        if (_endDate != null && workout.timestamp.isAfter(_endDate!)) {
          return false;
        }

        // Filter by search term
        if (_searchController.text.isNotEmpty) {
          final searchLower = _searchController.text.toLowerCase();
          final exerciseName = _getExerciseDisplayName(workout.exerciseType).toLowerCase();
          if (!exerciseName.contains(searchLower)) {
            return false;
          }
        }

        return true;
      }).toList();
    });
  }

  Future<void> _deleteWorkout(Workout workout) async {
    final confirmed = await _showDeleteConfirmation(workout);
    if (confirmed) {
      try {
        // Note: You would need to implement deleteWorkout in DatabaseService
        // await DatabaseService.deleteWorkout(workout.id!);
        await _loadWorkouts();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Workout deleted')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete workout')),
        );
      }
    }
  }

  Future<bool> _showDeleteConfirmation(Workout workout) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Workout'),
        content: Text(
          'Are you sure you want to delete this ${_getExerciseDisplayName(workout.exerciseType)} workout from ${DateFormat('MMM dd, yyyy').format(workout.timestamp)}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Workout History'),
        backgroundColor: Color(0xFF4A90E2),
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadWorkouts,
        child: Column(
          children: [
            _buildSearchBar(),
            _buildFilterChips(),
            Expanded(
              child: isLoading
                  ? Center(child: CircularProgressIndicator())
                  : filteredWorkouts.isEmpty
                      ? _buildEmptyState()
                      : _buildWorkoutList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: EdgeInsets.all(16),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search workouts...',
          prefixIcon: Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.grey[100],
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    if (_selectedFilter == 'all' && _selectedExercise == 'all' && _startDate == null && _endDate == null) {
      return SizedBox.shrink();
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          if (_selectedFilter != 'all')
            _buildFilterChip(_getFilterDisplayName(_selectedFilter), () {
              setState(() {
                _selectedFilter = 'all';
              });
              _filterWorkouts();
            }),
          if (_selectedExercise != 'all')
            _buildFilterChip(_getExerciseDisplayName(_selectedExercise), () {
              setState(() {
                _selectedExercise = 'all';
              });
              _filterWorkouts();
            }),
          if (_startDate != null || _endDate != null)
            _buildFilterChip(_getDateRangeText(), () {
              setState(() {
                _startDate = null;
                _endDate = null;
              });
              _filterWorkouts();
            }),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, VoidCallback onDeleted) {
    return Padding(
      padding: EdgeInsets.only(right: 8),
      child: Chip(
        label: Text(label),
        deleteIcon: Icon(Icons.close, size: 16),
        onDeleted: onDeleted,
        backgroundColor: Color(0xFF4A90E2).withOpacity(0.1),
        labelStyle: TextStyle(color: Color(0xFF4A90E2)),
        deleteIconColor: Color(0xFF4A90E2),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.history,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              workouts.isEmpty ? 'No workouts yet' : 'No workouts found',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 8),
            Text(
              workouts.isEmpty 
                  ? 'Start working out to see your history'
                  : 'Try adjusting your filters',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWorkoutList() {
    return ListView.builder(
      itemCount: filteredWorkouts.length,
      itemBuilder: (context, index) {
        final workout = filteredWorkouts[index];
        return _buildWorkoutCard(workout);
      },
    );
  }

  Widget _buildWorkoutCard(Workout workout) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _getExerciseColor(workout.exerciseType).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getExerciseIcon(workout.exerciseType),
                    color: _getExerciseColor(workout.exerciseType),
                    size: 24,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getExerciseDisplayName(workout.exerciseType),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2C3E50),
                        ),
                      ),
                      Text(
                        DateFormat('EEEE, MMMM dd, yyyy - hh:mm a').format(workout.timestamp),
                        style: TextStyle(
                          color: Color(0xFF7F8C8D),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton(
                  icon: Icon(Icons.more_vert),
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, color: Colors.red, size: 20),
                          SizedBox(width: 8),
                          Text('Delete'),
                        ],
                      ),
                    ),
                  ],
                  onSelected: (value) {
                    if (value == 'delete') {
                      _deleteWorkout(workout);
                    }
                  },
                ),
              ],
            ),
            SizedBox(height: 12),
            Row(
              children: [
                _buildStatItem(
                  workout.exerciseType == 'plank' ? 'Duration' : 'Reps',
                  workout.exerciseType == 'plank' 
                      ? '${workout.duration}s'
                      : '${workout.reps}',
                  Icons.timer,
                ),
                if (workout.duration > 0) ...[
                  SizedBox(width: 24),
                  _buildStatItem(
                    'Total Time',
                    '${(workout.duration / 60).toStringAsFixed(1)}m',
                    Icons.schedule,
                  ),
                ],
                if (workout.notes != null && workout.notes!.isNotEmpty) ...[
                  SizedBox(width: 24),
                  Expanded(
                    child: _buildStatItem(
                      'Notes',
                      workout.notes!,
                      Icons.note,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: Color(0xFF7F8C8D),
        ),
        SizedBox(width: 4),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2C3E50),
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Color(0xFF7F8C8D),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('Filter Workouts'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Time Period',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    _buildDialogFilterChip(
                      'All',
                      _selectedFilter == 'all',
                      () {
                        setDialogState(() {
                          _selectedFilter = 'all';
                        });
                      },
                    ),
                    _buildDialogFilterChip(
                      'Today',
                      _selectedFilter == 'today',
                      () {
                        setDialogState(() {
                          _selectedFilter = 'today';
                        });
                      },
                    ),
                    _buildDialogFilterChip(
                      'This Week',
                      _selectedFilter == 'week',
                      () {
                        setDialogState(() {
                          _selectedFilter = 'week';
                        });
                      },
                    ),
                    _buildDialogFilterChip(
                      'This Month',
                      _selectedFilter == 'month',
                      () {
                        setDialogState(() {
                          _selectedFilter = 'month';
                        });
                      },
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Text(
                  'Exercise Type',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    _buildDialogFilterChip(
                      'All',
                      _selectedExercise == 'all',
                      () {
                        setDialogState(() {
                          _selectedExercise = 'all';
                        });
                      },
                    ),
                    _buildDialogFilterChip(
                      'Push-ups',
                      _selectedExercise == 'pushups',
                      () {
                        setDialogState(() {
                          _selectedExercise = 'pushups';
                        });
                      },
                    ),
                    _buildDialogFilterChip(
                      'Squats',
                      _selectedExercise == 'squats',
                      () {
                        setDialogState(() {
                          _selectedExercise = 'squats';
                        });
                      },
                    ),
                    _buildDialogFilterChip(
                      'Sit-ups',
                      _selectedExercise == 'situps',
                      () {
                        setDialogState(() {
                          _selectedExercise = 'situps';
                        });
                      },
                    ),
                    _buildDialogFilterChip(
                      'Plank',
                      _selectedExercise == 'plank',
                      () {
                        setDialogState(() {
                          _selectedExercise = 'plank';
                        });
                      },
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Text(
                  'Custom Date Range',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: _startDate ?? DateTime.now(),
                            firstDate: DateTime(2020),
                            lastDate: DateTime.now(),
                          );
                          if (date != null) {
                            setDialogState(() {
                              _startDate = date;
                            });
                          }
                        },
                        child: Text(
                          _startDate != null
                              ? DateFormat('MMM dd, yyyy').format(_startDate!)
                              : 'Start Date',
                        ),
                      ),
                    ),
                    Text(' to '),
                    Expanded(
                      child: TextButton(
                        onPressed: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: _endDate ?? DateTime.now(),
                            firstDate: DateTime(2020),
                            lastDate: DateTime.now(),
                          );
                          if (date != null) {
                            setDialogState(() {
                              _endDate = date;
                            });
                          }
                        },
                        child: Text(
                          _endDate != null
                              ? DateFormat('MMM dd, yyyy').format(_endDate!)
                              : 'End Date',
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _applyFilters();
                Navigator.of(context).pop();
              },
              child: Text('Apply'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDialogFilterChip(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? Color(0xFF4A90E2) : Colors.grey[200],
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Color(0xFF2C3E50),
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  void _applyFilters() {
    // Apply time period filter
    if (_selectedFilter != 'all') {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      
      switch (_selectedFilter) {
        case 'today':
          _startDate = today;
          _endDate = today.add(Duration(days: 1));
          break;
        case 'week':
          _startDate = today.subtract(Duration(days: today.weekday - 1));
          _endDate = _startDate!.add(Duration(days: 7));
          break;
        case 'month':
          _startDate = DateTime(now.year, now.month, 1);
          _endDate = DateTime(now.year, now.month + 1, 0);
          break;
      }
    }
    
    _filterWorkouts();
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

  String _getFilterDisplayName(String filter) {
    switch (filter) {
      case 'today':
        return 'Today';
      case 'week':
        return 'This Week';
      case 'month':
        return 'This Month';
      default:
        return filter;
    }
  }

  String _getDateRangeText() {
    if (_startDate != null && _endDate != null) {
      return '${DateFormat('MMM dd').format(_startDate!)} - ${DateFormat('MMM dd').format(_endDate!)}';
    } else if (_startDate != null) {
      return 'From ${DateFormat('MMM dd').format(_startDate!)}';
    } else if (_endDate != null) {
      return 'Until ${DateFormat('MMM dd').format(_endDate!)}';
    }
    return 'Date Range';
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
