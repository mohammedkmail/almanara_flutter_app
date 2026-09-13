import 'package:flutter/material.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() =>
      _RegisterScreenState();
}

class _RegisterScreenState
    extends State<RegisterScreen> {

  final GlobalKey<FormState> _formKey =
  GlobalKey<FormState>();

  final TextEditingController _nameController =
  TextEditingController();

  final TextEditingController _emailController =
  TextEditingController();

  final TextEditingController _passwordController =
  TextEditingController();

  final TextEditingController
  _confirmPasswordController =
  TextEditingController();

  bool _hidePassword = true;
  bool _hideConfirmPassword = true;

  static const Color darkTeal =
  Color(0xFF003F42);

  static const Color buttonTeal =
  Color(0xFF137A78);

  static const Color accentTeal =
  Color(0xFF0F777B);

  static const Color mutedText =
  Color(0xFF667678);

  static const Color fieldText =
  Color(0xFF778488);

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();

    super.dispose();
  }

  void _register() {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight =
        MediaQuery.of(context).size.height;

    return Directionality(
      textDirection: TextDirection.rtl,

      child: Scaffold(
        resizeToAvoidBottomInset: true,

        body: Stack(
          children: [

            // =========================
            // BACKGROUND IMAGE
            // =========================
            Positioned.fill(
              child: Image.asset(
                'assets/images/reg_img.png',
                fit: BoxFit.cover,
              ),
            ),

            // =========================
            // CONTENT
            // =========================
            SafeArea(
              child: SingleChildScrollView(
                keyboardDismissBehavior:
                ScrollViewKeyboardDismissBehavior
                    .onDrag,

                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight:
                    screenHeight -
                        MediaQuery.of(context)
                            .padding
                            .top,
                  ),

                  child: Padding(
                    padding:
                    const EdgeInsets.symmetric(
                      horizontal: 30,
                    ),

                    child: Form(
                      key: _formKey,

                      child: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment
                            .stretch,

                        children: [

                          // =====================
                          // BACK BUTTON
                          // =====================
                          Align(
                            alignment:
                            Alignment.centerLeft,

                            child: IconButton(
                              onPressed: () {
                                Navigator.pop(
                                  context,
                                );
                              },

                              icon: const Icon(
                                Icons.arrow_back,
                                size: 30,
                                color: darkTeal,
                              ),
                            ),
                          ),

                          SizedBox(
                            height:
                            screenHeight * 0.16,
                          ),

                          // =====================
                          // TITLE
                          // =====================
                          const Text(
                            'إنشاء حساب',

                            textAlign:
                            TextAlign.center,

                            style: TextStyle(
                              color: darkTeal,
                              fontSize: 29,
                              fontWeight:
                              FontWeight.w800,
                            ),
                          ),

                          const SizedBox(height: 6),

                          const Text(
                            'ابدأ رحلتك في عالم المعرفة',

                            textAlign:
                            TextAlign.center,

                            style: TextStyle(
                              color: mutedText,
                              fontSize: 15,
                              fontWeight:
                              FontWeight.w500,
                            ),
                          ),

                          const SizedBox(height: 26),

                          // =====================
                          // NAME
                          // =====================
                          _fieldShadow(
                            child: TextFormField(
                              controller:
                              _nameController,

                              textInputAction:
                              TextInputAction
                                  .next,

                              style:
                              const TextStyle(
                                color: darkTeal,
                                fontSize: 15,
                              ),

                              decoration:
                              _fieldDecoration(
                                hintText:
                                'الاسم الكامل',

                                suffixIcon:
                                Icons
                                    .person_outline,
                              ),

                              validator: (value) {
                                if (value == null ||
                                    value
                                        .trim()
                                        .isEmpty) {
                                  return 'الرجاء إدخال الاسم الكامل';
                                }

                                if (value
                                    .trim()
                                    .length <
                                    3) {
                                  return 'الاسم قصير جداً';
                                }

                                return null;
                              },
                            ),
                          ),

                          const SizedBox(height: 14),

                          // =====================
                          // EMAIL
                          // =====================
                          _fieldShadow(
                            child: TextFormField(
                              controller:
                              _emailController,

                              keyboardType:
                              TextInputType
                                  .emailAddress,

                              textInputAction:
                              TextInputAction
                                  .next,

                              style:
                              const TextStyle(
                                color: darkTeal,
                                fontSize: 15,
                              ),

                              decoration:
                              _fieldDecoration(
                                hintText:
                                'البريد الإلكتروني',

                                suffixIcon:
                                Icons
                                    .email_outlined,
                              ),

                              validator: (value) {
                                if (value == null ||
                                    value
                                        .trim()
                                        .isEmpty) {
                                  return 'الرجاء إدخال البريد الإلكتروني';
                                }

                                if (!value
                                    .contains('@')) {
                                  return 'البريد الإلكتروني غير صحيح';
                                }

                                return null;
                              },
                            ),
                          ),

                          const SizedBox(height: 14),

                          // =====================
                          // PASSWORD
                          // =====================
                          _fieldShadow(
                            child: TextFormField(
                              controller:
                              _passwordController,

                              obscureText:
                              _hidePassword,

                              textInputAction:
                              TextInputAction
                                  .next,

                              style:
                              const TextStyle(
                                color: darkTeal,
                                fontSize: 15,
                              ),

                              decoration:
                              _passwordDecoration(
                                hintText:
                                'كلمة المرور',

                                hidden:
                                _hidePassword,

                                onPressed: () {
                                  setState(() {
                                    _hidePassword =
                                    !_hidePassword;
                                  });
                                },
                              ),

                              validator: (value) {
                                if (value == null ||
                                    value.isEmpty) {
                                  return 'الرجاء إدخال كلمة المرور';
                                }

                                if (value.length < 6) {
                                  return 'كلمة المرور يجب أن تكون 6 أحرف على الأقل';
                                }

                                return null;
                              },
                            ),
                          ),

                          const SizedBox(height: 14),

                          // =====================
                          // CONFIRM PASSWORD
                          // =====================
                          _fieldShadow(
                            child: TextFormField(
                              controller:
                              _confirmPasswordController,

                              obscureText:
                              _hideConfirmPassword,

                              textInputAction:
                              TextInputAction
                                  .done,

                              style:
                              const TextStyle(
                                color: darkTeal,
                                fontSize: 15,
                              ),

                              decoration:
                              _passwordDecoration(
                                hintText:
                                'تأكيد كلمة المرور',

                                hidden:
                                _hideConfirmPassword,

                                onPressed: () {
                                  setState(() {
                                    _hideConfirmPassword =
                                    !_hideConfirmPassword;
                                  });
                                },
                              ),

                              validator: (value) {
                                if (value == null ||
                                    value.isEmpty) {
                                  return 'الرجاء تأكيد كلمة المرور';
                                }

                                if (value !=
                                    _passwordController
                                        .text) {
                                  return 'كلمتا المرور غير متطابقتين';
                                }

                                return null;
                              },

                              onFieldSubmitted:
                                  (_) {
                                _register();
                              },
                            ),
                          ),

                          const SizedBox(height: 20),

                          // =====================
                          // REGISTER BUTTON
                          // =====================
                          SizedBox(
                            height: 56,

                            child: ElevatedButton(
                              onPressed:
                              _register,

                              style:
                              ElevatedButton
                                  .styleFrom(
                                backgroundColor:
                                buttonTeal,

                                foregroundColor:
                                Colors.white,

                                elevation: 0,

                                shape:
                                RoundedRectangleBorder(
                                  borderRadius:
                                  BorderRadius
                                      .circular(
                                    14,
                                  ),
                                ),
                              ),

                              child: const Text(
                                'إنشاء حساب',

                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight:
                                  FontWeight
                                      .w700,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 17),

                          // =====================
                          // LOGIN LINK
                          // =====================
                          Row(
                            mainAxisAlignment:
                            MainAxisAlignment
                                .center,

                            children: [
                              const Text(
                                'لديك حساب بالفعل؟',

                                style:
                                TextStyle(
                                  color:
                                  mutedText,
                                  fontSize: 14,
                                  fontWeight:
                                  FontWeight
                                      .w500,
                                ),
                              ),

                              TextButton(
                                onPressed: () {
                                  Navigator.pop(
                                    context,
                                  );
                                },

                                style:
                                TextButton
                                    .styleFrom(
                                  padding:
                                  const EdgeInsets
                                      .symmetric(
                                    horizontal: 5,
                                  ),

                                  minimumSize:
                                  Size.zero,

                                  tapTargetSize:
                                  MaterialTapTargetSize
                                      .shrinkWrap,
                                ),

                                child:
                                const Text(
                                  'تسجيل الدخول',

                                  style:
                                  TextStyle(
                                    color:
                                    accentTeal,
                                    fontSize: 14,
                                    fontWeight:
                                    FontWeight
                                        .w800,
                                  ),
                                ),
                              ),
                            ],
                          ),



                          const SizedBox(height: 28),
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
  // NORMAL FIELD
  // ==========================================
  InputDecoration _fieldDecoration({
    required String hintText,
    required IconData suffixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,

      hintStyle: const TextStyle(
        color: fieldText,
        fontSize: 14,
      ),

      filled: true,

      fillColor:
      Colors.white.withValues(
        alpha: 0.94,
      ),

      suffixIcon: Icon(
        suffixIcon,
        color: darkTeal,
        size: 22,
      ),

      contentPadding:
      const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 18,
      ),

      border: OutlineInputBorder(
        borderRadius:
        BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),

      enabledBorder:
      OutlineInputBorder(
        borderRadius:
        BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),

      focusedBorder:
      OutlineInputBorder(
        borderRadius:
        BorderRadius.circular(14),

        borderSide:
        const BorderSide(
          color: buttonTeal,
          width: 1.4,
        ),
      ),

      errorBorder:
      OutlineInputBorder(
        borderRadius:
        BorderRadius.circular(14),

        borderSide:
        const BorderSide(
          color: Colors.redAccent,
          width: 1,
        ),
      ),

      focusedErrorBorder:
      OutlineInputBorder(
        borderRadius:
        BorderRadius.circular(14),

        borderSide:
        const BorderSide(
          color: Colors.redAccent,
          width: 1.2,
        ),
      ),
    );
  }

  // ==========================================
  // PASSWORD FIELD
  // ==========================================
  InputDecoration _passwordDecoration({
    required String hintText,
    required bool hidden,
    required VoidCallback onPressed,
  }) {
    return InputDecoration(
      hintText: hintText,

      hintStyle: const TextStyle(
        color: fieldText,
        fontSize: 14,
      ),

      filled: true,

      fillColor:
      Colors.white.withValues(
        alpha: 0.94,
      ),

      prefixIcon: IconButton(
        onPressed: onPressed,

        icon: Icon(
          hidden
              ? Icons.visibility_outlined
              : Icons.visibility_off_outlined,

          color: darkTeal,
          size: 22,
        ),
      ),

      suffixIcon: const Icon(
        Icons.lock_outline,
        color: darkTeal,
        size: 22,
      ),

      contentPadding:
      const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 18,
      ),

      border: OutlineInputBorder(
        borderRadius:
        BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),

      enabledBorder:
      OutlineInputBorder(
        borderRadius:
        BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),

      focusedBorder:
      OutlineInputBorder(
        borderRadius:
        BorderRadius.circular(14),

        borderSide:
        const BorderSide(
          color: buttonTeal,
          width: 1.4,
        ),
      ),

      errorBorder:
      OutlineInputBorder(
        borderRadius:
        BorderRadius.circular(14),

        borderSide:
        const BorderSide(
          color: Colors.redAccent,
          width: 1,
        ),
      ),

      focusedErrorBorder:
      OutlineInputBorder(
        borderRadius:
        BorderRadius.circular(14),

        borderSide:
        const BorderSide(
          color: Colors.redAccent,
          width: 1.2,
        ),
      ),
    );
  }

  // ==========================================
  // FIELD SHADOW
  // ==========================================
  Widget _fieldShadow({
    required Widget child,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius:
        BorderRadius.circular(14),

        boxShadow: [
          BoxShadow(
            color:
            Colors.black.withValues(
              alpha: 0.055,
            ),

            blurRadius: 12,

            offset:
            const Offset(0, 4),
          ),
        ],
      ),

      child: child,
    );
  }
}