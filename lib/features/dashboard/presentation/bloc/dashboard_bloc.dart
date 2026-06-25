import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/usecase/usecase.dart';
import '../../domain/entities/recinto_avance.dart';
import '../../domain/usecases/get_provincial_avance.dart';

abstract class DashboardEvent extends Equatable {
  const DashboardEvent();
  @override
  List<Object?> get props => [];
}

class LoadProvincialAvance extends DashboardEvent {
  const LoadProvincialAvance();
}

abstract class DashboardState extends Equatable {
  const DashboardState();
  @override
  List<Object?> get props => [];
}

class DashboardLoading extends DashboardState {
  const DashboardLoading();
}

class DashboardLoaded extends DashboardState {
  final List<RecintoAvance> avances;
  const DashboardLoaded(this.avances);
  @override
  List<Object?> get props => [avances];
}

class DashboardError extends DashboardState {
  final String message;
  const DashboardError(this.message);
  @override
  List<Object?> get props => [message];
}

@injectable
class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final GetProvincialAvance getProvincialAvance;

  DashboardBloc({required this.getProvincialAvance})
      : super(const DashboardLoading()) {
    on<LoadProvincialAvance>(_onLoad);
  }

  Future<void> _onLoad(
    LoadProvincialAvance e,
    Emitter<DashboardState> emit,
  ) async {
    emit(const DashboardLoading());
    final result = await getProvincialAvance(NoParams());
    result.fold(
      (f) => emit(DashboardError(f.message)),
      (avances) => emit(DashboardLoaded(avances)),
    );
  }
}
