import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class VersionUtils {
  static Future<Map<String, dynamic>> parseVersionConfig(
      String versionCheckJson) async {
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

  static Future<bool> launchStore(String? configuredUrl) async {
    final value = configuredUrl?.trim() ?? '';
    final url = Uri.tryParse(value);
    const allowedSchemes = {'https', 'http', 'market', 'itms-apps'};

    if (url == null ||
        value.isEmpty ||
        !url.hasScheme ||
        !allowedSchemes.contains(url.scheme.toLowerCase())) {
      debugPrint('Store URL is missing or invalid: $value');
      return false;
    }

    try {
      return await launchUrl(url, mode: LaunchMode.externalApplication);
    } catch (error) {
      debugPrint('Could not launch store URL $url: $error');
      return false;
    }
  }
}
