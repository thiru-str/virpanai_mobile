import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:waioz/api/api_service.dart';
import 'package:waioz/ui/bottom_nav_page.dart';
import 'package:waioz/ui/soft_update_bottom_sheet.dart';
import 'package:waioz/ui/welcome_page.dart';
import '../api/push_notification_service.dart';
import '../model/public_detail_model.dart';
import '../utility/shared_preferences_util.dart';

import '../utility/version_utils.dart';
import 'force_update_page.dart';

class SplashPage extends StatefulWidget {
  final bool skipLogin;
  final PublicDetailsResponse? publicDetailsResponse;
  const SplashPage(
      {super.key, this.skipLogin = false, this.publicDetailsResponse});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  bool _resolvedSkipLogin = false;

  @override
  void initState() {
    super.initState();

    Future.microtask(() async {
      await PushNotificationService().initialize(context);
    });

    navToNextPage();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF3EAA3C),
      body: Stack(
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Image.asset(
                'images/annachi_logo.png',
                fit: BoxFit.contain,
              ),
            ),
          ),
          const Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: EdgeInsets.only(bottom: 56),
              child: SizedBox(
                height: 22,
                width: 22,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void navToNextPage() async {
    final results = await Future.wait([
      _resolvePublicDetails(),
      Future.delayed(const Duration(seconds: 1)),
    ]);
    final publicDetails = results[0] as PublicDetailsResponse?;
    _resolvedSkipLogin =
        publicDetails?.storeDetails?.storeMetadata?.skipLogin ??
            widget.skipLogin;

    final versionCheckJson =
        publicDetails?.storeDetails?.storeMetadata?.versionCheck;

    debugPrint('min build calling ${versionCheckJson}');

    if (versionCheckJson != null && versionCheckJson.isNotEmpty) {
      final versionConfig =
          await VersionUtils.parseVersionConfig(versionCheckJson);

      final bool forceUpdate = versionConfig['force_update'] ?? false;
      final androidConfig = versionConfig['android'];
      final iosConfig = versionConfig['ios'];
      final storeUrl = Platform.isAndroid
          ? versionConfig['play_store_url']?.toString()
          : versionConfig['app_store_url']?.toString();

      if (Platform.isAndroid) {
        final currentBuild = await VersionUtils.getCurrentBuildNumber();
        final minBuild = androidConfig['min_version_code'];
        final latestBuild = androidConfig['current_version_code'];

        if (currentBuild < minBuild) {
          _showForceUpdate(storeUrl);
          return;
        } else if (currentBuild < latestBuild) {
          if (forceUpdate) {
            _showForceUpdate(storeUrl);
          } else {
            _showSoftUpdate(storeUrl);
          }
          return;
        }
      } else if (Platform.isIOS) {
        final currentVersion = await VersionUtils.getCurrentAppVersion();
        final minVersion = iosConfig['min_version'];
        final latestVersion = iosConfig['current_version'];

        if (_isVersionLower(currentVersion, minVersion)) {
          _showForceUpdate(storeUrl);
          return;
        } else if (_isVersionLower(currentVersion, latestVersion)) {
          if (forceUpdate) {
            _showForceUpdate(storeUrl);
          } else {
            _showSoftUpdate(storeUrl);
          }
          return;
        }
      }
    } else {
      debugPrint('min build calling');
    }

    _navigateToHome(skipLogin: _resolvedSkipLogin);
  }

  Future<PublicDetailsResponse?> _resolvePublicDetails() async {
    final prefs = SharedPreferencesUtil();
    final cachedPublicDetails =
        widget.publicDetailsResponse ?? await prefs.getPublicDetails();

    final hasSkipLogin = await prefs.containsKey('skip_login');
    if (cachedPublicDetails != null && hasSkipLogin) {
      return cachedPublicDetails;
    }

    try {
      final freshPublicDetails = await ApiService().getPublicDetails();
      await prefs.savePublicDetails(freshPublicDetails);
      return freshPublicDetails;
    } catch (_) {
      return cachedPublicDetails;
    }
  }

  Future<void> _openStore(BuildContext updateContext, String? storeUrl) async {
    final launched = await VersionUtils.launchStore(storeUrl);
    if (!launched && updateContext.mounted) {
      ScaffoldMessenger.of(updateContext).showSnackBar(
        const SnackBar(
          content: Text('The app store link is not configured correctly.'),
        ),
      );
    }
  }

  void _showForceUpdate(String? storeUrl) {
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (updateContext) => ForceUpdateScreen(
            onUpdateNow: () => _openStore(updateContext, storeUrl),
          ),
        ),
      );
    }
  }

  void _showSoftUpdate(String? storeUrl) {
    if (mounted) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        isDismissible: false,
        enableDrag: false,
        builder: (updateContext) => SoftUpdateBottomSheet(
          onUpdateNow: () => _openStore(updateContext, storeUrl),
          onContinue: () {
            Navigator.pop(context);
            _navigateToHome(skipLogin: _resolvedSkipLogin);
          },
        ),
      );
    }
  }

  bool _isVersionLower(String current, String latest) {
    final currentParts = current.split('.').map(int.parse).toList();
    final latestParts = latest.split('.').map(int.parse).toList();

    for (int i = 0; i < latestParts.length; i++) {
      final cur = (i < currentParts.length) ? currentParts[i] : 0;
      final lat = latestParts[i];
      if (cur < lat) return true;
      if (cur > lat) return false;
    }
    return false;
  }

  void _navigateToHome({required bool skipLogin}) async {
    String? token = await SharedPreferencesUtil().getString('token');
    Widget nextPage = token == null
        ? skipLogin
            ? const BottomNavPage()
            : WelcomePage()
        : const BottomNavPage();

    if (mounted) {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => nextPage,
          transitionDuration: Duration.zero,
          reverseTransitionDuration: Duration.zero,
        ),
      );
    }
  }

}
