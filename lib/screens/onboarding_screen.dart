import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:personal_hr/cubits/auth_cubit.dart';
import 'package:personal_hr/cubits/onboarding_cubit.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthCubit>().state;
      if (auth.currentUser != null) {
        context.read<OnboardingCubit>().loadTasks(
              currentUser: auth.currentUser!,
              currentEmpleado: auth.currentEmpleado,
            );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthCubit>().state;
    final user = authState.currentUser;
    final emp = authState.currentEmpleado;

    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Checklist de Onboarding'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: BlocBuilder<OnboardingCubit, OnboardingState>(
        builder: (context, state) {
          final tasks = state.tasks;
          final completed = tasks.where((t) => t.completada).length;
          final total = tasks.length;
          final progress = total > 0 ? completed / total : 0.0;

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  color: Colors.indigo.shade50,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Bienvenido/a, ${emp?.nombre ?? user.nombre}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.indigo,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Progreso de tu inducción: $completed de $total tareas completadas (${(progress * 100).toInt()}%)',
                        ),
                        const SizedBox(height: 12),
                        LinearProgressIndicator(
                          value: progress,
                          backgroundColor: Colors.indigo.shade100,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            Colors.indigo,
                          ),
                          minHeight: 8,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Tareas Asignadas:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: tasks.isEmpty
                      ? const Center(
                          child: Text(
                            'No hay tareas de onboarding pendientes.',
                            style: TextStyle(color: Colors.grey),
                          ),
                        )
                      : ListView.separated(
                          itemCount: tasks.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            final task = tasks[index];
                            return Card(
                              elevation: 1,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: CheckboxListTile(
                                title: Text(
                                  task.titulo,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    decoration: task.completada
                                        ? TextDecoration.lineThrough
                                        : null,
                                  ),
                                ),
                                subtitle: Text(task.descripcion),
                                value: task.completada,
                                activeColor: Colors.indigo,
                                onChanged: (_) {
                                  context.read<OnboardingCubit>().toggleTask(
                                        task.id,
                                        currentUser: user,
                                        currentEmpleado: emp,
                                      );
                                },
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
