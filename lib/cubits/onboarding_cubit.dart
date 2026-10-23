import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:personal_hr/models/hr_models.dart';
import 'package:personal_hr/repositories/hr_repository.dart';

class OnboardingState {
  const OnboardingState({this.tasks = const [], this.errorMessage});

  final List<OnboardingTask> tasks;
  final String? errorMessage;

  OnboardingState copyWith({
    List<OnboardingTask>? tasks,
    String? errorMessage,
  }) {
    return OnboardingState(
      tasks: tasks ?? this.tasks,
      errorMessage: errorMessage,
    );
  }
}

class OnboardingCubit extends Cubit<OnboardingState> {
  OnboardingCubit({required HrRepository repository})
    : _repository = repository,
      super(const OnboardingState());

  final HrRepository _repository;

  void loadTasks({
    required Usuario currentUser,
    required Empleado? currentEmpleado,
  }) {
    final empId = currentEmpleado?.id ?? 'emp_2';
    final tasks = _repository.getOnboardingTasks(currentUser.empresaId, empId);
    emit(state.copyWith(tasks: tasks));
  }

  void toggleTask(
    String taskId, {
    required Usuario currentUser,
    required Empleado? currentEmpleado,
  }) {
    _repository.toggleTaskStatus(taskId);
    loadTasks(currentUser: currentUser, currentEmpleado: currentEmpleado);
  }
}
