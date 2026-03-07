import 'package:flutter/material.dart';
import '../models/workout.dart';
import '../utils/constants.dart';

class WorkoutCard extends StatelessWidget {
  final Workout workout;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const WorkoutCard({
    Key? key,
    required this.workout,
    this.onTap,
    this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
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
                      color: ExerciseConstants.colors[workout.exerciseType]?.withOpacity(0.1) ?? AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      ExerciseConstants.icons[workout.exerciseType] ?? Icons.fitness_center,
                      color: ExerciseConstants.colors[workout.exerciseType] ?? AppColors.primary,
                      size: 24,
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          ExerciseConstants.displayNames[workout.exerciseType] ?? workout.exerciseType,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.onSurface,
                          ),
                        ),
                        Text(
                          _formatDate(workout.timestamp),
                          style: TextStyle(
                            color: AppColors.onBackground,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (onDelete != null)
                    PopupMenuButton(
                      icon: Icon(Icons.more_vert),
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete, color: AppColors.error, size: 20),
                              SizedBox(width: 8),
                              Text('Delete'),
                            ],
                          ),
                        ),
                      ],
                      onSelected: (value) {
                        if (value == 'delete') {
                          onDelete!();
                        }
                      },
                    ),
                ],
              ),
              SizedBox(height: 12),
              Row(
                children: [
                  _buildStatItem(
                    workout.exerciseType == 'plank' ? AppStrings.duration : AppStrings.reps,
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
                ],
              ),
            ],
          ),
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
          color: AppColors.onBackground,
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
                color: AppColors.onSurface,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: AppColors.onBackground,
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) {
      return 'Today ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays == 1) {
      return 'Yesterday ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
