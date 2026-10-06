import 'dart:async';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

import '../../../shared/services/audio_service.dart';
import '../../../shared/services/location_service.dart';
import '../../../shared/services/websocket_service.dart';
import '../models/order_model.dart';

enum RideStatus {
  idle,
  navigatingToPickup,
  arrivedAtPickup,
  inTrip,
  tripCompleted,
}

class RideProvider extends ChangeNotifier {
  final AudioService _audio = AudioService.instance;
  final LocationService _location = LocationService.instance;
  final WebSocketService _ws = WebSocketService.instance;

  RideStatus _status = RideStatus.idle;
  Order? _currentOrder;
  LatLng? _pickupLocation;
  LatLng? _destinationLocation;
  double _distanceToPickup = 0.0;
  int _etaToPickup = 0;
  double _tripDistance = 0.0;
  int _tripDuration = 0;
  Timer? _tripTimer;

  RideStatus get status => _status;
  Order? get currentOrder => _currentOrder;
  LatLng? get pickupLocation => _pickupLocation;
  LatLng? get destinationLocation => _destinationLocation;
  double get distanceToPickup => _distanceToPickup;
  int get etaToPickup => _etaToPickup;
  double get tripDistance => _tripDistance;
  int get tripDuration => _tripDuration;

  bool get hasActiveOrder => _currentOrder != null && _status != RideStatus.idle && _status != RideStatus.tripCompleted;

  void acceptOrder(Order order) {
    _currentOrder = order;
    _pickupLocation = LatLng(order.pickupLat, order.pickupLng);
    _destinationLocation = LatLng(order.destinationLat, order.destinationLng);
    _status = RideStatus.navigatingToPickup;

    _calculatePickupDistance();
    _ws.sendRideStatus(order.id, 'accepted');
    notifyListeners();
  }

  void _calculatePickupDistance() {
    if (_pickupLocation == null) return;
    final current = _location.currentPosition;
    final distance = Distance();
    final meters = distance(current, _pickupLocation!);
    _distanceToPickup = meters / 1000.0;
    _etaToPickup = (_distanceToPickup * 3.5).round().clamp(1, 60);
  }

  void updateLocation(LatLng location) {
    _calculatePickupDistance();
    if (_status == RideStatus.inTrip) {
      _updateTripProgress(location);
    }
    notifyListeners();
  }

  void _updateTripProgress(LatLng currentLocation) {
    if (_destinationLocation == null) return;
    _tripDistance += 0.001;
    _tripDuration = (_tripDuration > 0) ? _tripDuration : 0;
  }

  void driverArrived() {
    _status = RideStatus.arrivedAtPickup;
    _audio.playDriverArrived();
    if (_currentOrder != null) {
      _ws.sendRideStatus(_currentOrder!.id, 'arrived');
    }
    notifyListeners();
  }

  void startTrip() {
    _status = RideStatus.inTrip;
    _tripDistance = 0;
    _tripDuration = 0;
    _audio.playTripStarted();
    _startTripTimer();
    if (_currentOrder != null) {
      _ws.sendRideStatus(_currentOrder!.id, 'trip_started');
    }
    notifyListeners();
  }

  void _startTripTimer() {
    _tripTimer?.cancel();
    _tripTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      _tripDuration++;
      notifyListeners();
    });
  }

  void endTrip() {
    _tripTimer?.cancel();
    _status = RideStatus.tripCompleted;
    _audio.playDestinationReached();
    if (_currentOrder != null) {
      _ws.sendRideStatus(_currentOrder!.id, 'trip_completed');
    }
    notifyListeners();
  }

  void reset() {
    _tripTimer?.cancel();
    _status = RideStatus.idle;
    _currentOrder = null;
    _pickupLocation = null;
    _destinationLocation = null;
    _distanceToPickup = 0;
    _etaToPickup = 0;
    _tripDistance = 0;
    _tripDuration = 0;
    notifyListeners();
  }

  String get formattedTripDuration {
    final mins = _tripDuration ~/ 60;
    final secs = _tripDuration % 60;
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _tripTimer?.cancel();
    super.dispose();
  }
}
