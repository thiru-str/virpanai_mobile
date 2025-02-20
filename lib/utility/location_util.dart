import 'package:geolocator/geolocator.dart';

class LocationUtil {
  static Future<Position?> getApproximateLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return null; // Return null if location is disabled
    }

    // Check for location permissions
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return null; // If denied, return null
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return null; // Permissions are permanently denied
    }

    // Try to get the last known location for faster access
    Position? lastKnownPosition = await Geolocator.getLastKnownPosition();
    if (lastKnownPosition != null) {
      return lastKnownPosition;
    }

    // If no last known position is available, get a fresh low-accuracy location
    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.low,
    );
  }
}
