import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:personal_hr/cubits/auth_cubit.dart';
import 'package:personal_hr/cubits/evaluaciones_cubit.dart';
import 'package:personal_hr/models/hr_models.dart';
import 'package:personal_hr/repositories/hr_repository.dart';

class EvaluacionesScreen extends StatefulWidget {
  const EvaluacionesScreen({super.key});

  @override
  State<EvaluacionesScreen> createState() => _EvaluacionesScreenState();
}

class _EvaluacionesScreenState extends State<EvaluacionesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthCubit>().state;
      if (auth.currentUser != null) {
        context.read<EvaluacionesCubit>().loadEvaluaciones(
          currentUser: auth.currentUser!,
          currentEmpleado: auth.currentEmpleado,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final repository = context.read<HrRepository>();
    final authState = context.watch<AuthCubit>().state;
    final user = authState.currentUser;
    final emp = authState.currentEmpleado;

    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Evaluaciones de Desempeño'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      floatingActionButton: user.rol == UserRole.jefe
          ? FloatingActionButton.extended(
              onPressed: () => _showNuevaEvaluacionDialog(context, user, emp),
              icon: const Icon(Icons.rate_review),
              label: const Text('Nueva Evaluación'),
              backgroundColor: Colors.indigo,
              foregroundColor: Colors.white,
            )
          : null,
      body: BlocConsumer<EvaluacionesCubit, EvaluacionesState>(
        listener: (context, state) {
          if (state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage!),
                backgroundColor: Colors.red,
              ),
            );
          }
          if (state.successMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.successMessage!),
                backgroundColor: Colors.green,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state.status == HrStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.status == HrStatus.empty || state.evaluaciones.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.assessment_outlined, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No hay evaluaciones registradas.',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: state.evaluaciones.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final eval = state.evaluaciones[index];
              final empleado = repository.getEmpleadoById(eval.empleadoId);

              return Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            empleado?.nombre ?? 'Empleado ${eval.empleadoId}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.indigo.shade50,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              'Puntaje: ${eval.puntajeTotal} / 5.0',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.indigo,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Fecha: ${eval.fecha.day}/${eval.fecha.month}/${eval.fecha.year}',
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Criterios Evaluados:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      ...eval.criterios.map(
                        (c) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '- ${c.nombre} (Peso ${(c.peso * 100).toInt()}%)',
                              ),
                              Text(
                                '${c.puntaje} / 5.0',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (eval.comentarios != null &&
                          eval.comentarios!.isNotEmpty) ...[
                        const Divider(height: 20),
                        Text(
                          'Observaciones: "${eval.comentarios}"',
                          style: TextStyle(
                            fontStyle: FontStyle.italic,
                            color: Colors.grey[800],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showNuevaEvaluacionDialog(
    BuildContext context,
    Usuario user,
    Empleado? emp,
  ) {
    final team = context.read<HrRepository>().getEmpleadosByJefe(
      user.empresaId,
      user.id,
    );

    if (team.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No tienes empleados asignados en tu equipo.'),
        ),
      );
      return;
    }

    var selectedEmpId = team.first.id;
    var c1Score = 4.0;
    var c2Score = 4.0;
    var c3Score = 4.0;
    final commentController = TextEditingController();

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Nueva Evaluación de Desempeño'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DropdownButtonFormField<String>(
                      initialValue: selectedEmpId,
                      decoration: const InputDecoration(
                        labelText: 'Seleccionar Colaborador',
                      ),
                      items: team
                          .map(
                            (e) => DropdownMenuItem(
                              value: e.id,
                              child: Text(e.nombre),
                            ),
                          )
                          .toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setDialogState(() => selectedEmpId = val);
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Calidad de Trabajo (Peso 40%): ${c1Score.toStringAsFixed(1)}',
                    ),
                    Slider(
                      value: c1Score,
                      min: 1,
                      max: 5,
                      divisions: 8,
                      onChanged: (v) => setDialogState(() => c1Score = v),
                    ),
                    Text(
                      'Trabajo en Equipo (Peso 30%): ${c2Score.toStringAsFixed(1)}',
                    ),
                    Slider(
                      value: c2Score,
                      min: 1,
                      max: 5,
                      divisions: 8,
                      onChanged: (v) => setDialogState(() => c2Score = v),
                    ),
                    Text(
                      'Cumplimiento de Objetivos (Peso 30%): ${c3Score.toStringAsFixed(1)}',
                    ),
                    Slider(
                      value: c3Score,
                      min: 1,
                      max: 5,
                      divisions: 8,
                      onChanged: (v) => setDialogState(() => c3Score = v),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: commentController,
                      decoration: const InputDecoration(
                        labelText: 'Comentarios Adicionales',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 2,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () {
                    final criterios = [
                      CriterioEvaluacion(
                        id: 'c1',
                        nombre: 'Calidad de Trabajo',
                        peso: 0.4,
                        puntaje: c1Score,
                      ),
                      CriterioEvaluacion(
                        id: 'c2',
                        nombre: 'Trabajo en Equipo',
                        peso: 0.3,
                        puntaje: c2Score,
                      ),
                      CriterioEvaluacion(
                        id: 'c3',
                        nombre: 'Cumplimiento de Objetivos',
                        peso: 0.3,
                        puntaje: c3Score,
                      ),
                    ];

                    final success = context
                        .read<EvaluacionesCubit>()
                        .guardarEvaluacion(
                          currentUser: user,
                          currentEmpleado: emp,
                          empleadoId: selectedEmpId,
                          criterios: criterios,
                          comentarios: commentController.text.trim(),
                        );

                    if (success) {
                      Navigator.pop(dialogContext);
                    }
                  },
                  child: const Text('Guardar Evaluación'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
