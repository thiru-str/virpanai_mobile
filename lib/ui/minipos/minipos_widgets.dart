import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:waioz/utility/app_colors.dart';

/// Use the app's brand palette for MiniPOS controls and dialogs.
class MiniPosTheme extends StatelessWidget {
  final Widget child;
  const MiniPosTheme({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = ColorScheme.fromSeed(seedColor: AppColors.primary).copyWith(
      primary: AppColors.primary,
      onPrimary: Colors.white,
      secondary: AppColors.primary,
      onSecondary: Colors.white,
      surface: Colors.white,
      onSurface: AppColors.textColor,
    );
    return Theme(
      data: theme.copyWith(
        colorScheme: scheme,
        primaryColor: AppColors.primary,
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: theme.appBarTheme.copyWith(
          backgroundColor: Colors.white,
          foregroundColor: AppColors.textColor,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
        ),
        cardTheme: theme.cardTheme.copyWith(
          color: Colors.white,
          surfaceTintColor: Colors.transparent,
        ),
        dialogTheme: theme.dialogTheme.copyWith(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
        ),
        progressIndicatorTheme:
            ProgressIndicatorThemeData(color: AppColors.primary),
        textSelectionTheme: TextSelectionThemeData(
          cursorColor: AppColors.primary,
          selectionColor: AppColors.primary.withValues(alpha: 0.2),
          selectionHandleColor: AppColors.primary,
        ),
      ),
      child: child,
    );
  }
}

class MiniPosScaffold extends StatelessWidget {
  final PreferredSizeWidget? appBar;
  final Widget body;
  final Color? backgroundColor;
  const MiniPosScaffold(
      {super.key, this.appBar, required this.body, this.backgroundColor});

  @override
  Widget build(BuildContext context) => MiniPosTheme(
        child: Scaffold(
            appBar: appBar, body: body, backgroundColor: backgroundColor),
      );
}

class MiniPosUnavailable extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const MiniPosUnavailable(
      {super.key, required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) => Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          MiniPosEmpty(
              icon: Icons.storefront_outlined,
              title: 'MiniPOS unavailable',
              message: message),
          OutlinedButton(onPressed: onRetry, child: const Text('Retry')),
        ]),
      );
}

String miniPosMoney(dynamic paise) => NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 2,
    ).format((num.tryParse('$paise') ?? 0) / 100);

void miniPosMessage(BuildContext context, Object message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
        backgroundColor: AppColors.textColor,
        content: Text(message.toString(),
            style: const TextStyle(color: Colors.white)),
        behavior: SnackBarBehavior.floating),
  );
}

class MiniPosEmpty extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  const MiniPosEmpty(
      {super.key,
      required this.icon,
      required this.title,
      required this.message});
  @override
  Widget build(BuildContext context) => Center(
          child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 54, color: AppColors.primary),
          const SizedBox(height: 16),
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.black54)),
        ]),
      ));
}
