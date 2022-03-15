import 'dart:developer';

import 'package:deliapp/cubits/timespan_cubit.dart';
import 'package:deliapp/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class SummaryScreen extends StatelessWidget {
  const SummaryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider<TimespanCubit>(
      create: (_) => TimespanCubit(),
      child: SummaryScreenView(),
    );
  }
}

class SummaryScreenView extends StatelessWidget {
  final RefreshController _refreshController = RefreshController(
    initialRefresh: true,
  );

  SummaryScreenView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Összegzés'),
        actions: [
          IconButton(
            onPressed: () => _showTimespanPickerDialog(context),
            icon: const Icon(Icons.date_range),
          ),
        ],
      ),
      body: SmartRefresher(
        enablePullDown: true,
        enablePullUp: false,
        header: const WaterDropMaterialHeader(),
        controller: _refreshController,
        onRefresh: _refresh,
        child: BlocBuilder<TimespanCubit, TimespanCubitData>(
          builder: (context, state) => Column(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  OutlinedButton(
                    onPressed: () => _showDatePickerDialog(
                      context,
                      state.from,
                      (d) => context.read<TimespanCubit>().setFrom(d),
                    ),
                    child: Text('${state.from}-től'),
                  ),
                  OutlinedButton(
                    onPressed: () => _showDatePickerDialog(
                      context,
                      state.from,
                      (d) => context.read<TimespanCubit>().setTo(d),
                    ),
                    child: Text('${state.to}-ig'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  _refresh() async {
    log('Refresh called!');
    await Future.delayed(const Duration(seconds: 2));
    _refreshController.refreshCompleted();
  }

  static _showTimespanPickerDialog(
    BuildContext context,
  ) {
    Utils.showDialogAnimated(
      context,
      null,
      content: Column(
        children: [
          _buildTimespanPicker(
            context,
            'Mitől',
            (state) => Utils.formatDate(state.from),
            () => _showDatePickerDialog(
              context,
              context.read<TimespanCubit>().state.from,
              (d) => context.read<TimespanCubit>().setFrom(d),
            ),
          ),
          const Divider(),
          _buildTimespanPicker(
            context,
            'Meddig',
            (state) => Utils.formatDate(state.to),
            () => _showDatePickerDialog(
              context,
              context.read<TimespanCubit>().state.to,
              (d) => context.read<TimespanCubit>().setTo(d),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('OK'),
        ),
      ],
    );
  }

  static Widget _buildTimespanPicker(
    BuildContext context,
    String text,
    String Function(TimespanCubitData) selector,
    void Function() onPressed,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(text),
        BlocBuilder<TimespanCubit, TimespanCubitData>(
          bloc: context.read<TimespanCubit>(),
          builder: (context, state) => GestureDetector(
            onTap: onPressed,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                color: Theme.of(context).focusColor,
              ),
              child: Text(selector.call(state)),
            ),
          ),
        ),
      ],
    );
  }

  static _showDatePickerDialog(
    BuildContext context,
    DateTime initial,
    void Function(DateTime) onChanged,
  ) {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => Container(
        height: 216,
        padding: const EdgeInsets.only(top: 16),
        margin: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        color: Theme.of(context).backgroundColor,
        child: SafeArea(
          top: false,
          child: CupertinoDatePicker(
            initialDateTime: initial,
            use24hFormat: true,
            mode: CupertinoDatePickerMode.dateAndTime,
            onDateTimeChanged: onChanged,
          ),
        ),
      ),
    );
  }
}
