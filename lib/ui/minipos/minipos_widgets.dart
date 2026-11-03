import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:waioz/utility/app_colors.dart';
import 'package:waioz/utility/app_utils.dart';

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
        scaffoldBackgroundColor: const Color(0xFFF5FEF2),
        // Green header on every MiniPOS page, matching the MiniPOS home.
        appBarTheme: theme.appBarTheme.copyWith(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          iconTheme: const IconThemeData(color: Colors.white),
          actionsIconTheme: const IconThemeData(color: Colors.white),
          titleTextStyle: theme.textTheme.titleLarge
              ?.copyWith(color: Colors.white, fontWeight: FontWeight.w600),
          systemOverlayStyle: SystemUiOverlayStyle.light,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
        ),
        cardTheme: theme.cardTheme.copyWith(
          color: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: AppColors.primary),
          ),
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
  const MiniPosScaffold({super.key, this.appBar, required this.body});

  @override
  Widget build(BuildContext context) => MiniPosTheme(
        child: Scaffold(
          appBar: appBar,
          body: Container(
            decoration: const BoxDecoration(gradient: AppColors.linearGradient),
            child: body,
          ),
        ),
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

String miniPosOrderLabel(Map<String, dynamic> order) {
  final displayId = order['display_id'];
  if (displayId is num && displayId > 0) return '#${displayId.toInt()}';
  final legacy = '${order['order_number'] ?? ''}'.trim();
  return legacy.isEmpty ? '—' : legacy;
}

/// Short toast, the same as the rest of the app.
void miniPosMessage(BuildContext context, Object message) {
  AppUtils.showToast(message.toString());
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
