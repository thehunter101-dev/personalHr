import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:personal_hr/cubits/auth_cubit.dart';
import 'package:personal_hr/models/hr_models.dart';
import 'package:personal_hr/repositories/hr_repository.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final repository = context.read<HrRepository>();
    final authState = context.watch<AuthCubit>().state;
    final user = authState.currentUser;

    if (user == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final empList = repository.getEmpleados(user.empresaId);
    final solList = repository.getSolicitudes(user.empresaId);

    final pendientes = solList
        .where((s) => s.estado == EstadoSolicitud.pendiente)
        .length;
    final aprobadas = solList
        .where((s) => s.estado == EstadoSolicitud.aprobada)
        .length;
    final totalEmpleados = empList.length;

    final ausenciasSemana = solList
        .where((s) => s.estado == EstadoSolicitud.aprobada)
        .take(5)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Dashboard Global - '
          '${user.empresaId == "emp_1" ? "TechSolutions S.A." : "Logística Global Corp"}',
        ),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        actions: [
          if (user.rol == UserRole.adminRrhh)
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber,
                foregroundColor: Colors.black,
              ),
              icon: const Icon(Icons.restart_alt, size: 18),
              label: const Text('Reset Base Demo'),
              onPressed: () {
                context.read<AuthCubit>().resetDemoData();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content:
                        Text('✅ Datos ficticios restablecidos correctamente.'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
            ),
          const SizedBox(width: 16),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth > 800;
                final cardWidth = isWide
                    ? (constraints.maxWidth - 48) / 3
                    : constraints.maxWidth;
                return Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: [
                    _KpiCard(
                      title: 'Total Empleados',
                      value: '$totalEmpleados',
                      icon: Icons.people,
                      color: Colors.blue,
                      width: cardWidth,
                    ),
                    _KpiCard(
                      title: 'Solicitudes Pendientes',
                      value: '$pendientes',
                      icon: Icons.pending_actions,
                      color: Colors.orange,
                      width: cardWidth,
                    ),
                    _KpiCard(
                      title: 'Aprobadas',
                      value: '$aprobadas',
                      icon: Icons.check_circle,
                      color: Colors.green,
                      width: cardWidth,
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 32),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.calendar_month, color: Colors.indigo),
                        SizedBox(width: 8),
                        Text(
                          'Ausencias Programadas esta Semana (Calendario)',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    if (ausenciasSemana.isEmpty)
                      const Padding(
                        padding: EdgeInsets.all(24),
                        child: Center(
                          child: Text('No hay ausencias para esta semana.'),
                        ),
                      )
                    else
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: ausenciasSemana.length,
                        separatorBuilder: (_, __) => const Divider(),
                        itemBuilder: (context, index) {
                          final sol = ausenciasSemana[index];
                          final emp =
                              repository.getEmpleadoById(sol.empleadoId);
                          return ListTile(
                            leading: const CircleAvatar(
                              backgroundColor: Colors.blueAccent,
                              child: Icon(Icons.person, color: Colors.white),
                            ),
                            title: Text(
                              emp?.nombre ?? 'Empleado ${sol.empleadoId}',
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(
                              'Duración: ${sol.dias} días (${sol.fechaDesde.day}/${sol.fechaDesde.month} - ${sol.fechaHasta.day}/${sol.fechaHasta.month})',
                            ),
                            trailing: Chip(
                              label: Text(
                                sol.tipoId == 'tipo_vac'
                                    ? 'Vacaciones'
                                    : 'Permiso',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                              backgroundColor: sol.tipoId == 'tipo_vac'
                                  ? Colors.teal
                                  : Colors.indigo,
                            ),
                          );
                        },
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _KpiCard extends StatelessWidget {
  const _KpiCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.width,
  });

  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final double width;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: color.withValues(alpha: 0.15),
                child: Icon(icon, color: color, size: 32),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(color: Colors.grey[600], fontSize: 13),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
