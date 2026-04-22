import 'package:flutter/material.dart';

class AppUtils {
  static final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  static bool _isSosDialogVisible = false;

  static void showSnackBar(BuildContext context, String message, {bool isError = false}) {
    if (!context.mounted) return; // Ensure context is still valid

    ScaffoldMessenger.of(context).showSnackBar(
      _buildSnackBar(message, isError: isError),
    );
  }

  static void showGlobalSnackBar(String message, {bool isError = false}) {
    final messenger = scaffoldMessengerKey.currentState;
    if (messenger == null) return;

    messenger.showSnackBar(_buildSnackBar(message, isError: isError));
  }

  static Future<void> showGlobalSosDialog({
    required String title,
    required String message,
  }) async {
    final context = navigatorKey.currentContext;
    if (context == null || _isSosDialogVisible) return;

    _isSosDialogVisible = true;

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: const [
              Icon(Icons.warning_rounded, color: Colors.red),
              SizedBox(width: 10),
              Expanded(child: Text('Emergency Alert')),
            ],
          ),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );

    _isSosDialogVisible = false;
  }

  static SnackBar _buildSnackBar(String message, {bool isError = false}) {
    return SnackBar(
      content: Text(message),
      backgroundColor: isError ? Colors.red.shade700 : Colors.green.shade700,
      duration: const Duration(seconds: 3),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: const EdgeInsets.all(10),
    );
  }
}
