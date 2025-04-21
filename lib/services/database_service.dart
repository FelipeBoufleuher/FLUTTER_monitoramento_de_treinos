import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:async';
import 'dart:io';

import '../models/workout.dart';
import '../models/workout_session.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  static Database? _database;

  factory DatabaseService() {
    return _instance;
  }

  DatabaseService._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'workout_tracker.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Criar tabela de treinos
    await db.execute('''
      CREATE TABLE workouts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        description TEXT,
        createdAt TEXT NOT NULL
      )
    ''');

    // Criar tabela de exercícios
    await db.execute('''
      CREATE TABLE exercises (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        workoutId INTEGER,
        name TEXT NOT NULL,
        muscle TEXT NOT NULL,
        sets INTEGER NOT NULL,
        reps INTEGER NOT NULL,
        weight REAL NOT NULL,
        FOREIGN KEY (workoutId) REFERENCES workouts (id) ON DELETE CASCADE
      )
    ''');

    // Criar tabela de sessões de treino
    await db.execute('''
      CREATE TABLE workout_sessions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        workoutId INTEGER,
        date TEXT NOT NULL,
        durationMinutes INTEGER NOT NULL,
        notes TEXT,
        completed INTEGER NOT NULL,
        FOREIGN KEY (workoutId) REFERENCES workouts (id) ON DELETE CASCADE
      )
    ''');

    // Criar tabela de sets de exercícios
    await db.execute('''
      CREATE TABLE exercise_sets (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        sessionId INTEGER,
        exerciseId INTEGER,
        setNumber INTEGER NOT NULL,
        reps INTEGER NOT NULL,
        weight REAL NOT NULL,
        completed INTEGER NOT NULL,
        FOREIGN KEY (sessionId) REFERENCES workout_sessions (id) ON DELETE CASCADE,
        FOREIGN KEY (exerciseId) REFERENCES exercises (id) ON DELETE CASCADE
      )
    ''');
  }

  // CRUD para Workouts
  Future<int> insertWorkout(Workout workout) async {
    Database db = await database;
    int workoutId = await db.insert('workouts', workout.toMap());
    
    // Inserir exercícios relacionados
    for (var exercise in workout.exercises) {
      await db.insert('exercises', {
        ...exercise.toMap(),
        'workoutId': workoutId,
      });
    }
    
    return workoutId;
  }

  Future<List<Workout>> getAllWorkouts() async {
    Database db = await database;
    List<Map<String, dynamic>> workoutsMap = await db.query('workouts');
    
    List<Workout> workouts = [];
    for (var workoutMap in workoutsMap) {
      List<Map<String, dynamic>> exercisesMap = await db.query(
        'exercises',
        where: 'workoutId = ?',
        whereArgs: [workoutMap['id']],
      );
      
      List<Exercise> exercises = exercisesMap.map((e) => Exercise.fromMap(e)).toList();
      workouts.add(Workout.fromMap(workoutMap, exercises));
    }
    
    return workouts;
  }

  Future<Workout?> getWorkout(int id) async {
    Database db = await database;
    List<Map<String, dynamic>> workoutsMap = await db.query(
      'workouts',
      where: 'id = ?',
      whereArgs: [id],
    );
    
    if (workoutsMap.isEmpty) return null;
    
    List<Map<String, dynamic>> exercisesMap = await db.query(
      'exercises',
      where: 'workoutId = ?',
      whereArgs: [id],
    );
    
    List<Exercise> exercises = exercisesMap.map((e) => Exercise.fromMap(e)).toList();
    return Workout.fromMap(workoutsMap.first, exercises);
  }

  Future<int> updateWorkout(Workout workout) async {
    Database db = await database;
    
    // Atualizar exercícios
    for (var exercise in workout.exercises) {
      if (exercise.id != null) {
        await db.update(
          'exercises',
          exercise.toMap(),
          where: 'id = ?',
          whereArgs: [exercise.id],
        );
      } else {
        await db.insert('exercises', {
          ...exercise.toMap(),
          'workoutId': workout.id,
        });
      }
    }
    
    return await db.update(
      'workouts',
      workout.toMap(),
      where: 'id = ?',
      whereArgs: [workout.id],
    );
  }

  Future<int> deleteWorkout(int id) async {
    Database db = await database;
    return await db.delete(
      'workouts',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // CRUD para WorkoutSessions
  Future<int> insertSession(WorkoutSession session) async {
    Database db = await database;
    int sessionId = await db.insert('workout_sessions', session.toMap());
    
    // Inserir sets relacionados
    for (var set in session.sets) {
      await db.insert('exercise_sets', {
        ...set.toMap(),
        'sessionId': sessionId,
      });
    }
    
    return sessionId;
  }

  Future<List<WorkoutSession>> getSessionsForWorkout(int workoutId) async {
    Database db = await database;
    List<Map<String, dynamic>> sessionsMap = await db.query(
      'workout_sessions',
      where: 'workoutId = ?',
      whereArgs: [workoutId],
    );
    
    List<WorkoutSession> sessions = [];
    for (var sessionMap in sessionsMap) {
      List<Map<String, dynamic>> setsMap = await db.query(
        'exercise_sets',
        where: 'sessionId = ?',
        whereArgs: [sessionMap['id']],
      );
      
      List<ExerciseSet> sets = setsMap.map((s) => ExerciseSet.fromMap(s)).toList();
      sessions.add(WorkoutSession.fromMap(sessionMap, sets));
    }
    
    return sessions;
  }

  Future<int> updateSession(WorkoutSession session) async {
    Database db = await database;
    
    // Atualizar sets
    for (var set in session.sets) {
      if (set.id != null) {
        await db.update(
          'exercise_sets',
          set.toMap(),
          where: 'id = ?',
          whereArgs: [set.id],
        );
      } else {
        await db.insert('exercise_sets', {
          ...set.toMap(),
          'sessionId': session.id,
        });
      }
    }
    
    return await db.update(
      'workout_sessions',
      session.toMap(),
      where: 'id = ?',
      whereArgs: [session.id],
    );
  }

  Future<int> deleteSession(int id) async {
    Database db = await database;
    return await db.delete(
      'workout_sessions',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}