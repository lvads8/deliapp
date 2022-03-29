import 'package:flutter_bloc/flutter_bloc.dart';

class RefreshingCubit extends Cubit<bool> {
  RefreshingCubit() : super(false);

  void refresh() => emit(true);

  void finish() => emit(false);
}
