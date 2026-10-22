import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:personal_hr/models/hr_models.dart';
import 'package:personal_hr/repositories/hr_repository.dart';

enum SolicitudesStatus { initial, loading, success, failure, empty }

class SolicitudesState {
  const SolicitudesState({
    this.status = SolicitudesStatus.initial,
    this.solicitudes = const [],
    this.tipos = const [],
    this.errorMessage,
    this.notificationMessage,
  });

  final SolicitudesStatus status;
  final List<Solicitud> solicitudes;
  final List<TipoSolicitud> tipos;
  final String? errorMessage;
  final String? notificationMessage;

  SolicitudesState copyWith({
    SolicitudesStatus? status,
    List<Solicitud>? solicitudes,
    List<TipoSolicitud>? tipos,
    String? errorMessage,
    String? notificationMessage,
  }) {
    return SolicitudesState(
      status: status ?? this.status,
      solicitudes: solicitudes ?? this.solicitudes,
      tipos: tipos ?? this.tipos,
      errorMessage: errorMessage,
      notificationMessage: notificationMessage,
    );
  }
}

class SolicitudesCubit extends Cubit<SolicitudesState> {
  SolicitudesCubit({required HrRepository repository})
      : _repository = repository,
        super(const SolicitudesState());

  final HrRepository _repository;

  void loadSolicitudes({
    required Usuario currentUser,
    required Empleado? currentEmpleado,
  }) {
    emit(state.copyWith(status: SolicitudesStatus.loading));
    try {
      final tipos = _repository.getTiposSolicitud();
      List<Solicitud> list;

      switch (currentUser.rol) {
        case UserRole.adminRrhh:
          list = _repository.getSolicitudes(currentUser.empresaId);
        case UserRole.jefe:
          list = _repository.getSolicitudesByJefe(
            currentUser.empresaId,
            currentUser.id,
          );
        case UserRole.operativo:
          if (currentEmpleado != null) {
            list = _repository.getSolicitudesByEmpleado(
              currentUser.empresaId,
              currentEmpleado.id,
            );
          } else {
            list = [];
          }
      }

      final status =
          list.isEmpty ? SolicitudesStatus.empty : SolicitudesStatus.success;
      emit(state.copyWith(status: status, solicitudes: list, tipos: tipos));
    } catch (e) {
      emit(
        state.copyWith(
          status: SolicitudesStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  bool crearSolicitud({
    required Usuario currentUser,
    required Empleado currentEmpleado,
    required String tipoId,
    required DateTime fechaDesde,
    required DateTime fechaHasta,
  }) {
    final error = _repository.crearSolicitud(
      empresaId: currentUser.empresaId,
      empleadoId: currentEmpleado.id,
      tipoId: tipoId,
      fechaDesde: fechaDesde,
      fechaHasta: fechaHasta,
    );

    if (error != null) {
      emit(state.copyWith(errorMessage: error));
      return false;
    }

    // Refresh and trigger notification
    loadSolicitudes(currentUser: currentUser, currentEmpleado: currentEmpleado);
    emit(
      state.copyWith(
        notificationMessage:
            '📲 Simulación WhatsApp/Correo: Tu solicitud fue enviada exitosamente para revisión de tu jefe.',
      ),
    );
    return true;
  }

  bool responderSolicitud({
    required String solicitudId,
    required Usuario currentUser,
    required Empleado? currentEmpleado,
    required EstadoSolicitud nuevoEstado,
    String? comentario,
  }) {
    final error = _repository.responderSolicitud(
      solicitudId: solicitudId,
      aprobadorUsuarioId: currentUser.id,
      nuevoEstado: nuevoEstado,
      comentario: comentario,
    );

    if (error != null) {
      emit(state.copyWith(errorMessage: error));
      return false;
    }

    final estadoStr =
        nuevoEstado == EstadoSolicitud.aprobada ? 'APROBADA' : 'RECHAZADA';

    loadSolicitudes(currentUser: currentUser, currentEmpleado: currentEmpleado);
    emit(
      state.copyWith(
        notificationMessage:
            '📲 Simulación WhatsApp/Correo: La solicitud #$solicitudId cambió a estado "$estadoStr". Comentario: "${comentario ?? 'Sin comentarios'}"',
      ),
    );
    return true;
  }

  void clearNotification() {
    emit(state.copyWith());
  }
}
