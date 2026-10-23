import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:personal_hr/models/hr_models.dart';
import 'package:personal_hr/repositories/hr_repository.dart';

enum HrStatus { initial, loading, success, failure, empty }

class EvaluacionesState {
  const EvaluacionesState({
    this.status = HrStatus.initial,
    this.evaluaciones = const [],
    this.teamMembers = const [],
    this.errorMessage,
    this.successMessage,
  });

  final HrStatus status;
  final List<Evaluacion> evaluaciones;
  final List<Empleado> teamMembers;
  final String? errorMessage;
  final String? successMessage;

  EvaluacionesState copyWith({
    HrStatus? status,
    List<Evaluacion>? evaluaciones,
    List<Empleado>? teamMembers,
    String? errorMessage,
    String? successMessage,
  }) {
    return EvaluacionesState(
      status: status ?? this.status,
      evaluaciones: evaluaciones ?? this.evaluaciones,
      teamMembers: teamMembers ?? this.teamMembers,
      errorMessage: errorMessage,
      successMessage: successMessage,
    );
  }
}

class EvaluacionesCubit extends Cubit<EvaluacionesState> {
  EvaluacionesCubit({required HrRepository repository})
    : _repository = repository,
      super(const EvaluacionesState());

  final HrRepository _repository;

  void loadEvaluaciones({
    required Usuario currentUser,
    required Empleado? currentEmpleado,
  }) {
    emit(state.copyWith(status: HrStatus.loading));
    try {
      var list = <Evaluacion>[];
      var team = <Empleado>[];

      if (currentUser.rol == UserRole.jefe) {
        team = _repository.getEmpleadosByJefe(
          currentUser.empresaId,
          currentUser.id,
        );
        for (final emp in team) {
          list.addAll(
            _repository.getEvaluacionesByEmpleado(
              currentUser.empresaId,
              emp.id,
            ),
          );
        }
      } else if (currentEmpleado != null) {
        list = _repository.getEvaluacionesByEmpleado(
          currentUser.empresaId,
          currentEmpleado.id,
        );
      } else if (currentUser.rol == UserRole.adminRrhh) {
        final allEmps = _repository.getEmpleados(currentUser.empresaId);
        for (final emp in allEmps) {
          list.addAll(
            _repository.getEvaluacionesByEmpleado(
              currentUser.empresaId,
              emp.id,
            ),
          );
        }
      }

      final status = list.isEmpty ? HrStatus.empty : HrStatus.success;
      emit(
        state.copyWith(status: status, evaluaciones: list, teamMembers: team),
      );
    } catch (e) {
      emit(
        state.copyWith(status: HrStatus.failure, errorMessage: e.toString()),
      );
    }
  }

  bool guardarEvaluacion({
    required Usuario currentUser,
    required Empleado? currentEmpleado,
    required String empleadoId,
    required List<CriterioEvaluacion> criterios,
    String? comentarios,
  }) {
    try {
      // Calculate weighted total score
      var total = 0.0;
      for (final c in criterios) {
        total += c.peso * c.puntaje;
      }

      final eval = Evaluacion(
        id: 'eval_${DateTime.now().millisecondsSinceEpoch}',
        empresaId: currentUser.empresaId,
        empleadoId: empleadoId,
        evaluadorId: currentUser.id,
        fecha: DateTime.now(),
        puntajeTotal: double.parse(total.toStringAsFixed(2)),
        criterios: criterios,
        comentarios: comentarios,
      );

      _repository.guardarEvaluacion(eval);
      loadEvaluaciones(
        currentUser: currentUser,
        currentEmpleado: currentEmpleado,
      );

      emit(
        state.copyWith(
          successMessage: 'Evaluación de desempeño guardada correctamente.',
        ),
      );
      return true;
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
      return false;
    }
  }
}
