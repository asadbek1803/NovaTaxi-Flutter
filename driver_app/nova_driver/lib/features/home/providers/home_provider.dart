import 'dart:async';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

import '../../../core/constants/app_constants.dart';
import '../../../shared/services/driver_background_service.dart';
import '../../../shared/services/location_service.dart';
import '../../../shared/services/notification_service.dart';
import '../../../shared/services/websocket_service.dart';
import '../../../shared/services/audio_service.dart';
import '../models/order_model.dart';

class HomeProvider extends ChangeNotifier {
  final DriverBackgroundService _bg = DriverBackgroundService.instance;
  final WebSocketService _ws = WebSocketService.instance;
  final LocationService _location = LocationService.instance;
  final NotificationService _notifications = NotificationService.instance;
  final AudioService _audio = AudioService.instance;

  bool _isOnline = false;
  bool _isToggling = false;
  Order? _incomingOrder;
  int _orderSecondsLeft = 30;
  LatLng _currentPosition = const LatLng(
    AppConstants.defaultLat,
    AppConstants.defaultLng,
  );
  WsConnectionState _wsState = WsConnectionState.disconnected;

  Timer? _countdownTimer;
  Timer? _locationBroadcastTimer;
  StreamSubscription<Map<String, dynamic>?>? _bgOrderSub;
  StreamSubscription<Order>? _wsOrderSub;
  StreamSubscription<LatLng>? _locationSub;

  bool get isOnline => _isOnline;
  bool get isToggling => _isToggling;
  Order? get incomingOrder => _incomingOrder;
  int get orderSecondsLeft => _orderSecondsLeft;
  LatLng get currentPosition => _currentPosition;
  WsConnectionState get wsState => _wsState;

  final int todayEarnings = 101000;
  final int todayTrips = 6;
  final double todayHours = 4.5;

  String get formattedEarnings {
    return '${todayEarnings.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]} ')} so\'m';
  }

  void initialize() {
    _listenBackgroundOrders();
    _listenWebSocketOrders();
    _listenLocationUpdates();
    _audio.initialize();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _locationBroadcastTimer?.cancel();
    _bgOrderSub?.cancel();
    _wsOrderSub?.cancel();
    _locationSub?.cancel();
    super.dispose();
  }

  void _listenBackgroundOrders() {
    _bgOrderSub = _bg.on('new_order').listen((event) {
      if (event == null || !_isOnline) return;
      final order = Order.fromMap(Map<String, dynamic>.from(event));
      _presentIncomingOrder(order);
    });
  }

  void _listenWebSocketOrders() {
    _wsOrderSub = _ws.onNewOrder.listen((order) {
      if (!_isOnline) return;
      _presentIncomingOrder(order);
    });
  }

  void _listenLocationUpdates() {
    _locationSub = _location.onLocationChanged.listen((pos) {
      _currentPosition = pos;
      notifyListeners();
    });
  }

  Future<void> toggleOnline(bool value, BuildContext context) async {
    if (_isToggling) return;
    _isToggling = true;
    notifyListeners();

    try {
      if (value) {
        final ok = await _notifications.requestPermissions();
        if (!ok && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Bildirishnoma ruxsati kerak. Sozlamalardan yoqing.',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }

        await _bg.goOnline();
        await _location.getCurrentLocation();
        _location.startTracking();
        _startLocationBroadcast();

        _updateWsState();
        if (_ws.currentState != WsConnectionState.connected) {
          _ws.connect();
        }

        _isOnline = true;
      } else {
        await _bg.goOffline();
        _location.stopTracking();
        _stopLocationBroadcast();
        _ws.disconnect();
        _clearIncomingOrder();
        _isOnline = false;
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Xizmatni ishga tushirishda xato: $e',
                style: const TextStyle(fontSize: 15)),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      _isToggling = false;
      notifyListeners();
    }
  }

  void _updateWsState() {
    _ws.connectionState.listen((state) {
      _wsState = state;
      notifyListeners();
    });
  }

  void _startLocationBroadcast() {
    _locationBroadcastTimer?.cancel();
    _locationBroadcastTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      if (_isOnline && _ws.currentState == WsConnectionState.connected) {
        _ws.sendLocation(
          _currentPosition.latitude,
          _currentPosition.longitude,
        );
      }
    });
  }

  void _stopLocationBroadcast() {
    _locationBroadcastTimer?.cancel();
    _locationBroadcastTimer = null;
  }

  void _presentIncomingOrder(Order order) {
    if (_incomingOrder?.id == order.id) return;

    _incomingOrder = order;
    _orderSecondsLeft = 30;
    notifyListeners();

    _startOrderCountdown();
    _audio.playOrderAlert();
  }

  void _startOrderCountdown() {
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_orderSecondsLeft <= 1) {
        timer.cancel();
        declineOrder();
      } else {
        _orderSecondsLeft--;
        notifyListeners();
      }
    });
  }

  void _clearIncomingOrder() {
    _countdownTimer?.cancel();
    _audio.stopOrderAlert();
    _incomingOrder = null;
    _orderSecondsLeft = 30;
    notifyListeners();
  }

  void acceptOrder() {
    if (_incomingOrder == null) return;
    final order = _incomingOrder!;
    _countdownTimer?.cancel();
    _audio.stopOrderAlert();
    _bg.invoke('accept_order');
    _ws.sendAcceptOrder(order.id);
    _incomingOrder = null;
    _orderSecondsLeft = 30;
    notifyListeners();
  }

  void declineOrder() {
    _countdownTimer?.cancel();
    _audio.stopOrderAlert();
    _bg.invoke('decline_order');
    _incomingOrder = null;
    _orderSecondsLeft = 30;
    notifyListeners();
  }

  void onAppResume() {
    if (_incomingOrder == null) {
      _audio.stopOrderAlert();
    }
  }
}
