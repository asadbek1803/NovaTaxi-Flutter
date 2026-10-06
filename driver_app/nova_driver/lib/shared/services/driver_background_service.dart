import 'dart:async';
import 'dart:ui';

import 'package:flutter/widgets.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../../features/home/models/order_model.dart';
import 'notification_service.dart';

/// Haydovchi onlayn bo‘lganda Android/iOS fonda ishlaydigan xizmat.
///
/// - Doimiy "Onlayn" bildirishnomasi (foreground service)
/// - Har ~25 soniyada demo buyurtma yuboradi (real API o‘rniga)
/// - Asosiy UI `new_order` event orqali kartani ko‘rsatadi
class DriverBackgroundService {
  DriverBackgroundService._();
  static final DriverBackgroundService instance = DriverBackgroundService._();

  static const String _notificationChannelId =
      NotificationService.onlineChannelId;
  static const int _notificationId = NotificationService.onlineNotificationId;

  bool _configured = false;

  Future<void> configure() async {
    if (_configured) return;

    final service = FlutterBackgroundService();

    // Ensure online channel exists before FGS starts
    final plugin = FlutterLocalNotificationsPlugin();
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    await plugin.initialize(
      const InitializationSettings(android: androidInit),
    );
    final android = plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await android?.createNotificationChannel(
      const AndroidNotificationChannel(
        _notificationChannelId,
        'Onlayn holat',
        description: 'Haydovchi onlayn bo‘lganda fon xizmati',
        importance: Importance.low,
        playSound: false,
        enableVibration: false,
      ),
    );

    await service.configure(
      androidConfiguration: AndroidConfiguration(
        onStart: _onStart,
        autoStart: false,
        isForegroundMode: true,
        notificationChannelId: _notificationChannelId,
        initialNotificationTitle: 'Nova Haydovchi — Onlayn',
        initialNotificationContent: 'Buyurtmalar kutilmoqda...',
        foregroundServiceNotificationId: _notificationId,
        foregroundServiceTypes: [AndroidForegroundType.dataSync],
      ),
      iosConfiguration: IosConfiguration(
        autoStart: false,
        onForeground: _onStart,
        onBackground: _onIosBackground,
      ),
    );

    _configured = true;
  }

  Future<void> goOnline() async {
    await configure();
    final service = FlutterBackgroundService();
    final running = await service.isRunning();
    if (!running) {
      await service.startService();
    }
    service.invoke('set_online', {'online': true});
  }

  Future<void> goOffline() async {
    final service = FlutterBackgroundService();
    final running = await service.isRunning();
    if (running) {
      service.invoke('set_online', {'online': false});
      service.invoke('stop');
    }
    await NotificationService.instance.hideOnlineStatus();
    await NotificationService.instance.cancelOrderAlert();
  }

  Stream<Map<String, dynamic>?> on(String event) {
    return FlutterBackgroundService().on(event);
  }

  void invoke(String method, [Map<String, dynamic>? args]) {
    FlutterBackgroundService().invoke(method, args);
  }

  Future<bool> isRunning() => FlutterBackgroundService().isRunning();
}

@pragma('vm:entry-point')
Future<bool> _onIosBackground(ServiceInstance service) async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();
  return true;
}

