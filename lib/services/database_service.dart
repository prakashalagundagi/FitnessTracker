import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/workout.dart';
import '../models/achievement.dart';
import '../models/daily_progress.dart';

class DatabaseService {
  static Database? _database;
  static const String _dbName = 'fitness_tracker.db';
  static const int _dbVersion = 1;

  // Table names
  static const String workoutsTable = 'workouts';
  static const String achievementsTable = 'achievements';
  static const String dailyProgressTable = 'daily_progress';

  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  static Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), _dbName);
    
    return await openDatabase(
      path,
      version: _dbVersion,
      onCreate: _onCreate,
    );
  }

  static Future<void> _onCreate(Database db, int version) async {
    // Create workouts table
    await db.execute('''
      CREATE TABLE $workoutsTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        exerciseType TEXT NOT NULL,
        reps INTEGER NOT NULL,
        duration INTEGER NOT NULL,
        timestamp TEXT NOT NULL,
        notes TEXT
      )
    ''');

    // Create achievements table
    await db.execute('''
      CREATE TABLE $achievementsTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        iconName TEXT NOT NULL,
        requiredReps INTEGER NOT NULL,
        exerciseType TEXT NOT NULL,
        isUnlocked INTEGER NOT NULL DEFAULT 0,
        unlockedAt TEXT
      )
    ''');

    // Create daily progress table
    await db.execute('''
      CREATE TABLE $dailyProgressTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT NOT NULL UNIQUE,
        totalReps INTEGER NOT NULL DEFAULT 0,
        totalDuration INTEGER NOT NULL DEFAULT 0,
        workoutsCompleted INTEGER NOT NULL DEFAULT 0,
        exerciseBreakdown TEXT NOT NULL DEFAULT '{}'
      )
    ''');

    // Insert default achievements
    await _insertDefaultAchievements(db);
  }

  static Future<void> _insertDefaultAchievements(Database db) async {
    List<Achievement> defaultAchievements = Achievement.getDefaultAchievements();
    
    for (Achievement achievement in defaultAchievements) {
      await db.insert(
        achievementsTable,
        achievement.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }

  // Workout operations
  static Future<int> insertWorkout(Workout workout) async {
    final db = await database;
    return await db.insert(workoutsTable, workout.toMap());
  }

  static Future<List<Workout>> getAllWorkouts() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      workoutsTable,
      orderBy: 'timestamp DESC',
    );
    
    return List.generate(maps.length, (i) => Workout.fromMap(maps[i]));
  }

  static Future<List<Workout>> getWorkoutsByDateRange(DateTime startDate, DateTime endDate) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      workoutsTable,
      where: 'timestamp BETWEEN ? AND ?',
      whereArgs: [startDate.toIso8601String(), endDate.toIso8601String()],
      orderBy: 'timestamp DESC',
    );
    
    return List.generate(maps.length, (i) => Workout.fromMap(maps[i]));
  }

  static Future<List<Workout>> getWorkoutsByExercise(String exerciseType) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      workoutsTable,
      where: 'exerciseType = ?',
      whereArgs: [exerciseType],
      orderBy: 'timestamp DESC',
    );
    
    return List.generate(maps.length, (i) => Workout.fromMap(maps[i]));
  }

  // Achievement operations
  static Future<List<Achievement>> getAllAchievements() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(achievementsTable);
    
    return List.generate(maps.length, (i) => Achievement.fromMap(maps[i]));
  }

  static Future<int> updateAchievement(Achievement achievement) async {
    final db = await database;
    return await db.update(
      achievementsTable,
      achievement.toMap(),
      where: 'id = ?',
      whereArgs: [achievement.id],
    );
  }

  // Daily progress operations
  static Future<DailyProgress?> getDailyProgress(DateTime date) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      dailyProgressTable,
      where: 'date = ?',
      whereArgs: [date.toIso8601String().split('T')[0]],
    );
    
    if (maps.isNotEmpty) {
      return DailyProgress.fromMap(maps.first);
    }
    return null;
  }

  static Future<int> insertOrUpdateDailyProgress(DailyProgress progress) async {
    final db = await database;
    String dateStr = progress.date.toIso8601String().split('T')[0];
    
    // Check if progress for this date exists
    final existing = await db.query(
      dailyProgressTable,
      where: 'date = ?',
      whereArgs: [dateStr],
    );
    
    if (existing.isNotEmpty) {
      return await db.update(
        dailyProgressTable,
        progress.toMap(),
        where: 'date = ?',
        whereArgs: [dateStr],
      );
    } else {
      return await db.insert(dailyProgressTable, progress.toMap());
    }
  }

  static Future<List<DailyProgress>> getProgressHistory(int days) async {
    final db = await database;
    DateTime endDate = DateTime.now();
    DateTime startDate = endDate.subtract(Duration(days: days - 1));
    
    final List<Map<String, dynamic>> maps = await db.query(
      dailyProgressTable,
      where: 'date BETWEEN ? AND ?',
      whereArgs: [
        startDate.toIso8601String().split('T')[0],
        endDate.toIso8601String().split('T')[0]
      ],
      orderBy: 'date ASC',
    );
    
    return List.generate(maps.length, (i) => DailyProgress.fromMap(maps[i]));
  }

  // Statistics
  static Future<Map<String, int>> getTotalStats() async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT 
        exerciseType,
        SUM(reps) as totalReps,
        COUNT(*) as totalWorkouts
      FROM $workoutsTable
      GROUP BY exerciseType
    ''');
    
    Map<String, int> stats = {};
    for (var row in result) {
      stats[row['exerciseType'] as String] = row['totalReps'] as int;
    }
    
    return stats;
  }

  static Future<List<Achievement>> getAchievements() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(achievementsTable);
    
    if (maps.isEmpty) {
      // Initialize default achievements if none exist
      await _initializeDefaultAchievements();
      final List<Map<String, dynamic>> newMaps = await db.query(achievementsTable);
      return List.generate(newMaps.length, (i) => Achievement.fromMap(newMaps[i]));
    }
    
    return List.generate(maps.length, (i) => Achievement.fromMap(maps[i]));
  }

  static Future<void> _initializeDefaultAchievements() async {
    final db = await database;
    final defaultAchievements = Achievement.getDefaultAchievements();
    
    for (final achievement in defaultAchievements) {
      await db.insert(achievementsTable, achievement.toMap());
    }
  }

  static Future<void> closeDatabase() async {
    final db = await database;
    await db.close();
    _database = null;
  }
}
