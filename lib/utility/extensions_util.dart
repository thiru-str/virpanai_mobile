import 'shared_preferences_util.dart';

/// Synchronous read-only cache of installed extension slugs.
/// Populated once on app startup from /public/details — see ExtensionsUtil.refresh().
/// Widgets and pages should call ExtensionsUtil.has('loyalty') to gate UI.
class ExtensionsUtil {
  static List<String> _enabled = const [];

  static List<String> get enabled => _enabled;

  static bool has(String slug) => _enabled.contains(slug);

  /// Re-read the list from cached public_details. Call after /public/details
  /// is fetched and saved to SharedPreferences, and on app resume.
  static Future<void> refresh() async {
    try {
      final details = await SharedPreferencesUtil().getPublicDetails();
      _enabled = details?.enabledExtensions ?? const [];
    } catch (_) {
      _enabled = const [];
    }
  }
}
