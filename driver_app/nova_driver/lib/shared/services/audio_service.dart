import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

class AudioService {
  AudioService._();
  static final AudioService instance = AudioService._();

  final AudioPlayer _orderPlayer = AudioPlayer();
  final AudioPlayer _ridePlayer = AudioPlayer();
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;
    await _orderPlayer.setPlayerMode(PlayerMode.lowLatency);
    await _ridePlayer.setPlayerMode(PlayerMode.lowLatency);
  }

  Future<void> playOrderAlert() async {
    try {
      await _orderPlayer.stop();
      await _orderPlayer.play(
        AssetSource('sounds/order_alert.mp3'),
        volume: 1.0,
      );
    } catch (e) {
      debugPrint('AudioService: playOrderAlert error: $e');
    }
  }

  Future<void> stopOrderAlert() async {
    try {
      await _orderPlayer.stop();
    } catch (_) {}
  }

  Future<void> playOrderCancelled() async {
    try {
      await _ridePlayer.play(AssetSource('sounds/order_cancelled.mp3'));
    } catch (_) {}
  }

  Future<void> playDriverArrived() async {
    try {
      await _ridePlayer.play(AssetSource('sounds/driver_arrived.mp3'));
    } catch (e) {
      debugPrint('AudioService: playDriverArrived error: $e');
    }
  }

  Future<void> playTripStarted() async {
    try {
      await _ridePlayer.play(AssetSource('sounds/trip_started.mp3'));
    } catch (e) {
      debugPrint('AudioService: playTripStarted error: $e');
    }
  }

  Future<void> playDestinationReached() async {
    try {
      await _ridePlayer.play(AssetSource('sounds/destination_reached.mp3'));
    } catch (e) {
      debugPrint('AudioService: playDestinationReached error: $e');
    }
  }

  Future<void> playNavigation(String instruction) async {
    try {
      String asset;
      switch (instruction) {
        case 'go_straight':
          asset = 'sounds/go_straight.mp3';
          break;
        case 'turn_left':
          asset = 'sounds/turn_left.mp3';
          break;
        case 'turn_right':
          asset = 'sounds/turn_right.mp3';
          break;
        case 'slight_left':
          asset = 'sounds/slight_left.mp3';
          break;
        case 'slight_right':
          asset = 'sounds/slight_right.mp3';
          break;
        case 'u_turn':
          asset = 'sounds/u_turn.mp3';
          break;
        case '50_meters':
          asset = 'sounds/50_meters.mp3';
          break;
        case '100_meters':
          asset = 'sounds/100_meters.mp3';
          break;
        case '200_meters':
          asset = 'sounds/200_meters.mp3';
          break;
        case '500_meters':
          asset = 'sounds/500_meters.mp3';
          break;
        default:
          return;
      }
      await _ridePlayer.play(AssetSource(asset));
    } catch (e) {
      debugPrint('AudioService: playNavigation error: $e');
    }
  }

  void stopAll() {
    _orderPlayer.stop();
    _ridePlayer.stop();
  }

  void dispose() {
    _orderPlayer.dispose();
    _ridePlayer.dispose();
  }
}
