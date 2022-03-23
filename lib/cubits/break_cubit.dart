import 'package:deliapp/api/common.dart';
import 'package:deliapp/api/break.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BreakCubit extends Cubit<bool> {
  BreakCubit(bool intial) : super(intial);

  Future<void> setBreak(Authentication auth, bool value) async {
    emit(value);
    try {
      if (!await Break.setBreak(BreakRequest(auth, value))) {
        throw 'Ismeretlen hiba történt break beállításakor';
      }
    } catch (e) {
      emit(!value);
      rethrow;
    }
  }
}
