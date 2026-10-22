import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:personal_hr/cubits/auth_cubit.dart';
import 'package:personal_hr/cubits/directory_cubit.dart';

class DirectoryScreen extends StatefulWidget {
  const DirectoryScreen({super.key});

  @override
  State<DirectoryScreen> createState() => _DirectoryScreenState();
}

class _DirectoryScreenState extends State<DirectoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthCubit>().state;
      if (auth.currentUser != null) {
        context.read<DirectoryCubit>().loadDirectory(auth.currentUser!.empresaId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final df = DateFormat('dd/MM/yyyy');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Directorio de Colaboradores'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: BlocBuilder<DirectoryCubit, DirectoryState>(
        builder: (context, state) {
          final list = state.filteredEmpleados;

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  decoration: const InputDecoration(
                    labelText: 'Buscar por nombre o cargo...',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (val) => context.read<DirectoryCubit>().search(val),
                ),
              ),
              Expanded(
                child: list.isEmpty
                    ? const Center(
                        child: Text(
                          'No se encontraron empleados.',
                          style: TextStyle(color: Colors.grey),
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: list.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final emp = list[index];
                          return Card(
                            elevation: 1,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Colors.indigo,
                                child: Text(
                                  emp.nombre.substring(0, 1),
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                              title: Text(
                                emp.nombre,
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text(
                                '${emp.cargo} • Fecha Ingreso: ${df.format(emp.fechaIngreso)}',
                              ),
                              trailing: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.green.shade100,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '${emp.saldoVacaciones} días',
                                  style: const TextStyle(
                                    color: Colors.green,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}
