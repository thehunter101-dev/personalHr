import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:personal_hr/cubits/auth_cubit.dart';
import 'package:personal_hr/cubits/directory_cubit.dart';
import 'package:personal_hr/cubits/evaluaciones_cubit.dart';
import 'package:personal_hr/cubits/onboarding_cubit.dart';
import 'package:personal_hr/cubits/solicitudes_cubit.dart';
import 'package:personal_hr/l10n/l10n.dart';

import 'package:personal_hr/repositories/hr_repository.dart';
import 'package:personal_hr/screens/dashboard_screen.dart';
import 'package:personal_hr/screens/directory_screen.dart';
import 'package:personal_hr/screens/evaluaciones_screen.dart';
import 'package:personal_hr/screens/login_screen.dart';
import 'package:personal_hr/screens/mobile_home_screen.dart';
import 'package:personal_hr/screens/onboarding_screen.dart';
import 'package:personal_hr/screens/solicitudes_screen.dart';
import 'package:personal_hr/widgets/navigation_layout.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  late final HrRepository _repository;

  @override
  void initState() {
    super.initState();
    _repository = HrRepository();
  }

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider<HrRepository>.value(
      value: _repository,
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthCubit>(
            create: (_) => AuthCubit(repository: _repository),
          ),
          BlocProvider<SolicitudesCubit>(
            create: (_) => SolicitudesCubit(repository: _repository),
          ),
          BlocProvider<EvaluacionesCubit>(
            create: (_) => EvaluacionesCubit(repository: _repository),
          ),
          BlocProvider<DirectoryCubit>(
            create: (_) => DirectoryCubit(repository: _repository),
          ),
          BlocProvider<OnboardingCubit>(
            create: (_) => OnboardingCubit(repository: _repository),
          ),
        ],
        child: const AppView(),
      ),
    );
  }
}

class AppView extends StatefulWidget {
  const AppView({super.key});

  @override
  State<AppView> createState() => _AppViewState();
}

class _AppViewState extends State<AppView> {
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _router = GoRouter(
      initialLocation: '/login',
      routes: [
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginScreen(),
        ),
        ShellRoute(
          builder: (context, state, child) {
            return NavigationLayout(
              currentRoute: state.uri.path,
              child: child,
            );
          },
          routes: [
            GoRoute(
              path: '/dashboard',
              builder: (context, state) => const DashboardScreen(),
            ),
            GoRoute(
              path: '/m-home',
              builder: (context, state) => const MobileHomeScreen(),
            ),
            GoRoute(
              path: '/solicitudes',
              builder: (context, state) => const SolicitudesScreen(),
            ),
            GoRoute(
              path: '/evaluaciones',
              builder: (context, state) => const EvaluacionesScreen(),
            ),
            GoRoute(
              path: '/directorio',
              builder: (context, state) => const DirectoryScreen(),
            ),
            GoRoute(
              path: '/onboarding',
              builder: (context, state) => const OnboardingScreen(),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'PersonalHR',
      theme: ThemeData(
        colorSchemeSeed: Colors.indigo,
        useMaterial3: true,
      ),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: _router,
    );
  }
}
