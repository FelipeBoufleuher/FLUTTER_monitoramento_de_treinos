class Workout {
  final int? id;
  final String name;
  final String description;
  final DateTime createdAt;
  final List<Exercise> exercises;

  Workout({
    this.id,
    required this.name,
    required this.description,
    required this.createdAt,
    required this.exercises,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Workout.fromMap(Map<String, dynamic> map, List<Exercise> exercises) {
    return Workout(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      createdAt: DateTime.parse(map['createdAt']),
      exercises: exercises,
    );
  }

  Workout copyWith({
    int? id,
    String? name,
    String? description,
    DateTime? createdAt,
    List<Exercise>? exercises,
  }) {
    return Workout(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      exercises: exercises ?? this.exercises,
    );
  }
}

class Exercise {
  final int? id;
  final int? workoutId;
  final String name;
  final String muscle;
  final int sets;
  final int reps;
  final double weight;

  Exercise({
    this.id,
    this.workoutId,
    required this.name,
    required this.muscle,
    required this.sets,
    required this.reps,
    required this.weight,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'workoutId': workoutId,
      'name': name,
      'muscle': muscle,
      'sets': sets,
      'reps': reps,
      'weight': weight,
    };
  }

  factory Exercise.fromMap(Map<String, dynamic> map) {
    return Exercise(
      id: map['id'],
      workoutId: map['workoutId'],
      name: map['name'],
      muscle: map['muscle'],
      sets: map['sets'],
      reps: map['reps'],
      weight: map['weight'],
    );
  }

  Exercise copyWith({
    int? id,
    int? workoutId,
    String? name,
    String? muscle,
    int? sets,
    int? reps,
    double? weight,
  }) {
    return Exercise(
      id: id ?? this.id,
      workoutId: workoutId ?? this.workoutId,
      name: name ?? this.name,
      muscle: muscle ?? this.muscle,
      sets: sets ?? this.sets,
      reps: reps ?? this.reps,
      weight: weight ?? this.weight,
    );
  }
}