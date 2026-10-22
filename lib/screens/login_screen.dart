import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:personal_hr/cubits/auth_cubit.dart';
import 'package:personal_hr/models/hr_models.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1E88E5), Color(0xFF1565C0)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Container(
                constraints: const BoxConstraints(maxWidth: 420),
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.badge_outlined,
                      size: 64,
                      color: Color(0xFF1565C0),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'PersonalHR Demo',
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall
                          ?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF1565C0),
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Selecciona un rol para simular el inicio de sesión:',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[700],
                          ),
                    ),
                    const SizedBox(height: 32),
                    _LoginRoleButton(
                      label: 'Entrar como RRHH',
                      subtitle: 'Vista Administrador (PC / Desktop Dashboard)',
                      icon: Icons.admin_panel_settings,
                      color: Colors.deepPurple,
                      onPressed: () {
                        context.read<AuthCubit>().loginAs(UserRole.adminRrhh);
                        context.go('/dashboard');
                      },
                    ),
                    const SizedBox(height: 16),
                    _LoginRoleButton(
                      label: 'Entrar como Jefe',
                      subtitle: 'Gestión de equipo y aprobaciones',
                      icon: Icons.supervisor_account,
                      color: Colors.indigo,
                      onPressed: () {
                        context.read<AuthCubit>().loginAs(UserRole.jefe);
                        context.go('/solicitudes');
                      },
                    ),
                    const SizedBox(height: 16),
                    _LoginRoleButton(
                      label: 'Entrar como Operativo',
                      subtitle: 'Vista Móvil (Vacaciones, Permisos, Inducción)',
                      icon: Icons.smartphone,
                      color: Colors.teal,
                      onPressed: () {
                        context.read<AuthCubit>().loginAs(UserRole.operativo);
                        context.go('/m-home');
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LoginRoleButton extends StatelessWidget {
  const _LoginRoleButton({
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onPressed,
  });

  final String label;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          backgroundColor: color,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
        onPressed: onPressed,
        child: Row(
          children: [
            Icon(icon, size: 28),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withValues(alpha: 0.85),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16),
          ],
        ),
      ),
    );
  }
}
