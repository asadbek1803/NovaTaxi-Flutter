import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../features/home/models/order_model.dart';

/// Bildirishnomalar va buyurtma ovozi.
///
/// - `online_status` kanali: fon xizmati (sokin)
/// - `new_order` kanali: har bir yangi buyurtma (baland ovoz + vibration)
class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  static const String onlineChannelId = 'online_status';
  static const String orderChannelId = 'new_order';

  static const int onlineNotificationId = 1001;
  static const int orderNotificationId = 2001;

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  final AudioPlayer _audioPlayer = AudioPlayer();

  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    await _plugin.initialize(
      const InitializationSettings(android: androidInit, iOS: iosInit),
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    await _createChannels();
    await _audioPlayer.setReleaseMode(ReleaseMode.stop);
    await _audioPlayer.setVolume(1.0);

    _initialized = true;
  }

  Future<void> _createChannels() async {
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (android == null) return;

    await android.createNotificationChannel(
      const AndroidNotificationChannel(
        onlineChannelId,
        'Onlayn holat',
        description: 'Haydovchi onlayn bo‘lganda fon xizmati',
        importance: Importance.low,
        playSound: false,
        enableVibration: false,
        showBadge: false,
      ),
    );

    // Max importance + custom sound for every new order
    await android.createNotificationChannel(
      AndroidNotificationChannel(
        orderChannelId,
        'Yangi buyurtmalar',
        description: 'Har bir yangi buyurtma uchun ovozli bildirishnoma',
        importance: Importance.max,
        playSound: true,
        enableVibration: true,
        enableLights: true,
        sound: const RawResourceAndroidNotificationSound('order_alert'),
        audioAttributesUsage: AudioAttributesUsage.alarm,
        vibrationPattern: Int64List.fromList([0, 400, 200, 400, 200, 600]),
      ),
    );
  }

  /// Android 13+ va iOS ruxsatlarini so‘raydi.
  Future<bool> requestPermissions() async {
    if (kIsWeb) return true;

    if (Platform.isAndroid) {
      final notif = await Permission.notification.request();
      // Optional: ignore battery optimizations so service stays alive longer
      if (await Permission.ignoreBatteryOptimizations.isDenied) {
        await Permission.ignoreBatteryOptimizations.request();
      }
      return notif.isGranted || notif.isLimited;
    }

    if (Platform.isIOS) {
      final ios = _plugin.resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>();
      final granted = await ios?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          ) ??
          false;
      return granted;
    }

    return true;
  }

  /// Fon xizmati uchun doimiy (ongoing) bildirishnoma.
  NotificationDetails onlineServiceDetails() {
    return const NotificationDetails(
      android: AndroidNotificationDetails(
        onlineChannelId,
        'Onlayn holat',
        channelDescription: 'Haydovchi onlayn bo‘lganda fon xizmati',
        importance: Importance.low,
        priority: Priority.low,
        ongoing: true,
        autoCancel: false,
        playSound: false,
        enableVibration: false,
        showWhen: false,
        category: AndroidNotificationCategory.service,
        visibility: NotificationVisibility.public,
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: false,
        presentBadge: false,
        presentSound: false,
      ),
    );
  }

  Future<void> showOnlineStatus() async {
    await initialize();
    await _plugin.show(
      onlineNotificationId,
      'Nova Haydovchi — Onlayn',
      'Buyurtmalar kutilmoqda. Ilova fonda ishlayapti.',
      onlineServiceDetails(),
    );
  }

  Future<void> hideOnlineStatus() async {
    await _plugin.cancel(onlineNotificationId);
  }

  /// Har bir yangi buyurtma uchun ovozli bildirishnoma + ilova ichida ovoz.
  Future<void> alertNewOrder(
    Order order, {
    bool playInAppSound = true,
  }) async {
    await initialize();

    if (playInAppSound) {
      await playOrderSound();
    }

    final body =
        '${order.pickupAddress} → ${order.destinationAddress}\n'
        '${order.formattedPrice} · ${order.distance}';

    await _plugin.show(
      orderNotificationId,
      'Yangi buyurtma — ${order.formattedPrice}',
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          orderChannelId,
          'Yangi buyurtmalar',
          channelDescription: 'Har bir yangi buyurtma uchun ovozli bildirishnoma',
          importance: Importance.max,
          priority: Priority.max,
          category: AndroidNotificationCategory.call,
          visibility: NotificationVisibility.public,
          fullScreenIntent: true,
          playSound: true,
          enableVibration: true,
          sound: const RawResourceAndroidNotificationSound('order_alert'),
          audioAttributesUsage: AudioAttributesUsage.alarm,
          vibrationPattern: Int64List.fromList([0, 400, 200, 400, 200, 600]),
          styleInformation: BigTextStyleInformation(
            body,
            contentTitle: 'Yangi buyurtma — ${order.formattedPrice}',
            summaryText: 'Nova Haydovchi',
          ),
          ticker: 'Yangi buyurtma keldi!',
          autoCancel: true,
          timeoutAfter: 30000,
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
          sound: 'order_alert.mp3',
          interruptionLevel: InterruptionLevel.timeSensitive,
        ),
      ),
      payload: order.id,
    );
  }

  Future<void> cancelOrderAlert() async {
    await _plugin.cancel(orderNotificationId);
    await stopOrderSound();
  }

  /// Ilova ochiq bo‘lganda ham eshitiladigan ovoz.
  Future<void> playOrderSound() async {
    try {
      await _audioPlayer.stop();
      await _audioPlayer.play(AssetSource('sounds/order_alert.mp3'));
    } catch (e) {
      debugPrint('Order sound error: $e');
    }
  }

  Future<void> stopOrderSound() async {
    try {
      await _audioPlayer.stop();
    } catch (_) {}
  }

  void _onNotificationTap(NotificationResponse response) {
    // UI layer listens via stream if needed later
    debugPrint('Notification tapped: ${response.payload}');
  }
}
