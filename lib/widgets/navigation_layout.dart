import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:personal_hr/cubits/auth_cubit.dart';
import 'package:personal_hr/models/hr_models.dart';

class NavigationLayout extends StatelessWidget {
  const NavigationLayout({
    required this.child,
    required this.currentRoute,
    super.key,
  });

  final Widget child;
  final String currentRoute;

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthCubit>().state;
    final user = authState.currentUser;

    if (user == null) {
      return child;
    }

    final isMobile = MediaQuery.of(context).size.width < 768;

    if (isMobile) {
      return Scaffold(
        appBar: AppBar(
          title: Text(user.nombre),
          backgroundColor: Colors.indigo,
          foregroundColor: Colors.white,
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              tooltip: 'Cerrar Sesión',
              onPressed: () {
                context.read<AuthCubit>().logout();
                context.go('/login');
              },
            ),
          ],
        ),
        body: child,
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _getBottomIndex(user.rol, currentRoute),
          onTap: (index) => _onBottomTap(context, user.rol, index),
          selectedItemColor: Colors.indigo,
          unselectedItemColor: Colors.grey,
          type: BottomNavigationBarType.fixed,
          items: _getBottomItems(user.rol),
        ),
      );
    }

    // Desktop Layout with Side Menu Navigation Bar
    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            extended: MediaQuery.of(context).size.width >= 1024,
            backgroundColor: const Color(0xFF1E293B),
            selectedIconTheme: const IconThemeData(color: Colors.white),
            unselectedIconTheme: const IconThemeData(color: Colors.grey),
            selectedLabelTextStyle: const TextStyle(color: Colors.white),
            unselectedLabelTextStyle: const TextStyle(color: Colors.grey),
            leading: Column(
              children: [
                const SizedBox(height: 16),
                const Icon(
                  Icons.badge_outlined,
                  size: 40,
                  color: Colors.blueAccent,
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    user.nombre,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Text(
                  user.rol.label,
                  style: const TextStyle(color: Colors.grey, fontSize: 10),
                ),
                const SizedBox(height: 16),
              ],
            ),
            destinations: _getRailDestinations(user.rol),
            selectedIndex: _getRailIndex(user.rol, currentRoute),
            onDestinationSelected: (index) =>
                _onRailTap(context, user.rol, index),
            trailing: Expanded(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: IconButton(
                    icon: const Icon(Icons.logout, color: Colors.white),
                    tooltip: 'Cerrar Sesión',
                    onPressed: () {
                      context.read<AuthCubit>().logout();
                      context.go('/login');
                    },
                  ),
                ),
              ),
            ),
          ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(child: child),
        ],
      ),
    );
  }

  int _getBottomIndex(UserRole role, String route) {
    if (role == UserRole.operativo) {
      if (route.startsWith('/m-home')) return 0;
      if (route.startsWith('/solicitudes')) return 1;
      if (route.startsWith('/evaluaciones')) return 2;
      if (route.startsWith('/onboarding')) return 3;
    } else {
      if (route.startsWith('/dashboard')) return 0;
      if (route.startsWith('/solicitudes')) return 1;
      if (route.startsWith('/directorio')) return 2;
      if (route.startsWith('/evaluaciones')) return 3;
    }
    return 0;
  }

  List<BottomNavigationBarItem> _getBottomItems(UserRole role) {
    if (role == UserRole.operativo) {
      return const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
        BottomNavigationBarItem(
          icon: Icon(Icons.event_note),
          label: 'Solicitudes',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.assessment),
          label: 'Evaluaciones',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.checklist),
          label: 'Onboarding',
        ),
      ];
    }
    return const [
      BottomNavigationBarItem(
        icon: Icon(Icons.dashboard),
        label: 'Dashboard',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.assignment),
        label: 'Solicitudes',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.people),
        label: 'Directorio',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.assessment),
        label: 'Evaluaciones',
      ),
    ];
  }

  void _onBottomTap(BuildContext context, UserRole role, int index) {
    if (role == UserRole.operativo) {
      switch (index) {
        case 0:
          context.go('/m-home');
        case 1:
          context.go('/solicitudes');
        case 2:
          context.go('/evaluaciones');
        case 3:
          context.go('/onboarding');
      }
    } else {
      switch (index) {
        case 0:
          context.go('/dashboard');
        case 1:
          context.go('/solicitudes');
        case 2:
          context.go('/directorio');
        case 3:
          context.go('/evaluaciones');
      }
    }
  }

  int _getRailIndex(UserRole role, String route) {
    if (route.startsWith('/dashboard')) return 0;
    if (route.startsWith('/solicitudes')) return 1;
    if (route.startsWith('/directorio')) return 2;
    if (route.startsWith('/evaluaciones')) return 3;
    if (route.startsWith('/onboarding')) return 4;
    return 0;
  }

  List<NavigationRailDestination> _getRailDestinations(UserRole role) {
    return const [
      NavigationRailDestination(
        icon: Icon(Icons.dashboard_outlined),
        selectedIcon: Icon(Icons.dashboard),
        label: Text('Dashboard Global'),
      ),
      NavigationRailDestination(
        icon: Icon(Icons.assignment_outlined),
        selectedIcon: Icon(Icons.assignment),
        label: Text('Solicitudes'),
      ),
      NavigationRailDestination(
        icon: Icon(Icons.people_alt_outlined),
        selectedIcon: Icon(Icons.people_alt),
        label: Text('Directorio'),
      ),
      NavigationRailDestination(
        icon: Icon(Icons.analytics_outlined),
        selectedIcon: Icon(Icons.analytics),
        label: Text('Evaluaciones'),
      ),
      NavigationRailDestination(
        icon: Icon(Icons.checklist_outlined),
        selectedIcon: Icon(Icons.checklist),
        label: Text('Onboarding'),
      ),
    ];
  }

  void _onRailTap(BuildContext context, UserRole role, int index) {
    switch (index) {
      case 0:
        context.go('/dashboard');
      case 1:
        context.go('/solicitudes');
      case 2:
        context.go('/directorio');
      case 3:
        context.go('/evaluaciones');
      case 4:
        context.go('/onboarding');
    }
  }
}
