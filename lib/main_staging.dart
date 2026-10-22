import 'package:personal_hr/app/app.dart';
import 'package:personal_hr/bootstrap.dart';

Future<void> main() async {
  await bootstrap(() => const App());
}
