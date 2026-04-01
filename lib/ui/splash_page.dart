

import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:waioz/model/public_detail_model.dart';
import 'package:waioz/ui/bottom_nav_page.dart';
import 'package:waioz/ui/welcome_page.dart';
import 'package:waioz/ui/widgets/soft_update_bottom_sheet.dart';
import 'package:waioz/utility/app_assets.dart';
import 'package:waioz/utility/app_colors.dart';
import 'package:waioz/utility/page_route_utils.dart';

import '../api/push_notification_service.dart';
import '../api/api_service.dart';
import '../utility/app_logger.dart';
import '../utility/font_utils.dart';
import '../utility/shared_preferences_util.dart';


import '../utility/version_utils.dart';
import 'force_update_page.dart';

class SplashPage extends StatefulWidget {
  final bool skipLogin;
  final PublicDetailsResponse? publicDetailsResponse;
  final String? startupError;
  const SplashPage({
    super.key,
    this.skipLogin = false,
    this.publicDetailsResponse,
    this.startupError,
  });

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  late PublicDetailsResponse? _publicDetailsResponse;
  String? _startupError;

  @override
  void initState() {
    super.initState();
    _publicDetailsResponse = widget.publicDetailsResponse;
    _startupError = widget.startupError;
    Future.microtask(() async {
      await PushNotificationService().initialize(context);
    });

    // Initialize animation controller
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    // Define animation (zoom in)
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );

    // Start the animation
    _controller.forward();

    if (_publicDetailsResponse != null) {
      navToNextPage();
    } else if (_startupError != null) {
      AppLogger.warning('Startup blocked because public details are unavailable: $_startupError');
    }
  }

  @override
  Widget build(BuildContext context) {

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.white,
      ),
    );

    return Scaffold(
      body: Container(
        color: Colors.white,
        child: Center(child: _buildBody()),
      ),
    );
  }

  Widget _buildBody() {
    if (_publicDetailsResponse != null) {
      return SvgPicture.asset(AppAssets.app_logo,height: 250,);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(AppAssets.app_logo, height: 180),
          const SizedBox(height: 32),
          Text(
            'Something went wrong.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            _startupError ?? 'Unknown startup exception while loading public/details.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  void navToNextPage() async {
    final versionCheckJson = _publicDetailsResponse
        ?.storeDetails
        ?.storeMetadata
        ?.versionCheck;

    debugPrint('min build calling ${versionCheckJson}');


    if (versionCheckJson != null && versionCheckJson.isNotEmpty) {
      final versionConfig = await VersionUtils.parseVersionConfig(versionCheckJson);

      final bool forceUpdate = versionConfig['force_update'] ?? false;
      final androidConfig = versionConfig['android'];
      final iosConfig = versionConfig['ios'];

      if (Platform.isAndroid) {
        final currentBuild = await VersionUtils.getCurrentBuildNumber();
        final minBuild = androidConfig['min_version_code'];
        final latestBuild = androidConfig['current_version_code'];

        if (currentBuild < minBuild) {
          _showForceUpdate();
          return;
        } else if (currentBuild < latestBuild && !forceUpdate) {
          _showSoftUpdate();
          return;
        }
      } else if (Platform.isIOS) {
        final currentVersion = await VersionUtils.getCurrentAppVersion();
        final minVersion = iosConfig['min_version'];
        final latestVersion = iosConfig['current_version'];

        if (_isVersionLower(currentVersion, minVersion)) {
          _showForceUpdate();
          return;
        } else if (_isVersionLower(currentVersion, latestVersion) && !forceUpdate) {
          _showSoftUpdate();
          return;
        }
      }
    }
    else{
      debugPrint('min build calling');
    }

    _navigateToHome();
  }

  void _openStore() {
    if (Platform.isAndroid) {
      VersionUtils.launchPlayStore();
    } else if (Platform.isIOS) {
      VersionUtils.launchAppStore();
    }
  }

  void _showForceUpdate() {
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ForceUpdateScreen(
            onUpdateNow: _openStore,
          ),
        ),
      );
    }
  }

  void _showSoftUpdate() {
    if (mounted) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        isDismissible: false,
        enableDrag: false,
        builder: (_) => SoftUpdateBottomSheet(
          onUpdateNow: _openStore,
          onContinue: () {
            Navigator.pop(context);
            _navigateToHome();
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

  void _navigateToHome() async {
    String? token = await SharedPreferencesUtil().getString('token');
    Widget nextPage = token == null
        ? widget.skipLogin ? const BottomNavPage() : WelcomePage()
        : const BottomNavPage();

    if (mounted) {
      PageRouteUtils.pushWithZoom(context, nextPage);
    }
  }




  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
