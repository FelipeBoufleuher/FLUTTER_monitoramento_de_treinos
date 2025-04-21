import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../models/workout.dart';
import '../providers/workout_provider.dart';
import '../providers/theme_provider.dart';
import 'workout_form_screen.dart';
import 'workout_detail_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Monitoramento de Exercícios'),
        actions: [
          IconButton(
            icon: Icon(
              themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode,
            ),
            onPressed: () {
              themeProvider.toggleTheme();
            },
            tooltip: 'Alternar tema',
          ),
        ],
      ),
      body: Consumer<WorkoutProvider>(
        builder: (context, workoutProvider, child) {
          if (workoutProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (workoutProvider.workouts.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.fitness_center, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(
                    'Nenhum treino cadastrado',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Adicione seu primeiro treino',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.add),
                    label: const Text('Novo Treino'),
                    onPressed: () => _navigateToWorkoutForm(context),
                  ),
                ],
              ),
            );
          }
          
          return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: workoutProvider.workouts.length,
            itemBuilder: (context, index) {
              final workout = workoutProvider.workouts[index];
              return _buildWorkoutCard(context, workout);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToWorkoutForm(context),
        tooltip: 'Adicionar novo treino',
        child: const Icon(Icons.add),
      ),
    );
  }
  
  Widget _buildWorkoutCard(BuildContext context, Workout workout) {
    final dateFormat = DateFormat('dd/MM/yyyy');
    final exerciseCount = workout.exercises.length;
    
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      child: InkWell(
        onTap: () => _navigateToWorkoutDetail(context, workout),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      workout.name,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  Text(
                    dateFormat.format(workout.createdAt),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                workout.description,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Icon(Icons.fitness_center, size: 16),
                  const SizedBox(width: 4),
                  Text('$exerciseCount exercício${exerciseCount != 1 ? 's' : ''}'),
                  const Spacer(),
                  TextButton.icon(
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Iniciar treino'),
                    onPressed: () => _navigateToWorkoutDetail(context, workout),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  void _navigateToWorkoutForm(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const WorkoutFormScreen()),
    );
  }
  
  void _navigateToWorkoutDetail(BuildContext context, Workout workout) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => WorkoutDetailScreen(workout: workout)),
    );
  }
}