import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:waioz/utility/app_strings.dart';

class VersionUtils {
  static Future<Map<String, dynamic>> parseVersionConfig(String versionCheckJson) async {
    try {
      // remove any trailing commas before }
      final fixedJson = versionCheckJson.replaceAll(RegExp(r',\s*}'), '}');

      return jsonDecode(fixedJson);
    } catch (e) {
      debugPrint("❌ Failed to parse version_check: $e");
      return {};
    }
  }


  static Future<String> getCurrentAppVersion() async {
    final info = await PackageInfo.fromPlatform();
    return info.version; // e.g. "1.2.0"
  }

  static Future<int> getCurrentBuildNumber() async {
    final info = await PackageInfo.fromPlatform();
    return int.tryParse(info.buildNumber) ?? 0; // e.g. 12
  }

  static Future<void> launchPlayStore({String packageName = AppStrings.androidPackage}) async {
    final url = Uri.parse("https://play.google.com/store/apps/details?id=$packageName");
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      throw "Could not launch $url";
    }
  }

  static Future<void> launchAppStore({String appId = AppStrings.appId}) async {
    final url = Uri.parse("https://apps.apple.com/app/id$appId");
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      throw "Could not launch $url";
    }
  }

}
