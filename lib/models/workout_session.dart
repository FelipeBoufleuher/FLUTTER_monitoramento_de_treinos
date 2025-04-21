import 'workout.dart';

class WorkoutSession {
  final int? id;
  final int workoutId;
  final DateTime date;
  final int durationMinutes;
  final List<ExerciseSet> sets;
  final String notes;
  final bool completed;

  WorkoutSession({
    this.id,
    required this.workoutId,
    required this.date,
    required this.durationMinutes,
    required this.sets,
    this.notes = '',
    this.completed = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'workoutId': workoutId,
      'date': date.toIso8601String(),
      'durationMinutes': durationMinutes,
      'notes': notes,
      'completed': completed ? 1 : 0,
    };
  }

  factory WorkoutSession.fromMap(Map<String, dynamic> map, List<ExerciseSet> sets) {
    return WorkoutSession(
      id: map['id'],
      workoutId: map['workoutId'],
      date: DateTime.parse(map['date']),
      durationMinutes: map['durationMinutes'],
      notes: map['notes'],
      completed: map['completed'] == 1,
      sets: sets,
    );
  }

  WorkoutSession copyWith({
    int? id,
    int? workoutId,
    DateTime? date,
    int? durationMinutes,
    List<ExerciseSet>? sets,
    String? notes,
    bool? completed,
  }) {
    return WorkoutSession(
      id: id ?? this.id,
      workoutId: workoutId ?? this.workoutId,
      date: date ?? this.date,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      sets: sets ?? this.sets,
      notes: notes ?? this.notes,
      completed: completed ?? this.completed,
    );
  }
}

class ExerciseSet {
  final int? id;
  final int? sessionId;
  final int exerciseId;
  final int setNumber;
  final int reps;
  final double weight;
  final bool completed;

  ExerciseSet({
    this.id,
    this.sessionId,
    required this.exerciseId,
    required this.setNumber,
    required this.reps,
    required this.weight,
    this.completed = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'sessionId': sessionId,
      'exerciseId': exerciseId,
      'setNumber': setNumber,
      'reps': reps,
      'weight': weight,
      'completed': completed ? 1 : 0,
    };
  }

  factory ExerciseSet.fromMap(Map<String, dynamic> map) {
    return ExerciseSet(
      id: map['id'],
      sessionId: map['sessionId'],
      exerciseId: map['exerciseId'],
      setNumber: map['setNumber'],
      reps: map['reps'],
      weight: map['weight'],
      completed: map['completed'] == 1,
    );
  }

  ExerciseSet copyWith({
    int? id,
    int? sessionId,
    int? exerciseId,
    int? setNumber,
    int? reps,
    double? weight,
    bool? completed,
  }) {
    return ExerciseSet(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      exerciseId: exerciseId ?? this.exerciseId,
      setNumber: setNumber ?? this.setNumber,
      reps: reps ?? this.reps,
      weight: weight ?? this.weight,
      completed: completed ?? this.completed,
    );
  }
}