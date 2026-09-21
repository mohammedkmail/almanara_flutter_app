import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import '../widgets/api_error_view.dart';
import 'navigation_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();

  bool _hidePassword = true;
  bool _hideConfirm = true;
  bool _loading = false;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_loading || !_formKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus();
    setState(() => _loading = true);

    try {
      await AuthService.instance.register(
        username: _email.text.trim().toLowerCase(),
        fullName: _name.text.trim(),
        password: _password.text,
      );

      if (!mounted) return;
      final account = AuthService.instance.user.value;
      if (account == null) {
        throw StateError('لم يتم إنشاء جلسة المستخدم بعد التسجيل.');
      }

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => MainScreen(role: account.role)),
        (_) => false,
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(apiErrorMessage(error))));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppTheme.cream,
        body: LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth >= 850;
            if (wide) {
              return Row(
                children: [
                  Expanded(
                    flex: 5,
                    child: _RegisterVisual(
                      onBack: () => Navigator.maybePop(context),
                    ),
                  ),
                  Expanded(
                    flex: 6,
                    child: _RegisterForm(
                      formKey: _formKey,
                      name: _name,
                      email: _email,
                      password: _password,
                      confirm: _confirm,
                      hidePassword: _hidePassword,
                      hideConfirm: _hideConfirm,
                      loading: _loading,
                      showBack: false,
                      onBack: () => Navigator.maybePop(context),
                      onTogglePassword: () =>
                          setState(() => _hidePassword = !_hidePassword),
                      onToggleConfirm: () =>
                          setState(() => _hideConfirm = !_hideConfirm),
                      onSubmit: _submit,
                    ),
                  ),
                ],
              );
            }

            return SafeArea(
              child: SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.fromLTRB(18, 12, 18, 30),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 520),
                    child: Column(
                      children: [
                        _MobileRegisterVisual(
                          onBack: () => Navigator.maybePop(context),
                        ),
                        Transform.translate(
                          offset: const Offset(0, -26),
                          child: _RegisterForm(
                            formKey: _formKey,
                            name: _name,
                            email: _email,
                            password: _password,
                            confirm: _confirm,
                            hidePassword: _hidePassword,
                            hideConfirm: _hideConfirm,
                            loading: _loading,
                            showBack: false,
                            onBack: () => Navigator.maybePop(context),
                            onTogglePassword: () =>
                                setState(() => _hidePassword = !_hidePassword),
                            onToggleConfirm: () =>
                                setState(() => _hideConfirm = !_hideConfirm),
                            onSubmit: _submit,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _RegisterVisual extends StatelessWidget {
  final VoidCallback onBack;

  const _RegisterVisual({required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(
          'assets/images/reg_img.png',
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => Container(color: AppTheme.darkTeal),
        ),
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0x4D082E2B), Color(0xE6103D39)],
            ),
          ),
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(34),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Align(
                  alignment: Alignment.centerRight,
                  child: _GlassBackButton(onTap: onBack),
                ),
                const Spacer(),
                Container(
                  width: 54,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppTheme.gold,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                const SizedBox(height: 18),
                const Text(
                  'مساحتك في المنارة\nتبدأ من هنا',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 34,
                    height: 1.25,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  'احجز كتاباً، ادخل مكتبتك الرقمية، احجز غرفة دراسة، وتابع كل عملياتك من حساب واحد.',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: .82),
                    height: 1.7,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _MobileRegisterVisual extends StatelessWidget {
  final VoidCallback onBack;

  const _MobileRegisterVisual({required this.onBack});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 250,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              'assets/images/reg_img.png',
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => Container(color: AppTheme.darkTeal),
            ),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0x22082E2B), Color(0xE8103D39)],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _GlassBackButton(onTap: onBack),
                  const Spacer(),
                  const Text(
                    'أنشئ حسابك في المنارة',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'كل خدمات المكتبة في حساب واحد.',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: .82),
                      fontSize: 12.5,
                    ),
                  ),
                  const SizedBox(height: 34),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RegisterForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController name;
  final TextEditingController email;
  final TextEditingController password;
  final TextEditingController confirm;
  final bool hidePassword;
  final bool hideConfirm;
  final bool loading;
  final bool showBack;
  final VoidCallback onBack;
  final VoidCallback onTogglePassword;
  final VoidCallback onToggleConfirm;
  final VoidCallback onSubmit;

  const _RegisterForm({
    required this.formKey,
    required this.name,
    required this.email,
    required this.password,
    required this.confirm,
    required this.hidePassword,
    required this.hideConfirm,
    required this.loading,
    required this.showBack,
    required this.onBack,
    required this.onTogglePassword,
    required this.onToggleConfirm,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: showBack ? 0 : 0),
      padding: const EdgeInsets.fromLTRB(26, 26, 26, 24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: AppTheme.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .06),
            blurRadius: 26,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (showBack)
              Align(
                alignment: Alignment.centerRight,
                child: IconButton(
                  onPressed: onBack,
                  icon: const Icon(Icons.arrow_forward_rounded),
                ),
              ),
            const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'بيانات الحساب',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          color: AppTheme.ink,
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        'أدخل بياناتك الحقيقية حتى تظهر الحجوزات والاستعارات باسمك.',
                        style: TextStyle(color: AppTheme.muted, height: 1.5),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 12),
                _AccountMark(),
              ],
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: name,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.name],
              decoration: const InputDecoration(
                labelText: 'الاسم الكامل',
                hintText: 'مثال: محمد أحمد',
                prefixIcon: Icon(Icons.person_outline_rounded),
              ),
              validator: (value) {
                final text = value?.trim() ?? '';
                if (text.length < 3) return 'أدخل الاسم الكامل.';
                return null;
              },
            ),
            const SizedBox(height: 13),
            TextFormField(
              controller: email,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.email],
              decoration: const InputDecoration(
                labelText: 'البريد الإلكتروني',
                hintText: 'name@example.com',
                prefixIcon: Icon(Icons.alternate_email_rounded),
              ),
              validator: (value) {
                final text = value?.trim() ?? '';
                final valid = RegExp(
                  r'^[^\s@]+@[^\s@]+\.[^\s@]+$',
                ).hasMatch(text);
                if (!valid) return 'أدخل بريداً إلكترونياً صحيحاً.';
                return null;
              },
            ),
            const SizedBox(height: 13),
            TextFormField(
              controller: password,
              obscureText: hidePassword,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.newPassword],
              decoration: InputDecoration(
                labelText: 'كلمة المرور',
                prefixIcon: const Icon(Icons.lock_outline_rounded),
                suffixIcon: IconButton(
                  tooltip: hidePassword
                      ? 'إظهار كلمة المرور'
                      : 'إخفاء كلمة المرور',
                  onPressed: onTogglePassword,
                  icon: Icon(
                    hidePassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                  ),
                ),
              ),
              validator: (value) {
                if ((value?.length ?? 0) < 6) return 'استخدم 6 أحرف على الأقل.';
                return null;
              },
            ),
            const SizedBox(height: 13),
            TextFormField(
              controller: confirm,
              obscureText: hideConfirm,
              textInputAction: TextInputAction.done,
              autofillHints: const [AutofillHints.newPassword],
              onFieldSubmitted: (_) => onSubmit(),
              decoration: InputDecoration(
                labelText: 'تأكيد كلمة المرور',
                prefixIcon: const Icon(Icons.lock_reset_rounded),
                suffixIcon: IconButton(
                  tooltip: hideConfirm ? 'إظهار التأكيد' : 'إخفاء التأكيد',
                  onPressed: onToggleConfirm,
                  icon: Icon(
                    hideConfirm
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                  ),
                ),
              ),
              validator: (value) {
                if (value != password.text)
                  return 'كلمتا المرور غير متطابقتين.';
                return null;
              },
            ),
            const SizedBox(height: 9),
            const Row(
              children: [
                Icon(Icons.shield_outlined, size: 16, color: AppTheme.teal),
                SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'سيتم إنشاء الحساب بصلاحية قارئ. صلاحيات الإدارة لا تُمنح من شاشة التسجيل.',
                    style: TextStyle(
                      color: AppTheme.muted,
                      fontSize: 11.5,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 22),
            SizedBox(
              height: 54,
              child: FilledButton(
                onPressed: loading ? null : onSubmit,
                child: loading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'إنشاء الحساب',
                            style: TextStyle(fontWeight: FontWeight.w900),
                          ),
                          SizedBox(width: 8),
                          Icon(Icons.arrow_back_rounded, size: 20),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: loading ? null : onBack,
              child: const Text('لدي حساب بالفعل — تسجيل الدخول'),
            ),
          ],
        ),
      ),
    );
  }
}

class _AccountMark extends StatelessWidget {
  const _AccountMark();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: const Color(0xFFE7F1EE),
        borderRadius: BorderRadius.circular(15),
      ),
      child: const Icon(Icons.person_add_alt_1_rounded, color: AppTheme.teal),
    );
  }
}

class _GlassBackButton extends StatelessWidget {
  final VoidCallback onTap;

  const _GlassBackButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: .14),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: const SizedBox(
          width: 44,
          height: 44,
          child: Icon(Icons.arrow_forward_rounded, color: Colors.white),
        ),
      ),
    );
  }
}
