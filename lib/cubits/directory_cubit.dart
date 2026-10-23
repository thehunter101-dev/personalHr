import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:personal_hr/models/hr_models.dart';
import 'package:personal_hr/repositories/hr_repository.dart';

class DirectoryState {
  const DirectoryState({this.empleados = const [], this.searchQuery = ''});

  final List<Empleado> empleados;
  final String searchQuery;

  List<Empleado> get filteredEmpleados {
    if (searchQuery.trim().isEmpty) return empleados;
    final q = searchQuery.toLowerCase();
    return empleados
        .where(
          (e) =>
              e.nombre.toLowerCase().contains(q) ||
              e.cargo.toLowerCase().contains(q),
        )
        .toList();
  }
}

class DirectoryCubit extends Cubit<DirectoryState> {
  DirectoryCubit({required HrRepository repository})
    : _repository = repository,
      super(const DirectoryState());

  final HrRepository _repository;

  void loadDirectory(String empresaId) {
    final list = _repository.getEmpleados(empresaId);
    emit(DirectoryState(empleados: list, searchQuery: state.searchQuery));
  }

  void search(String query) {
    emit(DirectoryState(empleados: state.empleados, searchQuery: query));
  }
}
