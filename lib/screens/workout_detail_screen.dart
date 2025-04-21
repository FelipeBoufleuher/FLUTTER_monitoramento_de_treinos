import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../models/workout.dart';
import '../models/workout_session.dart';
import '../providers/workout_provider.dart';
import 'workout_form_screen.dart';
import 'workout_session_screen.dart';

class WorkoutDetailScreen extends StatefulWidget {
  final Workout workout;

  const WorkoutDetailScreen({super.key, required this.workout});

  @override
  State<WorkoutDetailScreen> createState() => _WorkoutDetailScreenState();
}

class _WorkoutDetailScreenState extends State<WorkoutDetailScreen> {
  late WorkoutProvider _workoutProvider;
  
  @override
  void initState() {
    super.initState();
    _workoutProvider = Provider.of<WorkoutProvider>(context, listen: false);
    _loadSessions();
  }
  
  Future<void> _loadSessions() async {
    await _workoutProvider.loadSessionsForWorkout(widget.workout.id!);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.workout.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: _editWorkout,
            tooltip: 'Editar treino',
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _confirmDeleteWorkout,
            tooltip: 'Excluir treino',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWorkoutHeader(),
            const SizedBox(height: 16),
            _buildExercisesList(),
            const SizedBox(height: 24),
            _buildSessionsHistory(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _startWorkoutSession,
        label: const Text('Iniciar Treino'),
        icon: const Icon(Icons.play_arrow),
      ),
    );
  }
  
  Widget _buildWorkoutHeader() {
    final dateFormat = DateFormat('dd/MM/yyyy');
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.calendar_today),
              const SizedBox(width: 8),
              Text(
                'Criado em ${dateFormat.format(widget.workout.createdAt)}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            widget.workout.description,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }
  
  Widget _buildExercisesList() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Exercícios',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          ...widget.workout.exercises.asMap().entries.map((entry) {
            int index = entry.key;
            Exercise exercise = entry.value;
            
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: Container(
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
                title: Text(
                  exercise.name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text('${exercise.muscle} | ${exercise.sets} séries x ${exercise.reps} reps | ${exercise.weight} kg'),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
  
  Widget _buildSessionsHistory() {
    return Consumer<WorkoutProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        
        final sessions = provider.sessions;
        
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Histórico de Treinos',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              if (sessions.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(
                    child: Text(
                      'Nenhum treino realizado ainda',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                )
              else
                ...sessions.map((session) => _buildSessionCard(session)).toList(),
            ],
          ),
        );
      },
    );
  }
  
  Widget _buildSessionCard(WorkoutSession session) {
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
    final completedSets = session.sets.where((set) => set.completed).length;
    final totalSets = session.sets.length;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(
          session.completed ? Icons.check_circle : Icons.timelapse,
          color: session.completed ? Colors.green : Colors.orange,
        ),
        title: Text(dateFormat.format(session.date)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Duração: ${session.durationMinutes} minutos'),
            Text('Sets completados: $completedSets/$totalSets'),
            if (session.notes.isNotEmpty)
              Text(
                'Notas: ${session.notes}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.arrow_forward_ios),
          onPressed: () => _viewSessionDetails(session),
        ),
      ),
    );
  }
  
  void _editWorkout() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WorkoutFormScreen(workout: widget.workout),
      ),
    ).then((_) {
      // Recarregar dados após edição
      _workoutProvider.loadWorkouts();
    });
  }
  
  Future<void> _confirmDeleteWorkout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir Treino'),
        content: Text('Tem certeza que deseja excluir "${widget.workout.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
    
    if (confirmed == true && widget.workout.id != null) {
      await _workoutProvider.deleteWorkout(widget.workout.id!);
      if (!mounted) return;
      Navigator.pop(context);
    }
  }
  
  void _startWorkoutSession() {
    if (widget.workout.id == null) return;
    
    // Criar uma nova sessão com base no treino atual
    final List<ExerciseSet> sets = [];
    
    for (var exercise in widget.workout.exercises) {
      for (int i = 0; i < exercise.sets; i++) {
        sets.add(ExerciseSet(
          exerciseId: exercise.id!,
          setNumber: i + 1,
          reps: exercise.reps,
          weight: exercise.weight,
        ));
      }
    }
    
    final session = WorkoutSession(
      workoutId: widget.workout.id!,
      date: DateTime.now(),
      durationMinutes: 0,
      sets: sets,
    );
    
    Navigator.push(
      context, 
      MaterialPageRoute(
        builder: (context) => WorkoutSessionScreen(
          workout: widget.workout,
          session: session,
        ),
      ),
    ).then((_) => _loadSessions());
  }
  
  void _viewSessionDetails(WorkoutSession session) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WorkoutSessionScreen(
          workout: widget.workout,
          session: session,
          readOnly: true,
        ),
      ),
    );
  }
}