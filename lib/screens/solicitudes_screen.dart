import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:personal_hr/cubits/auth_cubit.dart';
import 'package:personal_hr/cubits/solicitudes_cubit.dart';
import 'package:personal_hr/models/hr_models.dart';
import 'package:personal_hr/repositories/hr_repository.dart';

class SolicitudesScreen extends StatefulWidget {
  const SolicitudesScreen({super.key});

  @override
  State<SolicitudesScreen> createState() => _SolicitudesScreenState();
}

class _SolicitudesScreenState extends State<SolicitudesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthCubit>().state;
      if (auth.currentUser != null) {
        context.read<SolicitudesCubit>().loadSolicitudes(
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
        title: const Text('Gestión de Solicitudes'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      floatingActionButton: user.rol == UserRole.operativo && emp != null
          ? FloatingActionButton.extended(
              onPressed: () => _showNuevaSolicitudDialog(context, user, emp),
              icon: const Icon(Icons.add),
              label: const Text('Nueva Solicitud'),
              backgroundColor: Colors.indigo,
              foregroundColor: Colors.white,
            )
          : null,
      body: BlocConsumer<SolicitudesCubit, SolicitudesState>(
        listener: (context, state) {
          if (state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage!),
                backgroundColor: Colors.red,
              ),
            );
          }
          if (state.notificationMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.notificationMessage!),
                backgroundColor: Colors.indigo,
                duration: const Duration(seconds: 4),
              ),
            );
            context.read<SolicitudesCubit>().clearNotification();
          }
        },
        builder: (context, state) {
          if (state.status == SolicitudesStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.status == SolicitudesStatus.empty ||
              state.solicitudes.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.folder_off, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text(
                    'No hay solicitudes para mostrar.',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  if (user.rol == UserRole.operativo && emp != null) ...[
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () =>
                          _showNuevaSolicitudDialog(context, user, emp),
                      child: const Text('Crear mi primera solicitud'),
                    ),
                  ],
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: state.solicitudes.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final sol = state.solicitudes[index];
              final empleado = repository.getEmpleadoById(sol.empleadoId);

              Color statusColor;
              String statusLabel;
              switch (sol.estado) {
                case EstadoSolicitud.pendiente:
                  statusColor = Colors.orange;
                  statusLabel = 'Pendiente';
                case EstadoSolicitud.aprobada:
                  statusColor = Colors.green;
                  statusLabel = 'Aprobada';
                case EstadoSolicitud.rechazada:
                  statusColor = Colors.red;
                  statusLabel = 'Rechazada';
              }

              final canApprove =
                  user.rol == UserRole.jefe || user.rol == UserRole.adminRrhh;

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
                            empleado?.nombre ?? 'Empleado ${sol.empleadoId}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Chip(
                            label: Text(
                              statusLabel,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                            backgroundColor: statusColor,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text('Cargo: ${empleado?.cargo ?? "N/A"}'),
                      const SizedBox(height: 4),
                      Text(
                        'Fechas: ${sol.fechaDesde.day}/${sol.fechaDesde.month}/${sol.fechaDesde.year} al ${sol.fechaHasta.day}/${sol.fechaHasta.month}/${sol.fechaHasta.year} (${sol.dias} días)',
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      if (sol.comentario != null &&
                          sol.comentario!.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          'Comentario: ${sol.comentario}',
                          style: TextStyle(
                            fontStyle: FontStyle.italic,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                      if (canApprove &&
                          sol.estado == EstadoSolicitud.pendiente) ...[
                        const Divider(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.red,
                              ),
                              icon: const Icon(Icons.close, size: 18),
                              label: const Text('Rechazar'),
                              onPressed: () => _showResponderDialog(
                                context,
                                user,
                                emp,
                                sol,
                                EstadoSolicitud.rechazada,
                              ),
                            ),
                            const SizedBox(width: 12),
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                              ),
                              icon: const Icon(Icons.check, size: 18),
                              label: const Text('Aprobar'),
                              onPressed: () => _showResponderDialog(
                                context,
                                user,
                                emp,
                                sol,
                                EstadoSolicitud.aprobada,
                              ),
                            ),
                          ],
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

  void _showNuevaSolicitudDialog(
    BuildContext context,
    Usuario user,
    Empleado emp,
  ) {
    var selectedTipoId = 'tipo_vac';
    final fechaDesde = DateTime.now().add(const Duration(days: 1));
    final fechaHasta = DateTime.now().add(const Duration(days: 5));

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final diasCalculados =
                fechaHasta.difference(fechaDesde).inDays + 1;

            return AlertDialog(
              title: const Text('Solicitar Permiso / Vacaciones'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Saldo disponible: ${emp.saldoVacaciones} días'),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: selectedTipoId,
                    decoration: const InputDecoration(
                      labelText: 'Tipo de Solicitud',
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'tipo_vac',
                        child: Text('Vacaciones (Descuenta saldo)'),
                      ),
                      DropdownMenuItem(
                        value: 'tipo_med',
                        child: Text('Permiso Médico'),
                      ),
                      DropdownMenuItem(
                        value: 'tipo_per',
                        child: Text('Permiso Personal'),
                      ),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        setDialogState(() => selectedTipoId = val);
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  Text('Días calculados: $diasCalculados'),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () {
                    final success = context
                        .read<SolicitudesCubit>()
                        .crearSolicitud(
                          currentUser: user,
                          currentEmpleado: emp,
                          tipoId: selectedTipoId,
                          fechaDesde: fechaDesde,
                          fechaHasta: fechaHasta,
                        );
                    if (success) {
                      Navigator.pop(dialogContext);
                    }
                  },
                  child: const Text('Enviar Solicitud'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showResponderDialog(
    BuildContext context,
    Usuario user,
    Empleado? emp,
    Solicitud sol,
    EstadoSolicitud nuevoEstado,
  ) {
    final commentController = TextEditingController();

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(
            nuevoEstado == EstadoSolicitud.aprobada
                ? 'Aprobar Solicitud'
                : 'Rechazar Solicitud',
          ),
          content: TextField(
            controller: commentController,
            decoration: const InputDecoration(
              labelText: 'Comentario (opcional)',
              border: OutlineInputBorder(),
            ),
            maxLines: 2,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: nuevoEstado == EstadoSolicitud.aprobada
                    ? Colors.green
                    : Colors.red,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                final success = context
                    .read<SolicitudesCubit>()
                    .responderSolicitud(
                      solicitudId: sol.id,
                      currentUser: user,
                      currentEmpleado: emp,
                      nuevoEstado: nuevoEstado,
                      comentario: commentController.text.trim(),
                    );
                if (success) {
                  Navigator.pop(dialogContext);
                }
              },
              child: Text(
                nuevoEstado == EstadoSolicitud.aprobada
                    ? 'Confirmar Aprobación'
                    : 'Confirmar Rechazo',
              ),
            ),
          ],
        );
      },
    );
  }
}
