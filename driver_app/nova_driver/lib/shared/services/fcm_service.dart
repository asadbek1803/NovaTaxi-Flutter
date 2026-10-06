import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import '../../core/constants/app_constants.dart';
import '../services/api_service.dart';

class FCMService {
  FCMService._();
  static final FCMService instance = FCMService._();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final ApiService _api = ApiService.instance;

  String? _fcmToken;
  String? get fcmToken => _fcmToken;

  Future<void> initialize() async {
    await _requestPermission();
    await _getToken();
    _setupMessageHandlers();
  }

  Future<void> _requestPermission() async {
    if (Platform.isIOS) {
      final settings = await _messaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      debugPrint('FCM Permission: ${settings.authorizationStatus}');
    }
  }

  Future<void> _getToken() async {
    try {
      _fcmToken = await _messaging.getToken();
      debugPrint('FCM Token: $_fcmToken');
      
      if (_fcmToken != null) {
        await _sendTokenToServer();
      }
    } catch (e) {
      debugPrint('Error getting FCM token: $e');
    }
  }

  Future<void> _sendTokenToServer() async {
    try {
      // Send FCM token to backend for push notifications
      await _api.post('/drivers/fcm-token', body: {
        'fcm_token': _fcmToken,
      });
    } catch (e) {
      debugPrint('Error sending FCM token to server: $e');
    }
  }

  void _setupMessageHandlers() {
    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('Got a message whilst in the foreground!');
      debugPrint('Message data: ${message.data}');

      if (message.notification != null) {
        debugPrint('Message also contained a notification: ${message.notification}');
        _handleModeratorDecision(message);
      }
    });

    // Handle background messages
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('Message clicked!');
      _handleModeratorDecision(message);
    });

    // Handle when app is terminated
    FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? message) {
      if (message != null) {
        _handleModeratorDecision(message);
      }
    });
  }

  void _handleModeratorDecision(RemoteMessage message) {
    final data = message.data;
    final status = data['status'] as String?;
    final reason = data['rejection_reason'] as String?;

    if (status == null) return;

    switch (status) {
      case AppConstants.statusApproved:
        _handleApproval();
        break;
      case AppConstants.statusRejected:
        _handleRejection(reason);
        break;
      case AppConstants.statusPending:
        // Already on pending screen, no action needed
        break;
    }
  }

  void _handleApproval() {
    // Navigate to home screen
    // This will be handled by the app's navigation logic
    debugPrint('Driver approved! Navigating to home...');
  }

  void _handleRejection(String? reason) {
    // Navigate to rejection screen with reason
    debugPrint('Driver rejected! Reason: $reason');
  }

  Future<void> refreshToken() async {
    await _getToken();
  }
}

// Background message handler (must be top-level function)
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('Handling a background message: ${message.messageId}');
}
