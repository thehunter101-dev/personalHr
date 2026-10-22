import 'package:flutter_test/flutter_test.dart';
import 'package:personal_hr/models/hr_models.dart';
import 'package:personal_hr/repositories/hr_repository.dart';

void main() {
  group('HrRepository Business Rules Tests', () {
    late HrRepository repo;

    setUp(() {
      repo = HrRepository();
    });

    test('Multi-tenant isolation: getEmpleados filters by empresaId', () {
      final emp1List = repo.getEmpleados('emp_1');
      final emp2List = repo.getEmpleados('emp_2');

      expect(emp1List.every((e) => e.empresaId == 'emp_1'), isTrue);
      expect(emp2List.every((e) => e.empresaId == 'emp_2'), isTrue);
    });

    test(
      'Hierarchy isolation: getEmpleadosByJefe returns only team members',
      () {
        final team = repo.getEmpleadosByJefe('emp_1', 'usr_jefe1');
        expect(team.every((e) => e.jefeId == 'usr_jefe1'), isTrue);
      },
    );

    test(
      'Validation: Balance rule blocks request exceeding saldoVacaciones',
      () {
        final emp = repo.getEmpleadoById('emp_2');
        expect(emp, isNotNull);

        final error = repo.crearSolicitud(
          empresaId: 'emp_1',
          empleadoId: 'emp_2',
          tipoId: 'tipo_vac',
          fechaDesde: DateTime.now(),
          fechaHasta: DateTime.now().add(const Duration(days: 20)),
        );

        expect(error, contains('Saldo insuficiente'));
      },
    );

    test('Validation & Deduction: Approval deducts balance automatically', () {
      final emp = repo.getEmpleadoById('emp_2')!;
      final initialBalance = emp.saldoVacaciones;

      final error = repo.crearSolicitud(
        empresaId: 'emp_1',
        empleadoId: 'emp_2',
        tipoId: 'tipo_vac',
        fechaDesde: DateTime(2028, 5, 10),
        fechaHasta: DateTime(2028, 5, 12),
      );
      expect(error, isNull);

      final sol = repo
          .getSolicitudesByEmpleado('emp_1', 'emp_2')
          .firstWhere((s) => s.fechaDesde == DateTime(2028, 5, 10));

      final respError = repo.responderSolicitud(
        solicitudId: sol.id,
        aprobadorUsuarioId: 'usr_jefe1',
        nuevoEstado: EstadoSolicitud.aprobada,
      );
      expect(respError, isNull);

      final updatedEmp = repo.getEmpleadoById('emp_2')!;
      expect(updatedEmp.saldoVacaciones, equals(initialBalance - 3));
    });

    test(
      'Overlap blocking rule: cannot approve overlapping requests for same employee',
      () {
        repo.crearSolicitud(
          empresaId: 'emp_1',
          empleadoId: 'emp_2',
          tipoId: 'tipo_vac',
          fechaDesde: DateTime(2028, 6, 1),
          fechaHasta: DateTime(2028, 6, 5),
        );
        final sol1 = repo
            .getSolicitudesByEmpleado('emp_1', 'emp_2')
            .firstWhere((s) => s.fechaDesde == DateTime(2028, 6, 1));
        repo.responderSolicitud(
          solicitudId: sol1.id,
          aprobadorUsuarioId: 'usr_jefe1',
          nuevoEstado: EstadoSolicitud.aprobada,
        );

        repo.crearSolicitud(
          empresaId: 'emp_1',
          empleadoId: 'emp_2',
          tipoId: 'tipo_vac',
          fechaDesde: DateTime(2028, 6, 3),
          fechaHasta: DateTime(2028, 6, 7),
        );
        final sol2 = repo
            .getSolicitudesByEmpleado('emp_1', 'emp_2')
            .firstWhere((s) => s.fechaDesde == DateTime(2028, 6, 3));

        final respError = repo.responderSolicitud(
          solicitudId: sol2.id,
          aprobadorUsuarioId: 'usr_jefe1',
          nuevoEstado: EstadoSolicitud.aprobada,
        );

        expect(respError, contains('Solapamiento de fechas'));
      },
    );
  });
}
