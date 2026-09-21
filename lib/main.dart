import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';
import 'models/app_user_role.dart';
import 'screens/api_reservations_screen.dart';
import 'screens/login_screen.dart';
import 'screens/navigation_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/membership_screen.dart';
import 'services/auth_service.dart';
import 'services/notification_service.dart';
import 'theme/app_theme.dart';
import 'theme/theme_controller.dart';

Future<void> main() async {
WidgetsFlutterBinding.ensureInitialized();

await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

runApp(const MyApp());

await NotificationService.instance.initialize();
}

class MyApp extends StatefulWidget {
const MyApp({super.key});

@override
State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
final _navigatorKey = GlobalKey<NavigatorState>();

@override
void initState() {
super.initState();

AuthService.instance.user.addListener(_sessionChanged);
NotificationService.instance.openedPayload.addListener(_notificationOpened);
}

void _sessionChanged() {
final account = AuthService.instance.user.value;

if (account == null) {
_navigatorKey.currentState?.pushNamedAndRemoveUntil(
'/login',
(_) => false,
);
return;
}

NotificationService.instance.syncDeviceToken();
}

void _notificationOpened() {
if (AuthService.instance.user.value == null) return;

final data = NotificationService.instance.openedPayload.value;

if (data == null) return;

NotificationService.instance.openedPayload.value = null;

final type = (data['type'] ?? '').toString();

final Widget page = type == 'MEMBERSHIP'
? const MembershipScreen()
    : const ApiReservationsScreen();

_navigatorKey.currentState?.push(MaterialPageRoute(builder: (_) => page));
}

@override
void dispose() {
AuthService.instance.user.removeListener(_sessionChanged);
NotificationService.instance.openedPayload.removeListener(
_notificationOpened,
);

super.dispose();
}

@override
Widget build(BuildContext context) {
return ValueListenableBuilder<ThemeMode>(
valueListenable: ThemeController.themeMode,
builder: (context, themeMode, child) {
return MaterialApp(
navigatorKey: _navigatorKey,
debugShowCheckedModeBanner: false,
title: 'المنارة',
theme: AppTheme.lightTheme,
darkTheme: AppTheme.darkTheme,
themeMode: themeMode,
routes: {
'/login': (_) => const LoginScreen(),
'/home': (_) => MainScreen(
role:
AuthService.instance.user.value?.role ?? AppUserRole.customer,
),
},
home: const SplashScreen(),
);
},
);
}
}

