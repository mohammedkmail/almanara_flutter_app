import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import 'login_screen.dart';
import 'navigation_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _restore();
  }

  Future<void> _restore() async {
    setState(() {
      _hasError = false;
    });

    try {
      await Future.wait([
        AuthService.instance.restore(),
        Future.delayed(const Duration(seconds: 3)),
      ]);

      if (!mounted) return;

      final user = AuthService.instance.user.value;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute<void>(
          builder: (_) {
            if (user == null) {
              return const LoginScreen();
            }

            return MainScreen(role: user.role);
          },
        ),
      );
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _hasError = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/images/splash_image.png', fit: BoxFit.cover),

          if (_hasError)
            Container(
              color: Colors.black.withValues(alpha: 0.35),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.error_outline_rounded,
                        color: Colors.white,
                        size: 48,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'تعذر استعادة الجلسة',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: FilledButton(
                          onPressed: _restore,
                          child: const Text('إعادة المحاولة'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
