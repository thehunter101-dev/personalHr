enum UserRole { adminRrhh, jefe, operativo }

extension UserRoleX on UserRole {
  String get label {
    switch (this) {
      case UserRole.adminRrhh:
        return 'Administrador RRHH';
      case UserRole.jefe:
        return 'Jefe / Supervisor';
      case UserRole.operativo:
        return 'Empleado Operativo';
    }
  }
}

class Empresa {
  const Empresa({required this.id, required this.nombre, required this.ciudad});

  factory Empresa.fromJson(Map<String, dynamic> json) => Empresa(
    id: json['id'] as String,
    nombre: json['nombre'] as String,
    ciudad: json['ciudad'] as String,
  );

  final String id;
  final String nombre;
  final String ciudad;

  Map<String, dynamic> toJson() => {
    'id': id,
    'nombre': nombre,
    'ciudad': ciudad,
  };
}

class Usuario {
  const Usuario({
    required this.id,
    required this.empresaId,
    required this.nombre,
    required this.correo,
    required this.rol,
  });

  factory Usuario.fromJson(Map<String, dynamic> json) => Usuario(
    id: json['id'] as String,
    empresaId: json['empresaId'] as String,
    nombre: json['nombre'] as String,
    correo: json['correo'] as String,
    rol: UserRole.values.firstWhere((e) => e.name == json['rol']),
  );

  final String id;
  final String empresaId;
  final String nombre;
  final String correo;
  final UserRole rol;

  Map<String, dynamic> toJson() => {
    'id': id,
    'empresaId': empresaId,
    'nombre': nombre,
    'correo': correo,
    'rol': rol.name,
  };
}

class Departamento {
  const Departamento({
    required this.id,
    required this.empresaId,
    required this.nombre,
    required this.jefeId,
  });

  final String id;
  final String empresaId;
  final String nombre;
  final String jefeId;
}

class Empleado {
  const Empleado({
    required this.id,
    required this.empresaId,
    required this.usuarioId,
    required this.nombre,
    required this.cargo,
    required this.departamentoId,
    required this.fechaIngreso,
    required this.saldoVacaciones,
    this.jefeId,
  });

  final String id;
  final String empresaId;
  final String usuarioId;
  final String nombre;
  final String cargo;
  final String departamentoId;
  final String? jefeId;
  final DateTime fechaIngreso;
  final int saldoVacaciones;

  Empleado copyWith({
    String? id,
    String? empresaId,
    String? usuarioId,
    String? nombre,
    String? cargo,
    String? departamentoId,
    String? jefeId,
    DateTime? fechaIngreso,
    int? saldoVacaciones,
  }) {
    return Empleado(
      id: id ?? this.id,
      empresaId: empresaId ?? this.empresaId,
      usuarioId: usuarioId ?? this.usuarioId,
      nombre: nombre ?? this.nombre,
      cargo: cargo ?? this.cargo,
      departamentoId: departamentoId ?? this.departamentoId,
      jefeId: jefeId ?? this.jefeId,
      fechaIngreso: fechaIngreso ?? this.fechaIngreso,
      saldoVacaciones: saldoVacaciones ?? this.saldoVacaciones,
    );
  }
}

class TipoSolicitud {
  const TipoSolicitud({
    required this.id,
    required this.nombre,
    required this.descuentaSaldo,
  });

  final String id;
  final String nombre;
  final bool descuentaSaldo;
}

enum EstadoSolicitud { pendiente, aprobada, rechazada }

class Solicitud {
  const Solicitud({
    required this.id,
    required this.empresaId,
    required this.empleadoId,
    required this.tipoId,
    required this.fechaDesde,
    required this.fechaHasta,
    required this.dias,
    required this.estado,
    this.aprobadorId,
    this.comentario,
  });

  final String id;
  final String empresaId;
  final String empleadoId;
  final String tipoId;
  final DateTime fechaDesde;
  final DateTime fechaHasta;
  final int dias;
  final EstadoSolicitud estado;
  final String? aprobadorId;
  final String? comentario;

  Solicitud copyWith({
    String? id,
    String? empresaId,
    String? empleadoId,
    String? tipoId,
    DateTime? fechaDesde,
    DateTime? fechaHasta,
    int? dias,
    EstadoSolicitud? estado,
    String? aprobadorId,
    String? comentario,
  }) {
    return Solicitud(
      id: id ?? this.id,
      empresaId: empresaId ?? this.empresaId,
      empleadoId: empleadoId ?? this.empleadoId,
      tipoId: tipoId ?? this.tipoId,
      fechaDesde: fechaDesde ?? this.fechaDesde,
      fechaHasta: fechaHasta ?? this.fechaHasta,
      dias: dias ?? this.dias,
      estado: estado ?? this.estado,
      aprobadorId: aprobadorId ?? this.aprobadorId,
      comentario: comentario ?? this.comentario,
    );
  }
}

class CriterioEvaluacion {
  const CriterioEvaluacion({
    required this.id,
    required this.nombre,
    required this.peso,
    required this.puntaje,
  });

  final String id;
  final String nombre;
  final double peso;
  final double puntaje;
}

class Evaluacion {
  const Evaluacion({
    required this.id,
    required this.empresaId,
    required this.empleadoId,
    required this.evaluadorId,
    required this.fecha,
    required this.puntajeTotal,
    required this.criterios,
    this.comentarios,
  });

  final String id;
  final String empresaId;
  final String empleadoId;
  final String evaluadorId;
  final DateTime fecha;
  final double puntajeTotal;
  final List<CriterioEvaluacion> criterios;
  final String? comentarios;
}

class OnboardingTask {
  const OnboardingTask({
    required this.id,
    required this.empresaId,
    required this.empleadoId,
    required this.titulo,
    required this.descripcion,
    required this.completada,
  });

  final String id;
  final String empresaId;
  final String empleadoId;
  final String titulo;
  final String descripcion;
  final bool completada;

  OnboardingTask copyWith({
    String? id,
    String? empresaId,
    String? empleadoId,
    String? titulo,
    String? descripcion,
    bool? completada,
  }) {
    return OnboardingTask(
      id: id ?? this.id,
      empresaId: empresaId ?? this.empresaId,
      empleadoId: empleadoId ?? this.empleadoId,
      titulo: titulo ?? this.titulo,
      descripcion: descripcion ?? this.descripcion,
      completada: completada ?? this.completada,
    );
  }
}
