import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/workout_history.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'fitness_tracker.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE workout_history (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        type TEXT,
        count INTEGER,
        durationSeconds INTEGER,
        date TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE achievements (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT,
        description TEXT,
        isUnlocked INTEGER,
        unlockedAt TEXT
      )
    ''');

    // Insert initial achievements
    await _insertInitialAchievements(db);
  }

  Future _insertInitialAchievements(Database db) async {
    final achievements = [
      ['First Workout', 'Complete your first workout', 0],
      ['Push-up Master', 'Perform 50 push-ups in total', 0],
      ['Early Bird', 'Complete a workout before 8 AM', 0],
      ['Consistency King', 'Workout 3 days in a row', 0],
    ];

    for (var achievement in achievements) {
      await db.insert('achievements', {
        'title': achievement[0],
        'description': achievement[1],
        'isUnlocked': achievement[2],
      });
    }
  }

  Future<int> insertWorkout(WorkoutHistory workout) async {
    Database db = await database;
    return await db.insert('workout_history', workout.toMap());
  }

  Future<List<WorkoutHistory>> getWorkouts() async {
    Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query('workout_history', orderBy: 'date DESC');
    return List.generate(maps.length, (i) => WorkoutHistory.fromMap(maps[i]));
  }

  Future<List<Map<String, dynamic>>> getAchievements() async {
    Database db = await database;
    return await db.query('achievements');
  }

  Future<void> unlockAchievement(String title) async {
    Database db = await database;
    await db.update(
      'achievements',
      {'isUnlocked': 1, 'unlockedAt': DateTime.now().toIso8601String()},
      where: 'title = ? AND isUnlocked = 0',
      whereArgs: [title],
    );
  }
}
