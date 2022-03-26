import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:deliapp/api/common.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Utils {
  static Future<T> showDialogAnimated<T>(
    BuildContext context,
    T def, {
    required Widget content,
    required List<Widget> actions,
    bool dismissable = false,
  }) {
    return showGeneralDialog<T>(
      context: context,
      barrierLabel: 'animated-dialog',
      barrierDismissible: dismissable,
      pageBuilder: (context, _, __) => AlertDialog(
        content: SingleChildScrollView(
          child: content,
        ),
        actions: actions,
      ),
      transitionBuilder: (_, anim, __, child) {
        final animation = CurvedAnimation(
          parent: anim,
          curve: Curves.easeInOutCubic,
        );

        return SlideTransition(
          position: Tween(
            begin: const Offset(0, 1),
            end: const Offset(0, 0),
          ).animate(animation),
          child: child,
        );
      },
    ).then((res) => res ?? def);
  }

  static void alertUser(
    BuildContext context,
    String message, {
    bool snackBar = true,
  }) {
    if (snackBar) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } else {
      showDialogAnimated(
        context,
        null,
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      );
    }
  }

  static Future<bool> promptUser(BuildContext context, String message) {
    return showDialogAnimated(
      context,
      false,
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('NEM'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text('IGEN'),
        ),
      ],
    );
  }

  static Future<String?> readString(String key) async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getString(key);
  }

  static Future<void> writeString(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(key, value);
  }

  static Future<void> deleteString(String key) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove(key);
  }

  static Future<T> tryRequest<T>(
    BuildContext context,
    Future<T> Function() call,
    T fallback, {
    bool snackbar = true,
  }) async {
    try {
      return await call();
    } on StateError {
      // Element is no longer visible, blah blah we don't care
    } on SocketException {
      alertUser(
        context,
        'A LogiNext nem érhető el, ellenőrizd az internetkapcsolatod',
        snackBar: snackbar,
      );
    } on UnauthorizedException {
      final nav = Navigator.of(context);
      await Fluttertoast.showToast(
        msg: 'Megszakadt a kapcsolat, kérlek jelentkezz be újra',
        backgroundColor: Theme.of(context).colorScheme.inverseSurface,
        textColor: Theme.of(context).colorScheme.inversePrimary,
      );

      nav.popUntil((route) => !route.isFirst);
      nav.pushReplacementNamed('/login');
    } catch (e) {
      log('Unknown error ocurred during login', error: e);

      alertUser(context, 'Ismeretlen hiba történt', snackBar: snackbar);
    }

    return Future.value(fallback);
  }

  static String formatDate(DateTime date) {
    final f = NumberFormat('00');

    return '${f.format(date.month)}/${f.format(date.day)} ${f.format(date.hour)}:${f.format(date.minute)}';
  }
}
