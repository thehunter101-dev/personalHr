// Ignore for testing purposes
// ignore_for_file: prefer_const_constructors

import 'package:flutter_test/flutter_test.dart';
import 'package:personal_hr/app/app.dart';
import 'package:personal_hr/screens/login_screen.dart';

void main() {
  group('App', () {
    testWidgets('renders LoginScreen', (tester) async {
      await tester.pumpWidget(App());
      expect(find.byType(LoginScreen), findsOneWidget);
    });
  });
}
