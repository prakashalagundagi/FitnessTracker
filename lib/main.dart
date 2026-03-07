import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:camera/camera.dart';
import 'screens/home_screen.dart';
import 'screens/workout_camera_screen.dart';
import 'screens/progress_screen.dart';
import 'screens/achievements_screen.dart';
import 'screens/workout_history_screen.dart';
import 'services/database_service.dart';
import 'services/voice_coach_service.dart';
import 'services/pose_detector_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize camera
  final cameras = await availableCameras();
  final firstCamera = cameras.first;
  
  // Initialize services
  await VoiceCoachService().initialize();
  await PoseDetectorService().initialize();
  
  runApp(FitnessTrackerApp(camera: firstCamera));
}

class FitnessTrackerApp extends StatelessWidget {
  final CameraDescription camera;
  
  const FitnessTrackerApp({Key? key, required this.camera}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fitness Tracker',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        primaryColor: Color(0xFF4A90E2),
        scaffoldBackgroundColor: Color(0xFFF5F7FA),
        appBarTheme: AppBarTheme(
          backgroundColor: Color(0xFF4A90E2),
          elevation: 0,
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFF4A90E2),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
        ),
        cardTheme: CardThemeData(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      home: MainNavigation(camera: camera),
      routes: {
        '/home': (context) => MainNavigation(camera: camera),
        '/workout': (context) => WorkoutCameraScreen(camera: camera),
        '/progress': (context) => ProgressScreen(),
        '/achievements': (context) => AchievementsScreen(),
        '/history': (context) => WorkoutHistoryScreen(),
      },
    );
  }
}

class MainNavigation extends StatefulWidget {
  final CameraDescription camera;
  
  const MainNavigation({Key? key, required this.camera}) : super(key: key);

  @override
  _MainNavigationState createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;
  
  final List<Widget> _screens = [
    HomeScreen(),
    ProgressScreen(),
    AchievementsScreen(),
    WorkoutHistoryScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: Color(0xFF4A90E2),
          unselectedItemColor: Colors.grey,
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.trending_up),
              label: 'Progress',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.emoji_events),
              label: 'Achievements',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.history),
              label: 'History',
            ),
          ],
        ),
      ),
      floatingActionButton: _currentIndex == 0 ? FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/workout');
        },
        backgroundColor: Color(0xFF4A90E2),
        child: Icon(Icons.fitness_center, color: Colors.white),
      ) : null,
    );
  }
}
