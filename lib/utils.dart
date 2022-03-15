import 'dart:developer';
import 'dart:io';

import 'package:deliapp/api/common.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Utils {
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
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          content: SingleChildScrollView(
            child: Text(message),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Ok"),
            ),
          ],
        ),
      );
    }
  }

  static Future<bool> promptUser(BuildContext context, String message) async {
    final res = await showGeneralDialog<bool>(
      context: context,
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (context, _, __) => AlertDialog(
        content: SingleChildScrollView(
          child: Text(message),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Nem'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Igen'),
          ),
        ],
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
    );

    return res ?? false;
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
    void Function(Object)? errorCallback,
  }) async {
    try {
      return await call();
    } on SocketException {
      alertUser(
        context,
        "A LogiNext nem érhető el, ellenőrizd az internetkapcsolatod",
        snackBar: snackbar,
      );
    } on UnauthorizedException {
      alertUser(
        context,
        "A belépés már nem érvényes, próbálj meg bejelentkezni újra",
        snackBar: snackbar,
      );

      errorCallback?.call(UnauthorizedException());
    } catch (e) {
      log("Unknown error ocurred during login", error: e);

      errorCallback?.call(e);

      alertUser(context, "Ismeretlen hiba történt", snackBar: snackbar);
    }

    return Future.value(fallback);
  }
}
