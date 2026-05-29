import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'dart:async';

import 'package:waioz/ui/widgets/common_header_app_bar.dart';
import 'package:waioz/utility/app_colors.dart';
import 'package:waioz/utility/app_strings.dart';
import 'package:waioz/utility/font_utils.dart';
import 'package:waioz/utility/shared_preferences_util.dart';

import '../model/register_response.dart';
import '../utility/page_route_utils.dart';
import 'add_address_page.dart';

/// What the user is trying to accomplish on MapPage.
/// Decides what Confirm does:
///  - [selectActive]: pick a location to use NOW. Saves to `selected_address`
///    prefs and pops back to caller. No form, no permanent save.
///  - [saveAddress]: continue to AddAddressPage to fill name/phone and save
///    permanently. Used for "Add new" and "Edit" flows.
enum MapPageIntent { selectActive, saveAddress }

class MapPage extends StatefulWidget {
  final latitude;
  final longitude;
  final bool doublePop;
  final bool isEditAddress;
  final Address? selectedAddress;
  final MapPageIntent intent;

  const MapPage(
      {super.key,
      this.latitude = 0.0,
      this.longitude = 0.0,
      this.doublePop = false,
      this.isEditAddress = false,
      this.selectedAddress,
      this.intent = MapPageIntent.saveAddress});

  //ScreenFrom
  // 1-> Home page
  // 2-> Menu Address page

  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final Completer<GoogleMapController> _controller = Completer();
  LatLng? _currentPosition;
  String _currentAddress = AppStrings.fetching_address;
  String _mainAddress = AppStrings.fetching_address;
  Marker? _marker;
  Placemark? place;

  @override
  void initState() {
    super.initState();
    requestLocationPermission();
    if (widget.isEditAddress) {
      print("Selected address: ${jsonEncode(widget.selectedAddress)}");
    }
    if (widget.latitude == 0.0 && widget.longitude == 0.0) {
      _getCurrentLocation();
    } else {
      _updateCustomLocation();
    }
  }

  /// Get Current Location
  Future<void> _getCurrentLocation() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();
    }

    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best);

    setState(() {
      _currentPosition = LatLng(position.latitude, position.longitude);
      _marker = Marker(
        markerId: MarkerId("currentLocation"),
        position: _currentPosition!,
        infoWindow: InfoWindow(title: AppStrings.your_location_map),
      );
    });

    _moveCameraToPosition(_currentPosition!);
    _getAddressFromLatLng(_currentPosition!);
  }

  Future<void> _updateCustomLocation() async {
    setState(() {
      _currentPosition = LatLng(widget.latitude, widget.longitude);
      _marker = Marker(
        markerId: MarkerId("currentLocation"),
        position: _currentPosition!,
        infoWindow: InfoWindow(title: AppStrings.your_location_map),
      );
    });

    _moveCameraToPosition(_currentPosition!);
    _getAddressFromLatLng(_currentPosition!);
  }

  /// Move Camera to Position
  Future<void> _moveCameraToPosition(LatLng position) async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(target: position, zoom: 20, tilt: 45),
    ));
  }

  /// Get Address from LatLng
  Future<void> _getAddressFromLatLng(LatLng position) async {
    try {
      List<Placemark> placemarks =
          await placemarkFromCoordinates(position.latitude, position.longitude);

      if (placemarks.isNotEmpty) {
        place = placemarks.first;

        List<String?> fullAddressParts = [
          place?.street,
          place?.locality,
          place?.administrativeArea,
          place?.postalCode,
          place?.country
        ].where((element) => element != null && element.isNotEmpty).toList();

        List<String?> mainAddressParts = [place?.name, place?.thoroughfare]
            .where((element) => element != null && element.isNotEmpty)
            .toList();

        setState(() {
          _currentAddress = fullAddressParts.join(", ");
          _mainAddress = mainAddressParts.join(", ");
        });
      }
    } catch (e) {
      print("Error getting address: $e");
    }
  }

  /// Update Marker & Address on Map Drag
  void _onCameraMove(CameraPosition position) {
    setState(() {
      _marker = Marker(
        markerId: MarkerId("movedLocation"),
        position: position.target,
        infoWindow: InfoWindow(title: AppStrings.selected_location),
      );
    });
  }

  void _onCameraIdle() async {
    if (_marker != null) {
      _getAddressFromLatLng(_marker!.position);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonHeaderAppBar(
        title: AppStrings.address,
        onBackTap: () {
          Navigator.of(context).pop();
        },
      ),
      backgroundColor: Colors.white,
      body: _currentPosition == null
          ? Center(
              child: CircularProgressIndicator(
              color: AppColors.primary,
            ))
          : Stack(
              children: [
                GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: _currentPosition!,
                    zoom: 15,
                  ),
                  markers: _marker != null ? {_marker!} : {},
                  onMapCreated: (GoogleMapController controller) {
                    _controller.complete(controller);
                  },
                  onCameraMove: _onCameraMove,
                  onCameraIdle: _onCameraIdle,
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _mainAddress, // Static location name or fetched dynamically
                          style: FontUtils.primaryFontStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textColor,
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          _currentAddress, // Dynamic address fetched from Geocoder
                          style: FontUtils.primaryFontStyle(
                            fontSize: 14,
                            color: Colors.grey[600]!,
                          ),
                        ),
                        SizedBox(height: 5),
                        SizedBox(height: 15),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              padding: EdgeInsets.symmetric(vertical: 15),
                            ),
                            onPressed: _onConfirm,
                            child: Text(
                              AppStrings.confirm_continue,
                              style: FontUtils.secondaryFontStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Future<void> _onConfirm() async {
    if (widget.intent == MapPageIntent.selectActive) {
      await _persistAsActive();
      if (!mounted) return;
      Navigator.of(context).pop(true);
      return;
    }
    // saveAddress — continue to AddAddressPage form
    PageRouteUtils.pushWithSlide(
      context,
      AddAddressPage(
        isFromMap: true,
        place: place,
        currentPosition: _currentPosition,
        doublePop: widget.doublePop,
        selectedAddress: widget.selectedAddress,
      ),
    );
  }

  /// Persist the picked location as the active delivery address (session-level,
  /// NOT a saved address). Home header + location-aware APIs read this from
  /// SharedPreferences under `selected_address`.
  Future<void> _persistAsActive() async {
    final lat = _currentPosition?.latitude;
    final lng = _currentPosition?.longitude;
    if (lat == null || lng == null) return;

    final address1Parts = [place?.name, place?.thoroughfare, place?.subLocality]
        .where((e) => (e ?? '').trim().isNotEmpty)
        .cast<String>()
        .toList();
    final address1 =
        address1Parts.isNotEmpty ? address1Parts.join(', ') : (place?.street ?? '');

    final Map<String, dynamic> payload = {
      'address_name': AppStrings.current_location.trim(),
      'address_1': address1,
      'city': place?.locality ?? '',
      'province': place?.administrativeArea ?? '',
      'postal_code': place?.postalCode ?? '',
      'country_code': place?.isoCountryCode?.toLowerCase() ?? '',
      'metadata': {
        'latitude': lat.toString(),
        'longitude': lng.toString(),
      },
    };
    await SharedPreferencesUtil().saveMap('selected_address', payload);
  }

  Future<void> requestLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever) {
      //openAppSettings(); // Direct user to settings if permanently denied
    }
  }
}
