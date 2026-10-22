import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:personal_hr/models/hr_models.dart';
import 'package:personal_hr/repositories/hr_repository.dart';

class AuthState {
  const AuthState({
    this.currentUser,
    this.currentEmpleado,
  });

  final Usuario? currentUser;
  final Empleado? currentEmpleado;

  bool get isAuthenticated => currentUser != null;

  AuthState copyWith({
    Usuario? currentUser,
    Empleado? currentEmpleado,
  }) {
    return AuthState(
      currentUser: currentUser ?? this.currentUser,
      currentEmpleado: currentEmpleado ?? this.currentEmpleado,
    );
  }
}

class AuthCubit extends Cubit<AuthState> {
  AuthCubit({required HrRepository repository})
      : _repository = repository,
        super(const AuthState());

  final HrRepository _repository;

  void loginAs(UserRole role) {
    final users = _repository.getUsuariosByEmpresa('emp_1');
    final user = users.firstWhere(
      (u) => u.rol == role,
      orElse: () => users.first,
    );

    final empleado = _repository.getEmpleadoByUsuarioId(user.id);
    emit(AuthState(currentUser: user, currentEmpleado: empleado));
  }

  void logout() {
    emit(const AuthState());
  }

  void resetDemoData() {
    _repository.seedData();
    if (state.currentUser != null) {
      final updatedEmpleado =
          _repository.getEmpleadoByUsuarioId(state.currentUser!.id);
      emit(state.copyWith(currentEmpleado: updatedEmpleado));
    }
  }
}
