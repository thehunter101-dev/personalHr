import 'package:personal_hr/models/hr_models.dart';

class HrRepository {
  HrRepository() {
    seedData();
  }

  int _nextSolicitudId = 1000;
  List<Empresa> _empresas = [];
  List<Usuario> _usuarios = [];
  List<Departamento> _departamentos = [];
  List<Empleado> _empleados = [];
  List<TipoSolicitud> _tiposSolicitud = [];
  List<Solicitud> _solicitudes = [];
  List<Evaluacion> _evaluaciones = [];
  List<OnboardingTask> _onboardingTasks = [];

  void seedData() {
    _empresas = const [
      Empresa(id: 'emp_1', nombre: 'TechSolutions S.A.', ciudad: 'Bogotá'),
      Empresa(id: 'emp_2', nombre: 'Logística Global Corp', ciudad: 'Medellín'),
    ];

    _usuarios = const [
      Usuario(
        id: 'usr_admin1',
        empresaId: 'emp_1',
        nombre: 'Valeria Gómez (RRHH)',
        correo: 'valeria.rrhh@techsolutions.com',
        rol: UserRole.adminRrhh,
      ),
      Usuario(
        id: 'usr_jefe1',
        empresaId: 'emp_1',
        nombre: 'Carlos Mendoza (Jefe IT)',
        correo: 'carlos.mendoza@techsolutions.com',
        rol: UserRole.jefe,
      ),
      Usuario(
        id: 'usr_emp1',
        empresaId: 'emp_1',
        nombre: 'Ana Lucía Torres (Dev)',
        correo: 'ana.torres@techsolutions.com',
        rol: UserRole.operativo,
      ),
      Usuario(
        id: 'usr_admin2',
        empresaId: 'emp_2',
        nombre: 'Fernando Ruiz (RRHH Logística)',
        correo: 'fernando@logisticaglobal.com',
        rol: UserRole.adminRrhh,
      ),
    ];

    _departamentos = const [
      Departamento(
        id: 'dep_1',
        empresaId: 'emp_1',
        nombre: 'Tecnología',
        jefeId: 'usr_jefe1',
      ),
      Departamento(
        id: 'dep_2',
        empresaId: 'emp_1',
        nombre: 'Operaciones',
        jefeId: 'usr_jefe1',
      ),
      Departamento(
        id: 'dep_3',
        empresaId: 'emp_2',
        nombre: 'Almacén',
        jefeId: 'usr_admin2',
      ),
    ];

    _tiposSolicitud = const [
      TipoSolicitud(id: 'tipo_vac', nombre: 'Vacaciones', descuentaSaldo: true),
      TipoSolicitud(
        id: 'tipo_med',
        nombre: 'Permiso Médico',
        descuentaSaldo: false,
      ),
      TipoSolicitud(
        id: 'tipo_per',
        nombre: 'Permiso Personal',
        descuentaSaldo: false,
      ),
    ];

    final now = DateTime.now();
    final list = <Empleado>[
      Empleado(
        id: 'emp_0',
        empresaId: 'emp_1',
        usuarioId: 'usr_admin1',
        nombre: 'Valeria Gómez',
        cargo: 'Directora de Talentos',
        departamentoId: 'dep_1',
        fechaIngreso: DateTime(2020),
        saldoVacaciones: 20,
      ),
      Empleado(
        id: 'emp_1',
        empresaId: 'emp_1',
        usuarioId: 'usr_jefe1',
        nombre: 'Carlos Mendoza',
        cargo: 'Líder Técnico IT',
        departamentoId: 'dep_1',
        jefeId: 'usr_admin1',
        fechaIngreso: DateTime(2021, 3, 10),
        saldoVacaciones: 15,
      ),
      Empleado(
        id: 'emp_2',
        empresaId: 'emp_1',
        usuarioId: 'usr_emp1',
        nombre: 'Ana Lucía Torres',
        cargo: 'Desarrolladora Frontend',
        departamentoId: 'dep_1',
        jefeId: 'usr_jefe1',
        fechaIngreso: DateTime(2023, 6),
        saldoVacaciones: 12,
      ),
    ];

    final namesEmp1 = [
      'Camilo Silva',
      'Mariana Páez',
      'David Ospina',
      'Sofía Ramírez',
      'Juan Pablo Duarte',
      'Paula Morales',
      'Andrés Cepeda',
      'Gabriela Mistral',
      'Esteban Quito',
      'Diana Uribe',
      'Santiago Alarcón',
      'Laura Acuña',
      'Mateo Carvajal',
      'Daniela Ospina',
      'Felipe Arias',
      'Camila Osorio',
      'Gabriel García',
      'Isabella Castillo',
      'Alejandro Sanz',
      'Natalia París',
      'Nicolás Arrieta',
      'Juliana Velásquez',
      'Samuel Moreno',
      'Valentina Lizcano',
      'Sebastián Yatra',
      'Manuela Gómez',
      'Lucas Arnau',
      'Catalina Gómez',
      'Jorge Barón',
      'Silvia Tcherassi',
      'Rigoberto Urán',
      'Nairo Quintana',
    ];

    final namesEmp2 = [
      'Egan Bernal',
      'Mariana Pajón',
      'Radamel Falcao',
      'James Rodríguez',
      'David Ospina Jr.',
      'Juan Cuadrado',
      'Luis Díaz',
      'Yerry Mina',
      'Davinson Sánchez',
      'Jefferson Lerma',
      'Wilmar Barrios',
      'Mateus Uribe',
      'Duvalier Zapata',
      'Rafael Borré',
      'Jhon Arias',
    ];

    var idCounter = 3;
    for (var i = 0; i < namesEmp1.length; i++) {
      list.add(
        Empleado(
          id: 'emp_$idCounter',
          empresaId: 'emp_1',
          usuarioId: 'usr_gen_$idCounter',
          nombre: namesEmp1[i],
          cargo: i.isEven ? 'Desarrollador Software' : 'Analista QA',
          departamentoId: 'dep_1',
          jefeId: 'usr_jefe1',
          fechaIngreso: DateTime(2022, (i % 12) + 1, (i % 28) + 1),
          saldoVacaciones: 10 + (i % 10),
        ),
      );
      idCounter++;
    }

    for (var i = 0; i < namesEmp2.length; i++) {
      list.add(
        Empleado(
          id: 'emp_$idCounter',
          empresaId: 'emp_2',
          usuarioId: 'usr_gen_$idCounter',
          nombre: namesEmp2[i],
          cargo: 'Operario de Logística',
          departamentoId: 'dep_3',
          jefeId: 'usr_admin2',
          fechaIngreso: DateTime(2021, (i % 12) + 1, (i % 28) + 1),
          saldoVacaciones: 8 + (i % 8),
        ),
      );
      idCounter++;
    }

    _empleados = list;

    final solList = <Solicitud>[];
    for (var i = 0; i < 25; i++) {
      final isEmp1 = i < 18;
      final emp = _empleados.firstWhere(
        (e) => isEmp1 ? e.empresaId == 'emp_1' : e.empresaId == 'emp_2',
      );
      final startDate = now.add(Duration(days: (i * 3) - 15));
      final endDate = startDate.add(Duration(days: (i % 4) + 1));

      solList.add(
        Solicitud(
          id: 'sol_$i',
          empresaId: emp.empresaId,
          empleadoId: emp.id,
          tipoId: i % 3 == 0
              ? 'tipo_vac'
              : (i % 3 == 1 ? 'tipo_med' : 'tipo_per'),
          fechaDesde: startDate,
          fechaHasta: endDate,
          dias: (i % 4) + 1,
          estado: i % 4 == 0
              ? EstadoSolicitud.aprobada
              : (i % 4 == 1
                    ? EstadoSolicitud.rechazada
                    : EstadoSolicitud.pendiente),
          aprobadorId: i % 4 != 2 ? 'usr_jefe1' : null,
          comentario: i % 4 != 2 ? 'Revisado y procesado.' : null,
        ),
      );
    }
    _solicitudes = solList;

    _onboardingTasks = const [
      OnboardingTask(
        id: 'task_1',
        empresaId: 'emp_1',
        empleadoId: 'emp_2',
        titulo: 'Firma de Contrato y NDA',
        descripcion: 'Subir documentos firmados a la plataforma de RRHH.',
        completada: true,
      ),
      OnboardingTask(
        id: 'task_2',
        empresaId: 'emp_1',
        empleadoId: 'emp_2',
        titulo: 'Configuración del Equipo de Cómputo',
        descripcion: 'Instalar entorno de desarrollo y accesos a GitHub/Slack.',
        completada: true,
      ),
      OnboardingTask(
        id: 'task_3',
        empresaId: 'emp_1',
        empleadoId: 'emp_2',
        titulo: 'Reunión de Bienvenida con el Equipo',
        descripcion:
            'Sesión virtual de 30 mins con Carlos Mendoza y el equipo.',
        completada: false,
      ),
      OnboardingTask(
        id: 'task_4',
        empresaId: 'emp_1',
        empleadoId: 'emp_2',
        titulo: 'Capacitación en Políticas Internas',
        descripcion:
            'Completar módulo de entrenamiento de vacaciones y permisos.',
        completada: false,
      ),
    ];

    _evaluaciones = [
      Evaluacion(
        id: 'eval_1',
        empresaId: 'emp_1',
        empleadoId: 'emp_2',
        evaluadorId: 'usr_jefe1',
        fecha: DateTime.now().subtract(const Duration(days: 30)),
        puntajeTotal: 4.5,
        comentarios:
            'Excelente desempeño técnico y gran adaptabilidad al equipo.',
        criterios: const [
          CriterioEvaluacion(
            id: 'c1',
            nombre: 'Calidad de Código',
            peso: 0.4,
            puntaje: 4.8,
          ),
          CriterioEvaluacion(
            id: 'c2',
            nombre: 'Trabajo en Equipo',
            peso: 0.3,
            puntaje: 4.5,
          ),
          CriterioEvaluacion(
            id: 'c3',
            nombre: 'Cumplimiento de Plazos',
            peso: 0.3,
            puntaje: 4,
          ),
        ],
      ),
    ];
  }

