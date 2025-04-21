import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/workout.dart';
import '../providers/workout_provider.dart';

class WorkoutFormScreen extends StatefulWidget {
  final Workout? workout;
  
  const WorkoutFormScreen({super.key, this.workout});

  @override
  State<WorkoutFormScreen> createState() => _WorkoutFormScreenState();
}

class _WorkoutFormScreenState extends State<WorkoutFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  List<ExerciseFormData> _exercises = [];
  
  @override
  void initState() {
    super.initState();
    
    // Se estiver editando, preenche os campos com os dados do treino
    if (widget.workout != null) {
      _nameController.text = widget.workout!.name;
      _descriptionController.text = widget.workout!.description;
      _exercises = widget.workout!.exercises.map((exercise) => 
        ExerciseFormData(
          id: exercise.id,
          nameController: TextEditingController(text: exercise.name),
          muscleController: TextEditingController(text: exercise.muscle),
          setsController: TextEditingController(text: exercise.sets.toString()),
          repsController: TextEditingController(text: exercise.reps.toString()),
          weightController: TextEditingController(text: exercise.weight.toString()),
        )
      ).toList();
    }
    
    // Se não houver exercício, adiciona um exercício vazio
    if (_exercises.isEmpty) {
      _addEmptyExercise();
    }
  }
  
  void _addEmptyExercise() {
    setState(() {
      _exercises.add(ExerciseFormData(
        nameController: TextEditingController(),
        muscleController: TextEditingController(),
        setsController: TextEditingController(text: '3'),
        repsController: TextEditingController(text: '12'),
        weightController: TextEditingController(text: '0'),
      ));
    });
  }
  
  void _removeExercise(int index) {
    setState(() {
      _exercises.removeAt(index);
    });
  }
  
  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    
    for (var exercise in _exercises) {
      exercise.dispose();
    }
    
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.workout == null ? 'Novo Treino' : 'Editar Treino'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nome do treino',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.fitness_center),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor, informe o nome do treino';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Descrição',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.description),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Exercícios',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  onPressed: _addEmptyExercise,
                  icon: const Icon(Icons.add_circle),
                  tooltip: 'Adicionar exercício',
                ),
              ],
            ),
            const SizedBox(height: 8),
            ..._buildExerciseForms(),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ElevatedButton(
            onPressed: _saveWorkout,
            child: const Text('Salvar Treino'),
          ),
        ),
      ),
    );
  }
  
  List<Widget> _buildExerciseForms() {
    return _exercises.asMap().entries.map((entry) {
      int index = entry.key;
      ExerciseFormData exercise = entry.value;
      
      return Card(
        margin: const EdgeInsets.only(bottom: 16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Exercício ${index + 1}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  if (_exercises.length > 1)
                    IconButton(
                      onPressed: () => _removeExercise(index),
                      icon: const Icon(Icons.delete, color: Colors.red),
                      tooltip: 'Remover exercício',
                    ),
                ],
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: exercise.nameController,
                decoration: const InputDecoration(
                  labelText: 'Nome do exercício',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Informe o nome do exercício';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: exercise.muscleController,
                decoration: const InputDecoration(
                  labelText: 'Grupo muscular',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Informe o grupo muscular';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: exercise.setsController,
                      decoration: const InputDecoration(
                        labelText: 'Séries',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Informe o número de séries';
                        }
                        if (int.tryParse(value) == null) {
                          return 'Digite um número válido';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      controller: exercise.repsController,
                      decoration: const InputDecoration(
                        labelText: 'Repetições',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Informe o número de repetições';
                        }
                        if (int.tryParse(value) == null) {
                          return 'Digite um número válido';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      controller: exercise.weightController,
                      decoration: const InputDecoration(
                        labelText: 'Peso (kg)',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Informe o peso';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Digite um número válido';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }).toList();
  }
  
  Future<void> _saveWorkout() async {
    if (_formKey.currentState!.validate()) {
      final workoutProvider = Provider.of<WorkoutProvider>(context, listen: false);
      
      // Converter exercícios do formulário para o modelo
      final exercises = _exercises.map((e) => Exercise(
        id: e.id,
        workoutId: widget.workout?.id,
        name: e.nameController.text,
        muscle: e.muscleController.text,
        sets: int.parse(e.setsController.text),
        reps: int.parse(e.repsController.text),
        weight: double.parse(e.weightController.text),
      )).toList();
      
      if (widget.workout == null) {
        // Criar novo treino
        final newWorkout = Workout(
          name: _nameController.text,
          description: _descriptionController.text,
          createdAt: DateTime.now(),
          exercises: exercises,
        );
        
        await workoutProvider.addWorkout(newWorkout);
      } else {
        // Atualizar treino existente
        final updatedWorkout = widget.workout!.copyWith(
          name: _nameController.text,
          description: _descriptionController.text,
          exercises: exercises,
        );
        
        await workoutProvider.updateWorkout(updatedWorkout);
      }
      
      if (!mounted) return;
      Navigator.pop(context);
    }
  }
}

class ExerciseFormData {
  final int? id;
  final TextEditingController nameController;
  final TextEditingController muscleController;
  final TextEditingController setsController;
  final TextEditingController repsController;
  final TextEditingController weightController;
  
  ExerciseFormData({
    this.id,
    required this.nameController,
    required this.muscleController,
    required this.setsController,
    required this.repsController,
    required this.weightController,
  });
  
  void dispose() {
    nameController.dispose();
    muscleController.dispose();
    setsController.dispose();
    repsController.dispose();
    weightController.dispose();
  }
}