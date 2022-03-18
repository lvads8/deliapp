import 'dart:developer';

import 'package:deliapp/api/common.dart';
import 'package:deliapp/api/history.dart';
import 'package:deliapp/cubits/auth_cubit.dart';
import 'package:deliapp/cubits/timespan_cubit.dart';
import 'package:deliapp/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';

class SummaryScreen extends StatelessWidget {
  const SummaryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider<TimespanCubit>(
      create: (_) => TimespanCubit(),
      child: const SummaryScreenView(),
    );
  }
}

class SummaryScreenView extends StatefulWidget {
  const SummaryScreenView({Key? key}) : super(key: key);

  @override
  State<SummaryScreenView> createState() => _SummaryScreenViewState();
}

class _SummaryScreenViewState extends State<SummaryScreenView> {
  Future<HistoryResponse>? _history;

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
      body: RefreshIndicator(
        onRefresh: () => _refresh(context),
        triggerMode: RefreshIndicatorTriggerMode.anywhere,
        child: Scrollbar(
          // TODO: Remove FutureBuilder from this, as it causes stuff to disappear which isn't very nice lol
          child: FutureBuilder(
            future: _history,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.none) {
                return ListView(
                  children: [
                    Container(
                      height: 100,
                    ),
                    Text(
                      'Válassz ki egy időszakot és húzd lefelé a frissítéshez',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Theme.of(context).hintColor,
                      ),
                    ),
                  ],
                );
              }
              if (snapshot.connectionState != ConnectionState.done) {
                return ListView(
                  children: [
                    Container(),
                  ],
                );
              }

              final data = snapshot.data as HistoryResponse;
              if (data.trips.isEmpty) {
                return ListView(
                  children: [
                    Container(
                      height: 100,
                    ),
                    Text(
                      'Nincs rendelés az adott időszakban',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Theme.of(context).hintColor,
                      ),
                    ),
                  ],
                );
              }

              return ListView.separated(
                shrinkWrap: true,
                itemCount: data.trips.length + 1,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return Card(
                      margin: const EdgeInsets.fromLTRB(4, 4, 4, 8),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            const Icon(
                              Icons.paid,
                              size: 56,
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                const Text(
                                  'Kézpénz',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text('${data.cashCollected} Ft')
                              ],
                            )
                          ],
                        ),
                      ),
                    );
                  }

                  final current = data.trips[index - 1];
                  return _buildCard(current);
                },
                separatorBuilder: (_, __) => Container(
                  height: 2,
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildCard(HistoryTrip current) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: ListTile(
          leading: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.local_shipping),
            ],
          ),
          title: Text(current.name),
          subtitle: Text('${current.orderCount} cím'),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('Kezdés: ' + Utils.formatDate(current.start)),
              Text('Végzés: ' + Utils.formatDate(current.end)),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _refresh(BuildContext context) async {
    log('Refresh called!');

    final auth = context.read<AuthCubit>().state!.auth;
    final timespanCubit = context.read<TimespanCubit>();
    final from = timespanCubit.state.from;
    final to = timespanCubit.state.to;

    final future = Utils.tryRequest(
      context,
      () => History.getHistory(HistoryRequest(auth, from, to)),
      null,
      snackbar: true,
    ).then((value) => value ?? const HistoryResponse(0, []));

    setState(() {
      _history = future;
    });

    await future;
  }

  static Future<void> _showTimespanPickerDialog(
    BuildContext context,
  ) async {
    await Utils.showDialogAnimated(
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
            backgroundColor: Theme.of(context).hintColor,
          ),
        ),
      ),
    );
  }
}
