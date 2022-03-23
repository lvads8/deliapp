import 'package:flutter_bloc/flutter_bloc.dart';

class TimespanCubitData {
  final DateTime from;
  final DateTime to;

  const TimespanCubitData(this.from, this.to);

  @override
  String toString() {
    return 'TimespanCubitData(from: $from, to: $to)';
  }
}

class TimespanCubit extends Cubit<TimespanCubitData> {
  TimespanCubit() : super(getInitialDate());

  static TimespanCubitData getInitialDate() {
    final now = DateTime.now();

    return TimespanCubitData(
      DateTime(now.year, now.month, now.day, 0, 0),
      DateTime(now.year, now.month, now.day, 23, 59),
    );
  }

  setFrom(DateTime d) {
    final data = TimespanCubitData(d, state.to);
    emit(data);
  }

  setTo(DateTime d) {
    final data = TimespanCubitData(state.from, d);
    emit(data);
  }
}
