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
import 'package:waioz/utility/ui_typography.dart';

import '../model/register_response.dart';
import '../utility/page_route_utils.dart';
import 'add_address_page.dart';

class MapPage extends StatefulWidget {
  final latitude;
  final longitude;
  final bool doublePop;
  final bool isEditAddress;
  final Address? selectedAddress; // Optional Address parameter

  const MapPage(
      {super.key,
      this.latitude = 0.0,
      this.longitude = 0.0,
      this.doublePop = false,
      this.isEditAddress = false,
      this.selectedAddress});

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
                    padding:
                        const EdgeInsets.fromLTRB(20, 20, 20, 24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(24),
                        topRight: Radius.circular(24),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 18,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: SafeArea(
                      top: false,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: Container(
                              width: 40,
                              height: 4,
                              decoration: BoxDecoration(
                                color: const Color(0xFFE5E7EC),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(Icons.location_on,
                                    size: 20, color: AppColors.primary),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _mainAddress, // Static location name or fetched dynamically
                                      style: UiTypography.cardTitle().copyWith(
                                        fontSize: 18,
                                        height: 1.25,
                                        letterSpacing: -0.2,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _currentAddress, // Dynamic address fetched from Geocoder
                                      style: UiTypography.cardSubtitle()
                                          .copyWith(height: 1.4),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 18),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                elevation: 0,
                                minimumSize: const Size(double.infinity, 54),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              onPressed: () {
                                // Handle confirmation logic
                                PageRouteUtils.pushWithSlide(
                                    context,
                                    AddAddressPage(
                                      isFromMap: true,
                                      place: place,
                                      currentPosition: _currentPosition,
                                      doublePop: widget.doublePop,
                                      selectedAddress: widget.selectedAddress,
                                    ));
                              },
                              child: Text(
                                AppStrings.confirm_continue,
                                style: FontUtils.primaryFontStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
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
