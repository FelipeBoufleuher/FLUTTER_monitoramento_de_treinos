import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../models/workout.dart';
import '../models/workout_session.dart';
import '../providers/workout_provider.dart';

class WorkoutSessionScreen extends StatefulWidget {
  final Workout workout;
  final WorkoutSession session;
  final bool readOnly;

  const WorkoutSessionScreen({
    super.key,
    required this.workout,
    required this.session,
    this.readOnly = false,
  });

  @override
  State<WorkoutSessionScreen> createState() => _WorkoutSessionScreenState();
}

class _WorkoutSessionScreenState extends State<WorkoutSessionScreen> {
  late Timer _timer;
  late Duration _elapsed;
  final TextEditingController _notesController = TextEditingController();
  Map<int, Exercise> _exercisesMap = {};
  List<ExerciseSet> _sets = [];
  bool _workoutCompleted = false;

  @override
  void initState() {
    super.initState();
    _notesController.text = widget.session.notes;
    _workoutCompleted = widget.session.completed;
    _sets = List.from(widget.session.sets);
    
    // Criar um mapa de exercícios para fácil consulta
    for (var exercise in widget.workout.exercises) {
      if (exercise.id != null) {
        _exercisesMap[exercise.id!] = exercise;
      }
    }
    
    // Se não for readonly e não estiver completo, iniciar o timer
    if (!widget.readOnly && !_workoutCompleted) {
      _startTimer();
    }
    
    _elapsed = Duration(minutes: widget.session.durationMinutes);
  }
  
  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _elapsed = Duration(seconds: timer.tick + (widget.session.durationMinutes * 60));
      });
    });
  }
  
  @override
  void dispose() {
    if (!widget.readOnly && !_workoutCompleted) {
      _timer.cancel();
    }
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.readOnly ? 'Detalhes do' : 'Sessão de'} Treino'),
        actions: [
          if (!widget.readOnly && !_workoutCompleted)
            TextButton.icon(
              icon: const Icon(Icons.check),
              label: const Text('Finalizar'),
              onPressed: _finishWorkoutSession,
            ),
        ],
      ),
      body: Column(
        children: [
          _buildSessionHeader(),
          Expanded(
            child: _buildSessionExercises(),
          ),
          if (!widget.readOnly) _buildSessionNotes(),
        ],
      ),
    );
  }
  
  Widget _buildSessionHeader() {
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
    final completedSets = _sets.where((set) => set.completed).length;
    final totalSets = _sets.length;
    final progressPercent = totalSets > 0 ? (completedSets / totalSets) : 0.0;
    
    String formatDuration(Duration duration) {
      final hours = duration.inHours.toString().padLeft(2, '0');
      final minutes = (duration.inMinutes % 60).toString().padLeft(2, '0');
      final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
      return '$hours:$minutes:$seconds';
    }
    
    return Container(
      padding: const EdgeInsets.all(16),
      color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.5),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.workout.name,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 4),
                  Text(dateFormat.format(widget.session.date)),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Tempo: ${formatDuration(_elapsed)}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Text(
                    '$completedSets / $totalSets séries',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: progressPercent,
            backgroundColor: Colors.grey[300],
            minHeight: 8,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSessionExercises() {
    // Agrupar os sets por exercício
    Map<int, List<ExerciseSet>> setsByExercise = {};
    
    for (var set in _sets) {
      if (!setsByExercise.containsKey(set.exerciseId)) {
        setsByExercise[set.exerciseId] = [];
      }
      setsByExercise[set.exerciseId]!.add(set);
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: setsByExercise.length,
      itemBuilder: (context, index) {
        final exerciseId = setsByExercise.keys.elementAt(index);
        final exercise = _exercisesMap[exerciseId];
        final exerciseSets = setsByExercise[exerciseId] ?? [];
        
        if (exercise == null) return const SizedBox();
        
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '${index + 1}',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            exercise.name,
                            style: const TextStyle(
                              fontSize: 18, 
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${exercise.muscle} | ${exercise.reps} repetições',
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text(
                        'Série',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        'Reps',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        'Peso (kg)',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                    const Expanded(
                      flex: 1,
                      child: Text(''),
                    ),
                  ],
                ),
              ),
              ...exerciseSets.map((set) => _buildSetRow(set)),
            ],
          ),
        );
      },
    );
  }
  
  Widget _buildSetRow(ExerciseSet set) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text('Série ${set.setNumber}'),
          ),
          Expanded(
            flex: 2,
            child: Text('${set.reps}'),
          ),
          Expanded(
            flex: 2,
            child: Text('${set.weight}'),
          ),
          Expanded(
            flex: 1,
            child: widget.readOnly || _workoutCompleted
                ? Icon(
                    set.completed ? Icons.check_circle : Icons.circle_outlined,
                    color: set.completed ? Colors.green : Colors.grey,
                  )
                : Checkbox(
                    value: set.completed,
                    onChanged: (value) => _toggleSetCompletion(set, value ?? false),
                    activeColor: Colors.green,
                  ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSessionNotes() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: _notesController,
        decoration: const InputDecoration(
          labelText: 'Notas do treino',
          border: OutlineInputBorder(),
          prefixIcon: Icon(Icons.note),
        ),
        maxLines: 2,
      ),
    );
  }
  
  void _toggleSetCompletion(ExerciseSet set, bool completed) {
    setState(() {
      // Encontrar e atualizar o set na lista
      final index = _sets.indexWhere(
        (s) => s.id == set.id || 
            (s.exerciseId == set.exerciseId && s.setNumber == set.setNumber)
      );
      
      if (index >= 0) {
        _sets[index] = set.copyWith(completed: completed);
      }
    });
  }
  
  Future<void> _finishWorkoutSession() async {
    final workoutProvider = Provider.of<WorkoutProvider>(context, listen: false);
    _timer.cancel();
    
    // Calcular duração em minutos
    final durationMinutes = _elapsed.inMinutes;
    
    final updatedSession = widget.session.copyWith(
      durationMinutes: durationMinutes,
      notes: _notesController.text,
      sets: _sets,
      completed: true,
    );
    
    if (updatedSession.id != null) {
      await workoutProvider.updateSession(updatedSession);
    } else {
      await workoutProvider.addSession(updatedSession);
    }
    
    if (!mounted) return;
    
    setState(() {
      _workoutCompleted = true;
    });
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Treino Finalizado'),
        content: Text('Parabéns! Você completou o treino em $durationMinutes minutos.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}