  List<Empresa> getEmpresas() => List.unmodifiable(_empresas);

  List<Departamento> getDepartamentos(String empresaId) {
    return _departamentos.where((d) => d.empresaId == empresaId).toList();
  }

  List<Usuario> getUsuariosByEmpresa(String empresaId) {
    return _usuarios.where((u) => u.empresaId == empresaId).toList();
  }

  List<Empleado> getEmpleados(String empresaId) {
    return _empleados.where((e) => e.empresaId == empresaId).toList();
  }

  List<Empleado> getEmpleadosByJefe(String empresaId, String jefeUsuarioId) {
    return _empleados
        .where((e) => e.empresaId == empresaId && e.jefeId == jefeUsuarioId)
        .toList();
  }

  Empleado? getEmpleadoByUsuarioId(String usuarioId) {
    try {
      return _empleados.firstWhere((e) => e.usuarioId == usuarioId);
    } catch (_) {
      return null;
    }
  }

  Empleado? getEmpleadoById(String id) {
    try {
      return _empleados.firstWhere((e) => e.id == id);
    } catch (_) {
      return null;
    }
  }

  List<TipoSolicitud> getTiposSolicitud() => List.unmodifiable(_tiposSolicitud);

  List<Solicitud> getSolicitudes(String empresaId) {
    return _solicitudes.where((s) => s.empresaId == empresaId).toList();
  }

