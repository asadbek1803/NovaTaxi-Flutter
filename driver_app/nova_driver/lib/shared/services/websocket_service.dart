import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/app_constants.dart';
import '../../features/home/models/order_model.dart';

enum WsConnectionState { disconnected, connecting, connected }

class WebSocketService {
  WebSocketService._();
  static final WebSocketService instance = WebSocketService._();

  WebSocketChannel? _channel;
  WsConnectionState _state = WsConnectionState.disconnected;
  Timer? _heartbeatTimer;
  Timer? _reconnectTimer;
  int _reconnectAttempts = 0;
  static const int _maxReconnectAttempts = 10;

  final _stateController = StreamController<WsConnectionState>.broadcast();
  final _orderController = StreamController<Order>.broadcast();
  final _locationController = StreamController<Map<String, dynamic>>.broadcast();

  Stream<WsConnectionState> get connectionState => _stateController.stream;
  Stream<Order> get onNewOrder => _orderController.stream;
  WsConnectionState get currentState => _state;

  Future<void> connect() async {
    if (_state == WsConnectionState.connected ||
        _state == WsConnectionState.connecting) {
      return;
    }

    _updateState(WsConnectionState.connecting);

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(AppConstants.accessToken) ?? 'demo';
      final driverId = prefs.getString(AppConstants.driverId) ?? 'demo';

      final uri = Uri.parse(
        '${AppConstants.wsBaseUrl}/ws/driver/?token=$token&driver_id=$driverId',
      );

      _channel = WebSocketChannel.connect(uri);

      await _channel!.ready.timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw Exception('WebSocket connection timeout'),
      );

      _updateState(WsConnectionState.connected);
      _reconnectAttempts = 0;

      _channel!.stream.listen(
        _onMessage,
        onDone: _onDisconnected,
        onError: (error) {
          debugPrint('WebSocket error: $error');
          _onDisconnected();
        },
      );

      _startHeartbeat();
    } catch (e) {
      debugPrint('WebSocket connect failed: $e');
      _updateState(WsConnectionState.disconnected);
      _scheduleReconnect();
    }
  }

  void _onMessage(dynamic data) {
    try {
      final message = jsonDecode(data.toString());
      final type = message['type'] as String?;

      switch (type) {
        case 'new_order':
          final orderData = message['order'];
          if (orderData != null) {
            final order = Order.fromMap(Map<String, dynamic>.from(orderData));
            _orderController.add(order);
          }
          break;
        case 'pong':
          break;
        case 'driver_location_ack':
          _locationController.add({
            'status': 'acknowledged',
            'lat': message['lat'],
            'lng': message['lng'],
          });
          break;
        default:
          break;
      }
    } catch (e) {
      debugPrint('WebSocket message parse error: $e');
    }
  }

  void _onDisconnected() {
    _heartbeatTimer?.cancel();
    _updateState(WsConnectionState.disconnected);
    _scheduleReconnect();
  }

  void _startHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = Timer.periodic(const Duration(seconds: 20), (_) {
      _send({'type': 'ping'});
    });
  }

  void sendLocation(double lat, double lng) {
    _send({
      'type': 'driver_location',
      'lat': lat,
      'lng': lng,
    });
  }

  void sendAcceptOrder(String orderId) {
    _send({
      'type': 'accept_order',
      'order_id': orderId,
    });
  }

  void sendDeclineOrder(String orderId) {
    _send({
      'type': 'decline_order',
      'order_id': orderId,
    });
  }

  void sendRideStatus(String orderId, String status) {
    _send({
      'type': 'ride_status',
      'order_id': orderId,
      'status': status,
    });
  }

  void _send(Map<String, dynamic> data) {
    if (_channel != null && _state == WsConnectionState.connected) {
      _channel!.sink.add(jsonEncode(data));
    }
  }

  void _scheduleReconnect() {
    if (_reconnectAttempts >= _maxReconnectAttempts) {
      debugPrint('WebSocket: max reconnect attempts reached');
      return;
    }

    final delay = Duration(seconds: (2 * (_reconnectAttempts + 1)).clamp(2, 30));
    _reconnectAttempts++;

    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(delay, () {
      debugPrint('WebSocket: reconnecting (attempt $_reconnectAttempts)...');
      connect();
    });
  }

  void _updateState(WsConnectionState newState) {
    _state = newState;
    _stateController.add(newState);
  }

  void disconnect() {
    _heartbeatTimer?.cancel();
    _reconnectTimer?.cancel();
    _channel?.sink.close();
    _channel = null;
    _updateState(WsConnectionState.disconnected);
  }

  void dispose() {
    disconnect();
    _stateController.close();
    _orderController.close();
    _locationController.close();
  }
}
