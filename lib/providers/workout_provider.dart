import 'package:flutter/material.dart';
import '../models/workout.dart';
import '../models/workout_session.dart';
import '../services/database_service.dart';

class WorkoutProvider extends ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();
  
  List<Workout> _workouts = [];
  List<WorkoutSession> _sessions = [];
  bool _isLoading = false;
  
  List<Workout> get workouts => _workouts;
  List<WorkoutSession> get sessions => _sessions;
  bool get isLoading => _isLoading;
  
  WorkoutProvider() {
    loadWorkouts();
  }
  
  Future<void> loadWorkouts() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      _workouts = await _databaseService.getAllWorkouts();
      notifyListeners();
    } catch (e) {
      debugPrint('Erro ao carregar treinos: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<void> addWorkout(Workout workout) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      await _databaseService.insertWorkout(workout);
      await loadWorkouts();
    } catch (e) {
      debugPrint('Erro ao adicionar treino: $e');
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<void> updateWorkout(Workout workout) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      await _databaseService.updateWorkout(workout);
      await loadWorkouts();
    } catch (e) {
      debugPrint('Erro ao atualizar treino: $e');
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<void> deleteWorkout(int id) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      await _databaseService.deleteWorkout(id);
      await loadWorkouts();
    } catch (e) {
      debugPrint('Erro ao deletar treino: $e');
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<void> loadSessionsForWorkout(int workoutId) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      _sessions = await _databaseService.getSessionsForWorkout(workoutId);
      notifyListeners();
    } catch (e) {
      debugPrint('Erro ao carregar sessões: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<void> addSession(WorkoutSession session) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      await _databaseService.insertSession(session);
      await loadSessionsForWorkout(session.workoutId);
    } catch (e) {
      debugPrint('Erro ao adicionar sessão: $e');
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<void> updateSession(WorkoutSession session) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      await _databaseService.updateSession(session);
      await loadSessionsForWorkout(session.workoutId);
    } catch (e) {
      debugPrint('Erro ao atualizar sessão: $e');
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<void> deleteSession(int id, int workoutId) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      await _databaseService.deleteSession(id);
      await loadSessionsForWorkout(workoutId);
    } catch (e) {
      debugPrint('Erro ao deletar sessão: $e');
      _isLoading = false;
      notifyListeners();
    }
  }
}