@pragma('vm:entry-point')
void _onStart(ServiceInstance service) async {
  DartPluginRegistrant.ensureInitialized();

  final notifications = FlutterLocalNotificationsPlugin();
  const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
  await notifications.initialize(
    const InitializationSettings(
      android: androidInit,
      iOS: DarwinInitializationSettings(),
    ),
  );

  // Order channel with custom sound (must exist in background isolate too)
  final androidPlugin = notifications.resolvePlatformSpecificImplementation<
      AndroidFlutterLocalNotificationsPlugin>();
  await androidPlugin?.createNotificationChannel(
    const AndroidNotificationChannel(
      NotificationService.orderChannelId,
      'Yangi buyurtmalar',
      description: 'Har bir yangi buyurtma uchun ovozli bildirishnoma',
      importance: Importance.max,
      playSound: true,
      enableVibration: true,
      sound: RawResourceAndroidNotificationSound('order_alert'),
      audioAttributesUsage: AudioAttributesUsage.alarm,
    ),
  );
  await androidPlugin?.createNotificationChannel(
    const AndroidNotificationChannel(
      NotificationService.onlineChannelId,
      'Onlayn holat',
      description: 'Haydovchi onlayn bo‘lganda fon xizmati',
      importance: Importance.low,
      playSound: false,
    ),
  );

  Timer? orderTimer;
  var orderIndex = 0;
  var isOnline = true;

  Future<void> updateOnlineNotification(String content) async {
    if (service is AndroidServiceInstance) {
      if (await service.isForegroundService()) {
        service.setForegroundNotificationInfo(
          title: 'Nova Haydovchi — Onlayn',
          content: content,
        );
      }
    }
  }

  Future<void> fireDemoOrder() async {
    if (!isOnline) return;

    final order = demoOrders[orderIndex % demoOrders.length];
    orderIndex++;

    // Notify UI (if alive)
    service.invoke('new_order', order.toMap());

    // System notification with sound — works even if app is in background
    final body =
        '${order.pickupAddress} → ${order.destinationAddress}\n'
        '${order.formattedPrice} · ${order.distance}';

    await notifications.show(
      NotificationService.orderNotificationId,
      'Yangi buyurtma — ${order.formattedPrice}',
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          NotificationService.orderChannelId,
          'Yangi buyurtmalar',
          channelDescription:
              'Har bir yangi buyurtma uchun ovozli bildirishnoma',
          importance: Importance.max,
          priority: Priority.max,
          category: AndroidNotificationCategory.call,
          visibility: NotificationVisibility.public,
          fullScreenIntent: true,
          playSound: true,
          enableVibration: true,
          sound: const RawResourceAndroidNotificationSound('order_alert'),
          audioAttributesUsage: AudioAttributesUsage.alarm,
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

    await updateOnlineNotification(
      'Yangi buyurtma: ${order.formattedPrice}',
    );
  }

  void startOrderLoop() {
    orderTimer?.cancel();
    // First order soon after going online, then every 40s if not accepted
    orderTimer = Timer.periodic(const Duration(seconds: 40), (_) {
      fireDemoOrder();
    });
    // Immediate first order after short delay
    Future.delayed(const Duration(seconds: 3), fireDemoOrder);
  }

  void stopOrderLoop() {
    orderTimer?.cancel();
    orderTimer = null;
  }

  if (service is AndroidServiceInstance) {
    service.on('setAsForeground').listen((_) {
      service.setAsForegroundService();
    });
    service.on('setAsBackground').listen((_) {
      service.setAsBackgroundService();
    });
  }

  service.on('set_online').listen((event) {
    final online = event?['online'] == true;
    isOnline = online;
    if (online) {
      startOrderLoop();
      updateOnlineNotification('Buyurtmalar kutilmoqda...');
    } else {
      stopOrderLoop();
    }
  });

  service.on('stop').listen((_) {
    stopOrderLoop();
    isOnline = false;
    service.stopSelf();
  });

  service.on('accept_order').listen((_) async {
    await notifications.cancel(NotificationService.orderNotificationId);
    await updateOnlineNotification('Buyurtma qabul qilindi');
  });

  service.on('decline_order').listen((_) async {
    await notifications.cancel(NotificationService.orderNotificationId);
    await updateOnlineNotification('Buyurtmalar kutilmoqda...');
  });

  // Heartbeat so OS keeps the service warm
  Timer.periodic(const Duration(seconds: 20), (timer) async {
    if (!isOnline) {
      timer.cancel();
      return;
    }
    service.invoke('heartbeat', {
      'time': DateTime.now().toIso8601String(),
    });
  });

  startOrderLoop();
  await updateOnlineNotification('Buyurtmalar kutilmoqda...');
}
