import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import '../models/workout.dart';
import '../models/achievement.dart';
import '../services/database_service.dart';
import '../services/pose_detector_service.dart';
import '../services/voice_coach_service.dart';

class WorkoutCameraScreen extends StatefulWidget {
  final CameraDescription camera;

  const WorkoutCameraScreen({Key? key, required this.camera}) : super(key: key);

  @override
  _WorkoutCameraScreenState createState() => _WorkoutCameraScreenState();
}

class _WorkoutCameraScreenState extends State<WorkoutCameraScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  final PoseDetectorService _poseDetection = PoseDetectorService();
  final VoiceCoachService _voiceCoach = VoiceCoachService();
  
  String _selectedExercise = 'pushups';
  bool _isWorkoutActive = false;
  int _currentCount = 0;
  int _currentDuration = 0;
  String _feedback = 'Ready to start!';
  bool _isGoodForm = true;
  
  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _poseDetection.initialize();
  }

  Future<void> _initializeCamera() async {
    _controller = CameraController(
      widget.camera,
      ResolutionPreset.high,
      enableAudio: false,
    );
    
    _initializeControllerFuture = _controller.initialize();
    setState(() {});
  }

  @override
  void dispose() {
    _controller.dispose();
    _poseDetection.dispose();
    super.dispose();
  }

  void _toggleWorkout() {
    setState(() {
      _isWorkoutActive = !_isWorkoutActive;
      if (_isWorkoutActive) {
        _startWorkout();
      } else {
        _stopWorkout();
      }
    });
  }

  void _startWorkout() {
    _voiceCoach.speak("Starting ${_selectedExercise} workout!");
    _feedback = 'Get ready...';
    _simulateWorkout();
  }

  void _stopWorkout() async {
    _voiceCoach.speak("Workout complete! Great job!");
    
    // Save workout to database
    final workout = Workout(
      exerciseType: _selectedExercise,
      reps: _currentCount,
      duration: _currentDuration,
      timestamp: DateTime.now(),
    );
    
    await DatabaseService.insertWorkout(workout);
    
    // Check for achievements
    await _checkAchievements();
    
    setState(() {
      _feedback = 'Workout saved!';
    });
  }

  void _simulateWorkout() {
    if (!_isWorkoutActive) return;
    
    // Simulate pose detection (since ML Kit is removed)
    Future.delayed(Duration(seconds: 2), () {
      if (_isWorkoutActive) {
        setState(() {
          if (_selectedExercise != 'plank') {
            _currentCount++;
            _feedback = 'Good form! Keep going!';
          } else {
            _currentDuration++;
            _feedback = 'Hold strong!';
          }
        });
        
        // Voice feedback every 5 reps or 30 seconds
        if (_selectedExercise != 'plank' && _currentCount % 5 == 0) {
          _voiceCoach.speak("$_currentCount ${_selectedExercise}! Excellent!");
        } else if (_selectedExercise == 'plank' && _currentDuration % 30 == 0) {
          _voiceCoach.speak("${_currentDuration} seconds! Keep holding!");
        }
        
        _simulateWorkout();
      }
    });
  }

  Future<void> _checkAchievements() async {
    // Check for various achievements
    final achievements = await DatabaseService.getAchievements();
    
    for (final achievement in achievements) {
      if (!achievement.isUnlocked) {
        bool shouldUnlock = false;
        
        switch (achievement.id) {
          case 'first_workout':
            shouldUnlock = true;
            break;
          case 'pushup_10':
            shouldUnlock = _selectedExercise == 'pushups' && _currentCount >= 10;
            break;
          case 'squat_20':
            shouldUnlock = _selectedExercise == 'squats' && _currentCount >= 20;
            break;
          case 'situp_15':
            shouldUnlock = _selectedExercise == 'situps' && _currentCount >= 15;
            break;
          case 'plank_60':
            shouldUnlock = _selectedExercise == 'plank' && _currentDuration >= 60;
            break;
        }
        
        if (shouldUnlock) {
          final updatedAchievement = Achievement(
            id: achievement.id,
            title: achievement.title,
            description: achievement.description,
            iconName: achievement.iconName,
            requiredReps: achievement.requiredReps,
            exerciseType: achievement.exerciseType,
            isUnlocked: true,
            unlockedAt: DateTime.now(),
          );
          
          await DatabaseService.updateAchievement(updatedAchievement);
          _voiceCoach.speak("Achievement unlocked: ${achievement.title}!");
        }
      }
    }
  }

  void _resetWorkout() {
    setState(() {
      _currentCount = 0;
      _currentDuration = 0;
      _feedback = 'Ready to start!';
      _isWorkoutActive = false;
    });
    _poseDetection.resetCount();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('Fitness Tracker'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Column(
              children: [
                // Camera preview
                Expanded(
                  flex: 3,
                  child: Container(
                    width: double.infinity,
                    child: CameraPreview(_controller),
                  ),
                ),
                
                // Exercise selector
                Container(
                  padding: EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildExerciseButton('pushups', 'Push-ups'),
                      _buildExerciseButton('squats', 'Squats'),
                      _buildExerciseButton('situps', 'Sit-ups'),
                      _buildExerciseButton('plank', 'Plank'),
                    ],
                  ),
                ),
                
                // Stats display
                Expanded(
                  flex: 2,
                  child: Container(
                    padding: EdgeInsets.all(20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _selectedExercise.toUpperCase(),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          _selectedExercise == 'plank' 
                              ? '$_currentDuration'
                              : '$_currentCount',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (_selectedExercise == 'plank')
                          Text(
                            'seconds',
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 16,
                            ),
                          ),
                        SizedBox(height: 20),
                        Text(
                          _feedback,
                          style: TextStyle(
                            color: _isGoodForm ? Colors.green : Colors.red,
                            fontSize: 18,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
                
                // Control buttons
                Container(
                  padding: EdgeInsets.all(20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: _toggleWorkout,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _isWorkoutActive ? Colors.red : Colors.green,
                          padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                        ),
                        child: Text(
                          _isWorkoutActive ? 'STOP' : 'START',
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: _resetWorkout,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                        ),
                        child: Text(
                          'RESET',
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }

  Widget _buildExerciseButton(String exercise, String label) {
    return GestureDetector(
      onTap: () {
        if (!_isWorkoutActive) {
          setState(() {
            _selectedExercise = exercise;
            _resetWorkout();
          });
        }
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: _selectedExercise == exercise ? Colors.blue : Colors.grey[700],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
