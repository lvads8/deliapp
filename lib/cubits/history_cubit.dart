import 'package:deliapp/api/common.dart';
import 'package:deliapp/api/history.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HistoryCubit extends Cubit<HistoryResponse?> {
  HistoryCubit() : super(null);

  Future<void> getHistory(
    Authentication auth,
    DateTime from,
    DateTime to,
  ) async {
    final response = await History.getHistory(HistoryRequest(auth, from, to));
    emit(response);
  }
}
