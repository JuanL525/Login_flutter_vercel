import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/usecase/usecase.dart';
import '../../domain/entities/recinto_entity.dart';
import '../../domain/usecases/get_recintos.dart';
import '../../domain/usecases/save_recinto.dart';

// ----- Eventos -----
abstract class RecintosEvent extends Equatable {
  const RecintosEvent();
  @override
  List<Object?> get props => [];
}

class LoadRecintos extends RecintosEvent {
  const LoadRecintos();
}

class SaveRecintoRequested extends RecintosEvent {
  final String? id;
  final String provincia;
  final String canton;
  final String parroquia;
  final String nombre;

  const SaveRecintoRequested({
    this.id,
    required this.provincia,
    required this.canton,
    required this.parroquia,
    required this.nombre,
  });

  @override
  List<Object?> get props => [id, provincia, canton, parroquia, nombre];
}

// ----- Estados -----
abstract class RecintosState extends Equatable {
  const RecintosState();
  @override
  List<Object?> get props => [];
}

class RecintosInitial extends RecintosState {
  const RecintosInitial();
}

class RecintosLoading extends RecintosState {
  const RecintosLoading();
}

class RecintosLoaded extends RecintosState {
  final List<RecintoEntity> recintos;
  const RecintosLoaded(this.recintos);
  @override
  List<Object?> get props => [recintos];
}

class RecintosError extends RecintosState {
  final String message;
  const RecintosError(this.message);
  @override
  List<Object?> get props => [message];
}

class RecintoSaved extends RecintosState {
  const RecintoSaved();
}

@injectable
class RecintosBloc extends Bloc<RecintosEvent, RecintosState> {
  final GetRecintos getRecintos;
  final SaveRecinto saveRecinto;

  RecintosBloc({required this.getRecintos, required this.saveRecinto})
      : super(const RecintosInitial()) {
    on<LoadRecintos>(_onLoad);
    on<SaveRecintoRequested>(_onSave);
  }

  Future<void> _onLoad(LoadRecintos e, Emitter<RecintosState> emit) async {
    emit(const RecintosLoading());
    final result = await getRecintos(NoParams());
    result.fold(
      (f) => emit(RecintosError(f.message)),
      (list) => emit(RecintosLoaded(list)),
    );
  }

  Future<void> _onSave(
    SaveRecintoRequested e,
    Emitter<RecintosState> emit,
  ) async {
    emit(const RecintosLoading());
    final result = await saveRecinto(
      SaveRecintoParams(
        id: e.id,
        provincia: e.provincia,
        canton: e.canton,
        parroquia: e.parroquia,
        nombre: e.nombre,
      ),
    );
    result.fold(
      (f) => emit(RecintosError(f.message)),
      (_) => emit(const RecintoSaved()),
    );
  }
}
