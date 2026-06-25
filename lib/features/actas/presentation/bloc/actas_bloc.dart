import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/constants/enums.dart';
import '../../../../core/seeds/organizaciones_seed.dart';
import '../../../organizaciones/domain/repositories/organizaciones_repository.dart';
import '../../domain/entities/acta_entity.dart';
import '../../domain/usecases/get_actas_by_mesa.dart';
import '../../domain/usecases/save_acta.dart';

// ----- Eventos -----
abstract class ActasEvent extends Equatable {
  const ActasEvent();
  @override
  List<Object?> get props => [];
}

class LoadActas extends ActasEvent {
  final String mesaId;
  const LoadActas(this.mesaId);
  @override
  List<Object?> get props => [mesaId];
}

class SaveActaRequested extends ActasEvent {
  final ActaEntity acta;
  const SaveActaRequested(this.acta);
  @override
  List<Object?> get props => [acta];
}

// ----- Estados -----
abstract class ActasState extends Equatable {
  const ActasState();
  @override
  List<Object?> get props => [];
}

class ActasLoading extends ActasState {
  const ActasLoading();
}

class ActasLoaded extends ActasState {
  final String mesaId;
  final ActaEntity? alcalde;
  final ActaEntity? prefecto;
  const ActasLoaded({required this.mesaId, this.alcalde, this.prefecto});
  @override
  List<Object?> get props => [mesaId, alcalde, prefecto];
}

class ActasError extends ActasState {
  final String message;
  const ActasError(this.message);
  @override
  List<Object?> get props => [message];
}

class ActaSaving extends ActasState {
  const ActaSaving();
}

class ActaSaveSuccess extends ActasState {
  const ActaSaveSuccess();
}

@injectable
class ActasBloc extends Bloc<ActasEvent, ActasState> {
  final GetActasByMesa getActasByMesa;
  final SaveActa saveActa;
  final OrganizacionesRepository organizacionesRepository;

  ActasBloc({
    required this.getActasByMesa,
    required this.saveActa,
    required this.organizacionesRepository,
  }) : super(const ActasLoading()) {
    on<LoadActas>(_onLoad);
    on<SaveActaRequested>(_onSave);
  }

  List<OrganizacionPolitica> organizaciones(Dignidad d) =>
      organizacionesRepository.getByDignidad(d);

  Future<void> _onLoad(LoadActas e, Emitter<ActasState> emit) async {
    emit(const ActasLoading());
    final result = await getActasByMesa(e.mesaId);
    result.fold(
      (f) => emit(ActasError(f.message)),
      (actas) {
        ActaEntity? alcalde;
        ActaEntity? prefecto;
        for (final a in actas) {
          if (a.dignidad == Dignidad.alcalde) alcalde = a;
          if (a.dignidad == Dignidad.prefecto) prefecto = a;
        }
        emit(ActasLoaded(
          mesaId: e.mesaId,
          alcalde: alcalde,
          prefecto: prefecto,
        ));
      },
    );
  }

  Future<void> _onSave(SaveActaRequested e, Emitter<ActasState> emit) async {
    emit(const ActaSaving());
    final result = await saveActa(e.acta);
    await result.fold(
      (f) async => emit(ActasError(f.message)),
      (_) async {
        emit(const ActaSaveSuccess());
        add(LoadActas(e.acta.mesaId));
      },
    );
  }
}
