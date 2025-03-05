import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'dart:async';

import 'package:waioz/ui/widgets/common_header_app_bar.dart';
import 'package:waioz/utility/app_colors.dart';
import 'package:waioz/utility/font_utils.dart';

import '../model/register_response.dart';
import '../utility/page_route_utils.dart';
import 'add_address_page.dart';

class MapPage extends StatefulWidget {

  final latitude ;
  final longitude;
  final bool doublePop;
  final bool isEditAddress;
  final Address? selectedAddress; // Optional Address parameter

  const MapPage({super.key,this.latitude = 0.0,this.longitude = 0.0,this.doublePop = false,this.isEditAddress = false,this.selectedAddress});

  //ScreenFrom
  // 1-> Home page
  // 2-> Menu Address page

  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final Completer<GoogleMapController> _controller = Completer();
  LatLng? _currentPosition;
  String _currentAddress = "Fetching address...";
  String _mainAddress = "Fetching address...";
  Marker? _marker;
  Placemark? place;

  @override
  void initState() {
    super.initState();
    requestLocationPermission();
    if(widget.isEditAddress)
      {
        print("Selected address: ${jsonEncode(widget.selectedAddress)}");
      }
    if(widget.latitude == 0.0 && widget.longitude == 0.0) {
      _getCurrentLocation();
    }
    else{
     _updateCustomLocation();
    }
  }

  /// Get Current Location
  Future<void> _getCurrentLocation() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();
    }

    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best);

    setState(() {
      _currentPosition = LatLng(position.latitude, position.longitude);
      _marker = Marker(
        markerId: MarkerId("currentLocation"),
        position: _currentPosition!,
        infoWindow: InfoWindow(title: "Your Location"),
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
        infoWindow: InfoWindow(title: "Your Location"),
      );
    });

    _moveCameraToPosition(_currentPosition!);
    _getAddressFromLatLng(_currentPosition!);
  }

  /// Move Camera to Position
  Future<void> _moveCameraToPosition(LatLng position) async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(target: position, zoom: 15),
    ));
  }

  /// Get Address from LatLng
  Future<void> _getAddressFromLatLng(LatLng position) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
          position.latitude, position.longitude);

      if (placemarks.isNotEmpty) {
         place = placemarks.first;


        List<String?> fullAddressParts = [
          place?.street,
          place?.locality,
          place?.administrativeArea,
          place?.postalCode,
          place?.country
        ].where((element) => element != null && element.isNotEmpty).toList();

        List<String?> mainAddressParts = [
          place?.name,
          place?.thoroughfare
        ].where((element) => element != null && element.isNotEmpty).toList();

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
        infoWindow: InfoWindow(title: "Selected Location"),
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
        title: 'Address',
        onBackTap: () {
          Navigator.of(context).pop();
        },
      ),
      backgroundColor: Colors.white,
      body: _currentPosition == null
          ?  Center(child: CircularProgressIndicator(color: AppColors.primary,))
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
                        "Confirm & Continue",
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
