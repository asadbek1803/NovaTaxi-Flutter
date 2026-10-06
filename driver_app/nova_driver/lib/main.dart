import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/theme/app_theme.dart';
import 'core/constants/app_constants.dart';
import 'features/auth/providers/auth_provider.dart';
import 'features/onboarding/providers/onboarding_provider.dart';
import 'features/home/providers/home_provider.dart';
import 'features/home/providers/ride_provider.dart';
import 'features/auth/screens/phone_number_screen.dart';
import 'features/onboarding/screens/onboarding_wrapper.dart';
import 'features/onboarding/screens/pending_status_screen.dart';
import 'shared/services/fcm_service.dart';
import 'shared/services/driver_background_service.dart';
import 'shared/services/notification_service.dart';
import 'features/home/screens/home_wrapper.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  try {
    await Firebase.initializeApp();
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    await FCMService.instance.initialize();
  } catch (e) {
    debugPrint('Firebase not configured, running in demo mode: $e');
  }

  try {
    await NotificationService.instance.initialize();
    await NotificationService.instance.requestPermissions();
    await DriverBackgroundService.instance.configure();
  } catch (e) {
    debugPrint('Services init error: $e');
  }

  runApp(const NovaDriverApp());
}

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {}

class NovaDriverApp extends StatelessWidget {
  const NovaDriverApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => OnboardingProvider()),
        ChangeNotifierProvider(create: (_) => HomeProvider()),
        ChangeNotifierProvider(create: (_) => RideProvider()),
      ],
      child: MaterialApp(
        title: 'Nova Haydovchi',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        themeMode: ThemeMode.light,
        initialRoute: '/',
        routes: {
          '/': (context) => const AuthWrapper(),
          '/login': (context) => const PhoneNumberScreen(),
          '/onboarding': (context) => const OnboardingWrapper(),
          '/pending': (context) => const PendingStatusScreen(),
          '/rejected': (context) => const RejectionScreen(),
          '/home': (context) => const HomeWrapper(),
        },
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        switch (authProvider.status) {
          case AuthStatus.uninitialized:
          case AuthStatus.loading:
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          case AuthStatus.authenticated:
            final driver = authProvider.driver;
            if (driver == null) {
              return const _DemoModeRouter();
            }

            switch (driver.status) {
              case AppConstants.statusPending:
                return const PendingStatusScreen();
              case AppConstants.statusRejected:
                return const RejectionScreen();
              case AppConstants.statusApproved:
              case AppConstants.statusActive:
                return const HomeWrapper();
              default:
                return const OnboardingWrapper();
            }
          case AuthStatus.unauthenticated:
            return const PhoneNumberScreen();
          case AuthStatus.error:
            return const PhoneNumberScreen();
        }
      },
    );
  }
}

class _DemoModeRouter extends StatelessWidget {
  const _DemoModeRouter();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, String>>(
      future: _loadDemoState(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final data = snapshot.data!;
        final onboardingCompleted = data['onboarding_completed'] == 'true';
        final driverStatus = data['driver_status'] ?? '';

        if (!onboardingCompleted) {
          return const OnboardingWrapper();
        }

        switch (driverStatus) {
          case AppConstants.statusApproved:
          case AppConstants.statusActive:
            return const HomeWrapper();
          case AppConstants.statusPending:
            return const PendingStatusScreen();
          case AppConstants.statusRejected:
            return const RejectionScreen();
          default:
            return const OnboardingWrapper();
        }
      },
    );
  }

  Future<Map<String, String>> _loadDemoState() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'onboarding_completed': (prefs.getBool(AppConstants.onboardingCompleted) ?? false).toString(),
      'driver_status': prefs.getString(AppConstants.driverStatus) ?? '',
      'phone_number': prefs.getString(AppConstants.phoneNumber) ?? '',
    };
  }
}
