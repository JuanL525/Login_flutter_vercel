import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../users/domain/entities/profile_entity.dart';
import '../../../users/domain/usecases/get_veedores.dart';
import '../../domain/entities/mesa_entity.dart';
import '../../domain/usecases/assign_veedor.dart';
import '../../domain/usecases/get_mesas_by_recinto.dart';
import '../../domain/usecases/get_mesas_by_veedor.dart';

// ----- Eventos -----
abstract class MesasEvent extends Equatable {
  const MesasEvent();
  @override
  List<Object?> get props => [];
}

class LoadMesasByRecinto extends MesasEvent {
  final String recintoId;
  const LoadMesasByRecinto(this.recintoId);
  @override
  List<Object?> get props => [recintoId];
}

class LoadMesasByVeedor extends MesasEvent {
  final String veedorId;
  const LoadMesasByVeedor(this.veedorId);
  @override
  List<Object?> get props => [veedorId];
}

class AssignVeedorRequested extends MesasEvent {
  final String mesaId;
  final String? veedorId;
  final String recintoId;
  const AssignVeedorRequested({
    required this.mesaId,
    required this.veedorId,
    required this.recintoId,
  });
  @override
  List<Object?> get props => [mesaId, veedorId, recintoId];
}

// ----- Estados -----
abstract class MesasState extends Equatable {
  const MesasState();
  @override
  List<Object?> get props => [];
}

class MesasInitial extends MesasState {
  const MesasInitial();
}

class MesasLoading extends MesasState {
  const MesasLoading();
}

class MesasLoaded extends MesasState {
  final List<MesaEntity> mesas;
  final List<ProfileEntity> veedores;
  const MesasLoaded(this.mesas, {this.veedores = const []});
  @override
  List<Object?> get props => [mesas, veedores];
}

class MesasError extends MesasState {
  final String message;
  const MesasError(this.message);
  @override
  List<Object?> get props => [message];
}

@injectable
class MesasBloc extends Bloc<MesasEvent, MesasState> {
  final GetMesasByRecinto getMesasByRecinto;
  final GetMesasByVeedor getMesasByVeedor;
  final AssignVeedor assignVeedor;
  final GetVeedores getVeedores;

  MesasBloc({
    required this.getMesasByRecinto,
    required this.getMesasByVeedor,
    required this.assignVeedor,
    required this.getVeedores,
  }) : super(const MesasInitial()) {
    on<LoadMesasByRecinto>(_onLoadByRecinto);
    on<LoadMesasByVeedor>(_onLoadByVeedor);
    on<AssignVeedorRequested>(_onAssign);
  }

  Future<void> _onLoadByRecinto(
    LoadMesasByRecinto e,
    Emitter<MesasState> emit,
  ) async {
    emit(const MesasLoading());
    final mesasResult = await getMesasByRecinto(e.recintoId);
    final veedoresResult = await getVeedores(e.recintoId);

    final veedores = veedoresResult.getOrElse(() => const []);
    mesasResult.fold(
      (f) => emit(MesasError(f.message)),
      (mesas) => emit(MesasLoaded(mesas, veedores: veedores)),
    );
  }

  Future<void> _onLoadByVeedor(
    LoadMesasByVeedor e,
    Emitter<MesasState> emit,
  ) async {
    emit(const MesasLoading());
    final result = await getMesasByVeedor(e.veedorId);
    result.fold(
      (f) => emit(MesasError(f.message)),
      (mesas) => emit(MesasLoaded(mesas)),
    );
  }

  Future<void> _onAssign(
    AssignVeedorRequested e,
    Emitter<MesasState> emit,
  ) async {
    final result = await assignVeedor(
      AssignVeedorParams(mesaId: e.mesaId, veedorId: e.veedorId),
    );
    await result.fold(
      (f) async => emit(MesasError(f.message)),
      (_) async => add(LoadMesasByRecinto(e.recintoId)),
    );
  }
}
