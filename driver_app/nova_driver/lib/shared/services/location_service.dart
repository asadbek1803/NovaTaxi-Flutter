import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import '../../core/constants/app_constants.dart';

class LocationService {
  LocationService._();
  static final LocationService instance = LocationService._();

  LatLng? _currentPosition;
  StreamSubscription<Position>? _positionSub;
  final _positionController = StreamController<LatLng>.broadcast();

  LatLng get currentPosition =>
      _currentPosition ??
      const LatLng(AppConstants.defaultLat, AppConstants.defaultLng);

  Stream<LatLng> get onLocationChanged => _positionController.stream;

  Future<bool> checkAndRequestPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return false;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return false;
    }

    if (permission == LocationPermission.deniedForever) return false;

    return true;
  }

  Future<LatLng> getCurrentLocation() async {
    final hasPermission = await checkAndRequestPermission();
    if (!hasPermission) return currentPosition;

    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );
      _currentPosition = LatLng(position.latitude, position.longitude);
      return _currentPosition!;
    } catch (e) {
      debugPrint('LocationService: getCurrentLocation error: $e');
      return currentPosition;
    }
  }

  void startTracking() {
    _positionSub?.cancel();
    _positionSub = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    ).listen(
      (position) {
        _currentPosition = LatLng(position.latitude, position.longitude);
        _positionController.add(_currentPosition!);
      },
      onError: (e) => debugPrint('LocationService: stream error: $e'),
    );
  }

  void stopTracking() {
    _positionSub?.cancel();
    _positionSub = null;
  }

  void dispose() {
    stopTracking();
    _positionController.close();
  }
}
