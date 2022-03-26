import 'package:flutter_bloc/flutter_bloc.dart';

class SelectedIndexCubit extends Cubit<int> {
  SelectedIndexCubit() : super(0);

  int get index => state;
  set index(int value) => emit(value);
}
