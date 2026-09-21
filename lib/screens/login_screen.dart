import 'package:flutter/material.dart';

import 'navigation_screen.dart';
import 'register_screen.dart';
import '../models/api_models.dart';
import '../services/auth_service.dart';
import '../widgets/api_error_view.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _emailController = TextEditingController();

  final TextEditingController _passwordController = TextEditingController();

  bool _hidePassword = true;
  bool _loading = false;

  // ألوان التصميم
  static const Color darkTeal = Color(0xFF00373D);
  static const Color buttonTeal = Color(0xFF196A6D);
  static const Color accentTeal = Color(0xFF0F777B);
  static const Color mutedText = Color(0xFF6F7D80);
  static const Color fieldText = Color(0xFF778488);

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();

    super.dispose();
  }

  Future<void> _login() async {
    if (_loading) return;
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _loading = true);
    try {
      await AuthService.instance.login(
        LoginRequest(_emailController.text.trim(), _passwordController.text),
      );
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) =>
              MainScreen(role: AuthService.instance.user.value!.role),
        ),
      );
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(apiErrorMessage(error))));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _openRegister() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const RegisterScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;

    return Directionality(
      textDirection: TextDirection.rtl,

      child: Scaffold(
        resizeToAvoidBottomInset: true,

        body: Stack(
          children: [
            // =========================
            // BACKGROUND
            // =========================
            Positioned.fill(
              child: Image.asset(
                'assets/images/library_login_image.png',
                fit: BoxFit.cover,
              ),
            ),

            // =========================
            // PAGE CONTENT
            // =========================
            SafeArea(
              child: SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,

                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight:
                        screenHeight - MediaQuery.of(context).padding.top,
                  ),

                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30),

                    child: Form(
                      key: _formKey,

                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,

                        children: [
                          // =========================
                          // BACK BUTTON
                          // =========================
                          Align(
                            alignment: Alignment.centerLeft,

                            child: IconButton(
                              onPressed: () {
                                Navigator.maybePop(context);
                              },

                              icon: const Icon(
                                Icons.arrow_back,
                                size: 31,
                                color: darkTeal,
                              ),
                            ),
                          ),

                          // المسافة مكان اسم المنارة القديم
                          SizedBox(height: screenHeight * 0.22),

                          // =========================
                          // LOGIN TITLE
                          // =========================
                          const Text(
                            'تسجيل الدخول',

                            textAlign: TextAlign.center,

                            style: TextStyle(
                              color: darkTeal,
                              fontSize: 27,
                              fontWeight: FontWeight.w800,
                            ),
                          ),

                          const SizedBox(height: 5),

                          const Text(
                            'أهلاً بك مرة أخرى',

                            textAlign: TextAlign.center,

                            style: TextStyle(
                              color: mutedText,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),

                          const SizedBox(height: 23),

                          // =========================
                          // EMAIL
                          // =========================
                          _buildFieldShadow(
                            child: TextFormField(
                              controller: _emailController,

                              keyboardType: TextInputType.emailAddress,

                              textInputAction: TextInputAction.next,

                              textAlign: TextAlign.right,

                              style: const TextStyle(
                                color: darkTeal,
                                fontSize: 15,
                              ),

                              decoration: _fieldDecoration(
                                hintText: 'اسم المستخدم أو البريد الإلكتروني',
                                suffixIcon: Icons.email_outlined,
                              ),

                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'الرجاء إدخال البريد الإلكتروني';
                                }

                                return null;
                              },
                            ),
                          ),

                          const SizedBox(height: 14),

                          // =========================
                          // PASSWORD
                          // =========================
                          _buildFieldShadow(
                            child: TextFormField(
                              controller: _passwordController,

                              obscureText: _hidePassword,

                              textInputAction: TextInputAction.done,

                              textAlign: TextAlign.right,

                              style: const TextStyle(
                                color: darkTeal,
                                fontSize: 15,
                              ),

                              decoration: InputDecoration(
                                hintText: 'كلمة المرور',

                                hintStyle: const TextStyle(
                                  color: fieldText,
                                  fontSize: 14,
                                ),

                                filled: true,

                                fillColor: Colors.white.withValues(alpha: 0.94),

                                // العين
                                prefixIcon: IconButton(
                                  onPressed: () {
                                    setState(() {
                                      _hidePassword = !_hidePassword;
                                    });
                                  },

                                  icon: Icon(
                                    _hidePassword
                                        ? Icons.visibility_outlined
                                        : Icons.visibility_off_outlined,

                                    color: darkTeal,
                                    size: 23,
                                  ),
                                ),

                                // القفل
                                suffixIcon: const Icon(
                                  Icons.lock_outline,
                                  color: darkTeal,
                                  size: 22,
                                ),

                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 18,
                                  vertical: 18,
                                ),

                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: BorderSide.none,
                                ),

                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: BorderSide.none,
                                ),

                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),

                                  borderSide: const BorderSide(
                                    color: buttonTeal,
                                    width: 1.4,
                                  ),
                                ),

                                errorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),

                                  borderSide: const BorderSide(
                                    color: Colors.redAccent,
                                    width: 1,
                                  ),
                                ),

                                focusedErrorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),

                                  borderSide: const BorderSide(
                                    color: Colors.redAccent,
                                    width: 1.2,
                                  ),
                                ),
                              ),

                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'الرجاء إدخال كلمة المرور';
                                }

                                return null;
                              },

                              onFieldSubmitted: (_) {
                                _login();
                              },
                            ),
                          ),

                          const SizedBox(height: 20),

                          // =========================
                          // LOGIN BUTTON
                          // =========================
                          SizedBox(
                            width: double.infinity,
                            height: 56,

                            child: ElevatedButton(
                              onPressed: _loading ? null : _login,

                              style: ElevatedButton.styleFrom(
                                backgroundColor: buttonTeal,

                                foregroundColor: Colors.white,

                                elevation: 0,

                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),

                              child: _loading
                                  ? const SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Text(
                                      'تسجيل الدخول',

                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                            ),
                          ),

                          const SizedBox(height: 17),

                          // =========================
                          // REGISTER
                          // =========================
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,

                            children: [
                              const Text(
                                'ليس لديك حساب؟',

                                style: TextStyle(
                                  color: Color(0xFF536568),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),

                              TextButton(
                                onPressed: _openRegister,

                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 5,
                                  ),

                                  minimumSize: Size.zero,

                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),

                                child: const Text(
                                  'إنشاء حساب',

                                  style: TextStyle(
                                    color: accentTeal,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          // =========================
                          // QUOTE
                          // مباشرة تحت إنشاء حساب
                          // =========================
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // FIELD DECORATION
  // ==========================================
  InputDecoration _fieldDecoration({
    required String hintText,
    required IconData suffixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,

      hintStyle: const TextStyle(color: fieldText, fontSize: 14),

      filled: true,

      fillColor: Colors.white.withValues(alpha: 0.94),

      suffixIcon: Icon(suffixIcon, color: darkTeal, size: 22),

      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),

      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),

      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),

      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),

        borderSide: const BorderSide(color: buttonTeal, width: 1.4),
      ),

      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),

        borderSide: const BorderSide(color: Colors.redAccent, width: 1),
      ),

      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),

        borderSide: const BorderSide(color: Colors.redAccent, width: 1.2),
      ),
    );
  }

  // ==========================================
  // LIGHT SHADOW
  // ==========================================
  Widget _buildFieldShadow({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.055),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),

      child: child,
    );
  }
}