  List<Solicitud> getSolicitudesByEmpleado(
    String empresaId,
    String empleadoId,
  ) {
    return _solicitudes
        .where((s) => s.empresaId == empresaId && s.empleadoId == empleadoId)
        .toList();
  }

  List<Solicitud> getSolicitudesByJefe(String empresaId, String jefeUsuarioId) {
    final teamEmpIds = getEmpleadosByJefe(
      empresaId,
      jefeUsuarioId,
    ).map((e) => e.id).toSet();
    return _solicitudes
        .where(
          (s) => s.empresaId == empresaId && teamEmpIds.contains(s.empleadoId),
        )
        .toList();
  }

  String? crearSolicitud({
    required String empresaId,
    required String empleadoId,
    required String tipoId,
    required DateTime fechaDesde,
    required DateTime fechaHasta,
  }) {
    final empleado = getEmpleadoById(empleadoId);
    if (empleado == null) return 'Empleado no encontrado.';

    final tipo = _tiposSolicitud.firstWhere(
      (t) => t.id == tipoId,
      orElse: () => _tiposSolicitud.first,
    );

    final dias = fechaHasta.difference(fechaDesde).inDays + 1;
    if (dias <= 0) {
      return 'La fecha hasta debe ser posterior a la fecha desde.';
    }

    if (tipo.descuentaSaldo && dias > empleado.saldoVacaciones) {
      return 'Saldo insuficiente. Tienes ${empleado.saldoVacaciones} días '
          'disponibles y solicitaste $dias días.';
    }

    _nextSolicitudId++;
    final newSolicitud = Solicitud(
      id: 'sol_$_nextSolicitudId',
      empresaId: empresaId,
      empleadoId: empleadoId,
      tipoId: tipoId,
      fechaDesde: fechaDesde,
      fechaHasta: fechaHasta,
      dias: dias,
      estado: EstadoSolicitud.pendiente,
    );

    _solicitudes.insert(0, newSolicitud);
    return null;
  }

