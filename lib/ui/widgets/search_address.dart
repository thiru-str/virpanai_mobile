import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../../api/api_service.dart';
import '../../model/address_list_response.dart';
import '../../model/register_response.dart';
import '../../ui/bottom_nav_page.dart';
import '../../utility/app_colors.dart';
import '../../utility/app_config.dart';
import '../../utility/app_strings.dart';
import '../../utility/app_utils.dart';
import '../../utility/font_utils.dart';
import '../../utility/location_util.dart';
import '../../utility/page_route_utils.dart';
import '../../utility/shared_preferences_util.dart';
import '../add_address_page.dart';
import '../map_page.dart';
import 'common_header_app_bar.dart';

/// Address picker / manager — single screen for:
///  - typing a search query (Google Places autocomplete)
///  - using current location (MapPage / AddAddressPage based on
///    admin's `google_map_usage` flag)
///  - adding a new address manually
///  - picking from saved addresses
class SearchAddressPage extends StatefulWidget {
  /// If provided, picking a saved address triggers this callback and pops.
  /// If null, picking a saved address is a no-op (browsing only).
  final Function(Address selectedAddress)? onTapAddress;
  final bool isMandatory;
  final Widget? redirectPage;

  const SearchAddressPage({
    super.key,
    this.onTapAddress,
    this.isMandatory = false,
    this.redirectPage,
  });

  @override
  State<SearchAddressPage> createState() => _SearchAddressPageState();
}

class _SearchAddressPageState extends State<SearchAddressPage> {
  final TextEditingController _searchCtrl = TextEditingController();
  final Dio _dio = Dio();
  final ApiService _api = ApiService();

  List<dynamic> _predictions = [];
  bool _isSearching = false;
  bool _useMapPicker = false;
  bool _isLoggedIn = false;

  GetAddressListResponse? _addressList;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadGoogleMapUsage();
    _fetchSavedAddresses();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadGoogleMapUsage() async {
    final value =
        (await SharedPreferencesUtil().getBool('google_map_usage')) ?? false;
    if (!mounted) return;
    setState(() => _useMapPicker = value);
  }

