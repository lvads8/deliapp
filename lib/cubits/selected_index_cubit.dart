import 'package:flutter_bloc/flutter_bloc.dart';

class SelectedIndexCubit extends Cubit<int> {
  SelectedIndexCubit(int index) : super(index);

  void setIndex(int value) => emit(value);
}
