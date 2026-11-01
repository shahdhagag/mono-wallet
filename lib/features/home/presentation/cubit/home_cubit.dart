import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/get_recent_transactions_usecase.dart';
import 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit(this.getRecentTransactionsUseCase) : super(const HomeInitial()) {
    loadHome();
  }

  final GetRecentTransactionsUseCase getRecentTransactionsUseCase;

  Future<void> loadHome() async {
    final transactions = await getRecentTransactionsUseCase();
    emit(HomeLoaded(transactions));
  }
}