  Future<void> _fetchSavedAddresses() async {
    final isLoggedIn = await AppUtils.isLoggedIn();
    if (!isLoggedIn) {
      if (!mounted) return;
      setState(() {
        _isLoggedIn = false;
        _loading = false;
      });
      return;
    }

    try {
      final response = await _api.getAddressList(context);
      if (!mounted) return;
      setState(() {
        _isLoggedIn = true;
        _addressList = response;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  Future<void> _onSearchChanged(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _predictions = [];
        _isSearching = false;
      });
      return;
    }
    setState(() => _isSearching = true);

    try {
      final position = await LocationUtil.getApproximateLocation();
      String? locationParam;
      if (position != null) {
        locationParam = '${position.latitude},${position.longitude}';
      }
      final response = await _dio.get(
        'https://maps.googleapis.com/maps/api/place/autocomplete/json',
        queryParameters: {
          'input': query,
          'key': AppConfig.googleApiKey,
          if (locationParam != null) 'location': locationParam,
          if (locationParam != null) 'radius': 30000,
        },
      );
      if (response.statusCode == 200 && mounted) {
        setState(() => _predictions = response.data['predictions'] ?? []);
      }
    } catch (_) {/* ignore */}
  }

  Future<void> _openPlace(String placeId, String description) async {
    try {
      final response = await _dio.get(
        'https://maps.googleapis.com/maps/api/place/details/json',
        queryParameters: {
          'place_id': placeId,
          'key': AppConfig.googleApiKey,
        },
      );
      if (response.statusCode != 200) return;
      final loc = response.data['result']?['geometry']?['location'];
      final lat = (loc?['lat'] as num?)?.toDouble();
      final lng = (loc?['lng'] as num?)?.toDouble();
      if (lat == null || lng == null || !mounted) return;
      final result = await PageRouteUtils.push(
        context,
        MapPage(
          latitude: lat,
          longitude: lng,
          intent: MapPageIntent.selectActive,
        ),
      );
      if (result is Map<String, dynamic> && mounted) {
        _completeLocationSelection(result);
      }
    } catch (_) {/* ignore */}
  }

  Future<void> _useCurrentLocation() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Location permission denied. Please enable in settings.'),
      ));
      return;
    }
    if (!mounted) return;
    final result = await PageRouteUtils.push(
      context,
      MapPage(intent: MapPageIntent.selectActive),
    );
    if (result is Map<String, dynamic> && mounted) {
      _completeLocationSelection(result);
    }
  }

  Future<void> _addNewManually() async {
    final result = await PageRouteUtils.push(
      context,
      _useMapPicker
          ? MapPage(
              doublePop: true,
              intent: MapPageIntent.saveAddress,
            )
          : AddAddressPage(),
    );
    if (result == true) _fetchSavedAddresses();
  }

  Future<void> _pickSaved(Address address) async {
    if (!mounted) return;
    if (widget.onTapAddress != null) {
      widget.onTapAddress!(address);
    }
    _completeLocationSelection(address.toJson());
  }

  Future<void> _completeLocationSelection(Map<String, dynamic> address) async {
    if (!mounted) return;

    if (!widget.isMandatory) {
      Navigator.of(context).pop(address);
      return;
    }

    await SharedPreferencesUtil().saveMap('selected_address', address);
    if (!mounted) return;
    PageRouteUtils.pushAndRemoveUntil(
      context,
      widget.redirectPage ?? const BottomNavPage(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !widget.isMandatory,
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: CommonHeaderAppBar(
            title: AppStrings.your_location,
            leading: !widget.isMandatory,
            onBackTap: () => Navigator.of(context).pop(),
          ),
          body: Column(
            children: [
              _searchBar(),
              Expanded(
                child: _isSearching ? _searchResults() : _defaultBody(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Search bar ────────────────────────────────────────────────────────────
  Widget _searchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: TextField(
        controller: _searchCtrl,
        onChanged: _onSearchChanged,
        style: FontUtils.primaryFontStyle(fontSize: 14),
        decoration: InputDecoration(
          prefixIcon: Icon(Icons.search, color: Colors.grey.shade500),
          hintText: AppStrings.show_new_address,
          hintStyle: FontUtils.primaryFontStyle(
              fontSize: 14, color: Colors.grey.shade400),
          filled: true,
          fillColor: const Color(0xFFF5F5F7),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.primary, width: 1.2),
          ),
          suffixIcon: _searchCtrl.text.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.clear, color: Colors.grey.shade500),
                  onPressed: () {
                    _searchCtrl.clear();
                    setState(() {
                      _predictions = [];
                      _isSearching = false;
                    });
                  },
                )
              : null,
        ),
      ),
    );
  }

  // ── Default body (no search) ──────────────────────────────────────────────
  Widget _defaultBody() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
      children: [
        _ActionTile(
          icon: Icons.my_location_rounded,
          title: AppStrings.current_location,
          subtitle: AppStrings.location_mode,
          accent: AppColors.primary,
          onTap: _useCurrentLocation,
        ),
        if (_isLoggedIn) ...[
          const SizedBox(height: 10),
          _ActionTile(
            icon: Icons.add_location_alt_rounded,
            title: 'Add new address',
            subtitle: _useMapPicker ? 'Pin on map' : 'Type address details',
            accent: AppColors.primary,
            onTap: _addNewManually,
          ),
          const SizedBox(height: 22),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: Text(
              AppStrings.saved_location,
              style: FontUtils.primaryFontStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade600,
              ),
            ),
          ),
          const SizedBox(height: 10),
          _savedAddressList(),
        ],
      ],
    );
  }

  Widget _savedAddressList() {
    if (_loading) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
      );
    }
    final addresses = _addressList?.addresses ?? [];
    if (addresses.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Center(
          child: Text(
            AppStrings.no_saved_location,
            style: FontUtils.primaryFontStyle(
                fontSize: 13, color: Colors.grey.shade500),
          ),
        ),
      );
    }
    return Column(
      children: [
        for (final a in addresses) ...[
          _SavedAddressCard(
            address: a,
            onTap: () => _pickSaved(a),
          ),
          const SizedBox(height: 8),
        ],
      ],
    );
  }

  // ── Search results body ───────────────────────────────────────────────────
  Widget _searchResults() {
    if (_predictions.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Text(
            'No matching places. Try a different search.',
            style: FontUtils.primaryFontStyle(
                fontSize: 13, color: Colors.grey.shade500),
          ),
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(8, 4, 8, 24),
      itemCount: _predictions.length,
      separatorBuilder: (_, __) =>
          Divider(height: 1, color: Colors.grey.shade100),
      itemBuilder: (_, i) {
        final p = _predictions[i];
        final structured = p['structured_formatting'] as Map<String, dynamic>?;
        final main = (structured?['main_text'] ?? p['description'] ?? '') as String;
        final secondary =
            (structured?['secondary_text'] ?? '') as String;
        return InkWell(
          onTap: () => _openPlace(p['place_id'], p['description']),
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
            child: Row(
              children: [
                Icon(Icons.location_on_outlined,
                    color: AppColors.primary, size: 22),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        main,
                        style: FontUtils.primaryFontStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textColor),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (secondary.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          secondary,
                          style: FontUtils.primaryFontStyle(
                              fontSize: 12, color: Colors.grey.shade500),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ── Action tile (current location, add new) ─────────────────────────────────
class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color accent;
  final VoidCallback onTap;

  const _ActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.accent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200, width: 1),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: accent, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(title,
                      style: FontUtils.primaryFontStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textColor)),
                  const SizedBox(height: 2),
                  Text(subtitle,
                      style: FontUtils.primaryFontStyle(
                          fontSize: 12, color: Colors.grey.shade500)),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey.shade400, size: 20),
          ],
        ),
      ),
    );
  }
}

// ── Saved address card ──────────────────────────────────────────────────────
class _SavedAddressCard extends StatelessWidget {
  final Address address;
  final VoidCallback onTap;

  const _SavedAddressCard({required this.address, required this.onTap});

  IconData get _icon {
    final name = (address.addressName ?? '').toLowerCase();
    if (name == 'home') return Icons.home_rounded;
    if (name == 'work') return Icons.work_outline_rounded;
    return Icons.location_on_outlined;
  }

  String get _label =>
      (address.addressName?.trim().isNotEmpty ?? false)
          ? address.addressName!
          : 'Other';

  String get _fullAddress {
    final parts = [
      address.address1,
      address.city,
      address.province,
      address.postalCode,
    ].where((s) => (s ?? '').trim().isNotEmpty).cast<String>();
    return parts.join(', ');
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200, width: 1),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 36,
              height: 36,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(_icon, color: AppColors.primary, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(_label,
                      style: FontUtils.primaryFontStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textColor)),
                  const SizedBox(height: 2),
                  Text(
                    _fullAddress,
                    style: FontUtils.primaryFontStyle(
                        fontSize: 12.5, color: Colors.grey.shade600),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
