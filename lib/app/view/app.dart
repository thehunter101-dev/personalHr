import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:personal_hr/counter/counter.dart';
import 'package:personal_hr/l10n/l10n.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. MaterialApp DEBE ser el widget raíz devuelto aquí
    return MaterialApp(
      theme: ThemeData(
        appBarTheme: AppBarTheme(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        ),
        useMaterial3: true,
      ),
      // 2. Unimos los delegados de Very Good CLI con los delegados globales de Flutter
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      // 3. El contenido principal (CounterPage) va dentro de 'home'
      // Esto garantiza que CounterPage tenga a MaterialApp como ancestro en el BuildContext
      home: const CounterPage(),
    );
  }
}
