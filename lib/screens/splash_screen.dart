import 'package:flutter/material.dart';

import 'login_screen.dart';
import 'navigation_screen.dart';
import '../services/auth_service.dart';
import '../widgets/api_error_view.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Object? _error;
  @override
  void initState() {
    super.initState();

    _restore();
  }

  Future<void> _restore() async {
    setState(() => _error = null);
    try {
      await AuthService.instance.restore();
      if (!mounted) return;
      final user = AuthService.instance.user.value;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute<void>(
          builder: (_) =>
              user == null ? const LoginScreen() : MainScreen(role: user.role),
        ),
      );
    } catch (error) {
      if (mounted) setState(() => _error = error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _error != null
          ? ApiErrorView(error: _error!, retry: _restore)
          : SizedBox.expand(
              child: Image.asset(
                'assets/images/splash_image.png',
                fit: BoxFit.cover,
              ),
            ),
    );
  }
}