  String? responderSolicitud({
    required String solicitudId,
    required String aprobadorUsuarioId,
    required EstadoSolicitud nuevoEstado,
    String? comentario,
  }) {
    final index = _solicitudes.indexWhere((s) => s.id == solicitudId);
    if (index == -1) return 'Solicitud no encontrada.';

    final current = _solicitudes[index];
    final empleado = getEmpleadoById(current.empleadoId);
    if (empleado == null) return 'Empleado no encontrado.';

    final tipo = _tiposSolicitud.firstWhere((t) => t.id == current.tipoId);

    if (nuevoEstado == EstadoSolicitud.aprobada) {
      final hasOverlap = _solicitudes.any((s) {
        if (s.id == current.id) return false;
        if (s.empleadoId != current.empleadoId) return false;
        if (s.estado != EstadoSolicitud.aprobada) return false;

        // Overlap if not (current ends before s starts OR current starts after s ends)
        final cEnd = DateTime(
          current.fechaHasta.year,
          current.fechaHasta.month,
          current.fechaHasta.day,
        );
        final cStart = DateTime(
          current.fechaDesde.year,
          current.fechaDesde.month,
          current.fechaDesde.day,
        );
        final sStart = DateTime(
          s.fechaDesde.year,
          s.fechaDesde.month,
          s.fechaDesde.day,
        );
        final sEnd = DateTime(
          s.fechaHasta.year,
          s.fechaHasta.month,
          s.fechaHasta.day,
        );

        return !(cEnd.isBefore(sStart) || cStart.isAfter(sEnd));
      });

      if (hasOverlap) {
        return 'Solapamiento de fechas: El empleado ya tiene otra solicitud '
            'aprobada en el mismo período.';
      }

      if (tipo.descuentaSaldo) {
        final nuevoSaldo = empleado.saldoVacaciones - current.dias;
        final empIndex = _empleados.indexWhere((e) => e.id == empleado.id);
        if (empIndex != -1) {
          _empleados[empIndex] = _empleados[empIndex].copyWith(
            saldoVacaciones: nuevoSaldo,
          );
        }
      }
    }

    _solicitudes[index] = current.copyWith(
      estado: nuevoEstado,
      aprobadorId: aprobadorUsuarioId,
      comentario: comentario,
    );

    return null;
  }

  List<Evaluacion> getEvaluacionesByEmpleado(
    String empresaId,
    String empleadoId,
  ) {
    return _evaluaciones
        .where((e) => e.empresaId == empresaId && e.empleadoId == empleadoId)
        .toList();
  }

  void guardarEvaluacion(Evaluacion evaluacion) {
    _evaluaciones.add(evaluacion);
  }

  List<OnboardingTask> getOnboardingTasks(String empresaId, String empleadoId) {
    return _onboardingTasks
        .where((t) => t.empresaId == empresaId && t.empleadoId == empleadoId)
        .toList();
  }

  void toggleTaskStatus(String taskId) {
    final index = _onboardingTasks.indexWhere((t) => t.id == taskId);
    if (index != -1) {
      final task = _onboardingTasks[index];
      _onboardingTasks[index] = task.copyWith(completada: !task.completada);
    }
  }
}
