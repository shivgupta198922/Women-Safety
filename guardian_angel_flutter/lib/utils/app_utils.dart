import 'package:flutter/material.dart';

class AppUtils {
  static void showSnackBar(BuildContext context, String message, {bool isError = false}) {
    if (!context.mounted) return; // Ensure context is still valid

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red.shade700 : Colors.green.shade700,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(10),
      ),
    );
  }
}