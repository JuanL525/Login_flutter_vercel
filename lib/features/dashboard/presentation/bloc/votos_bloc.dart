import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/usecase/usecase.dart';
import '../../domain/entities/votos_consolidados.dart';
import '../../domain/usecases/get_votos_consolidados.dart';

// ── Events ──────────────────────────────────────────────────────────────────

abstract class VotosEvent extends Equatable {
  const VotosEvent();
  @override
  List<Object?> get props => [];
}

class LoadVotos extends VotosEvent {
  const LoadVotos();
}

// ── States ──────────────────────────────────────────────────────────────────

abstract class VotosState extends Equatable {
  const VotosState();
  @override
  List<Object?> get props => [];
}

class VotosInitial extends VotosState {
  const VotosInitial();
}

class VotosLoading extends VotosState {
  const VotosLoading();
}

class VotosLoaded extends VotosState {
  final List<VotosConsolidados> consolidados;
  const VotosLoaded(this.consolidados);
  @override
  List<Object?> get props => [consolidados];
}

class VotosError extends VotosState {
  final String message;
  const VotosError(this.message);
  @override
  List<Object?> get props => [message];
}

// ── BLoC ─────────────────────────────────────────────────────────────────────

class VotosBloc extends Bloc<VotosEvent, VotosState> {
  final GetVotosConsolidados getVotosConsolidados;

  VotosBloc({required this.getVotosConsolidados})
      : super(const VotosInitial()) {
    on<LoadVotos>(_onLoad);
  }

  Future<void> _onLoad(LoadVotos e, Emitter<VotosState> emit) async {
    emit(const VotosLoading());
    final result = await getVotosConsolidados(NoParams());
    result.fold(
      (f) => emit(VotosError(f.message)),
      (data) => emit(VotosLoaded(data)),
    );
  }
}
