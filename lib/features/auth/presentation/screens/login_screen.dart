import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/prefs.dart';
import '../../../../core/theme/app_theme.dart';
import '../providers/auth_providers.dart';

/// Login screen — mirrors eWay_Interactive_Prototype_FINAL.html:
/// gradient backdrop, DIGILYZR wordmark, company/username/password fields,
/// primary "Sign in" and a Face ID unlock affordance.
///
/// Navigation is NOT done here: a successful sign-in publishes the session and
/// the router's guard redirects to /dashboard (see core/router/app_router.dart).
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  static const _kRememberKey = 'login_remember';
  static const _kCompanyKey = 'login_company';
  static const _kUsernameKey = 'login_username';

  late final TextEditingController _company;
  late final TextEditingController _username;
  final _password = TextEditingController();
  final _passwordFocus = FocusNode();

  bool _remember = true;
  bool _obscure = true;

  @override
  void initState() {
    super.initState();
    final prefs = ref.read(sharedPrefsProvider);
    _remember = prefs.getBool(_kRememberKey) ?? true;
    // Prefilled with the demo workspace from the prototype while we are on
    // placeholder data.
    _company = TextEditingController(
      text: _remember ? (prefs.getString(_kCompanyKey) ?? 'HILAL') : '',
    );
    _username = TextEditingController(
      text: _remember ? (prefs.getString(_kUsernameKey) ?? 'demo.support') : '',
    );
  }

  @override
  void dispose() {
    _company.dispose();
    _username.dispose();
    _password.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  Future<void> _persistRemembered() async {
    final prefs = ref.read(sharedPrefsProvider);
    await prefs.setBool(_kRememberKey, _remember);
    if (_remember) {
      await prefs.setString(_kCompanyKey, _company.text.trim());
      await prefs.setString(_kUsernameKey, _username.text.trim());
    } else {
      await prefs.remove(_kCompanyKey);
      await prefs.remove(_kUsernameKey);
    }
  }

  void _submit() {
    FocusScope.of(context).unfocus();
    _persistRemembered();
    ref.read(authControllerProvider.notifier).login(
          company: _company.text.trim(),
          username: _username.text.trim(),
          password: _password.text,
        );
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;

    ref.listen<AuthState>(authControllerProvider, (_, next) {
      if (next is AuthError) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(next.message)));
      }
    });

    final loading = ref.watch(authControllerProvider) is AuthLoading;
    final showBiometrics =
        ref.watch(biometricAvailableProvider).valueOrNull ?? false;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: t.gradient,
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: LayoutBuilder(
            builder: (context, constraints) => SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Column(
                  // Wordmark at the top, sheet flush to the bottom — the
                  // prototype's login layout.
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Column(
                      children: [
                        SizedBox(height: 46),
                        Text(
                          'DIGILYZR',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 4,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'eℓway · pharma SFA',
                          style: TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                        SizedBox(height: 18),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 32),
                          child: Text(
                            'Field intelligence for medical reps\n'
                            '& management teams.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12.5,
                              height: 1.5,
                            ),
                          ),
                        ),
                        SizedBox(height: 34),
                      ],
                    ),
                    _sheet(t, loading, showBiometrics),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _sheet(AppTokens t, bool loading, bool showBiometrics) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        24,
        26,
        24,
        30 + MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: BoxDecoration(
        color: t.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Sign in',
            style: TextStyle(
              color: t.ink,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Enter your company workspace to continue.',
            style: TextStyle(color: t.sub, fontSize: 12.5),
          ),
          const SizedBox(height: 18),
          _field(
            t,
            'Company',
            _company,
            icon: Icons.business_rounded,
            textInputAction: TextInputAction.next,
          ),
          _field(
            t,
            'Username',
            _username,
            icon: Icons.person_outline_rounded,
            textInputAction: TextInputAction.next,
          ),
          _field(
            t,
            'Password',
            _password,
            icon: Icons.lock_outline_rounded,
            obscure: _obscure,
            focusNode: _passwordFocus,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _submit(),
            suffix: IconButton(
              icon: Icon(
                _obscure
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                color: t.sub,
                size: 19,
              ),
              onPressed: () => setState(() => _obscure = !_obscure),
            ),
          ),
          const SizedBox(height: 2),
          Row(
            children: [
              Flexible(
                child: GestureDetector(
                  onTap: () => setState(() => _remember = !_remember),
                  behavior: HitTestBehavior.opaque,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _remember
                            ? Icons.check_box_rounded
                            : Icons.check_box_outline_blank_rounded,
                        size: 19,
                        color: _remember ? t.primary : t.sub,
                      ),
                      const SizedBox(width: 7),
                      Flexible(
                        child: Text(
                          'Remember me',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: t.sub,
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () {
                  ScaffoldMessenger.of(context)
                    ..hideCurrentSnackBar()
                    ..showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Password reset arrives with the real API.',
                        ),
                      ),
                    );
                },
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(0, 32),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  'Forgot password?',
                  style: TextStyle(
                    color: t.primary,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _primaryButton(
            t,
            loading ? 'Signing in…' : 'Sign in',
            loading ? null : _submit,
          ),
          if (showBiometrics) ...[
            const SizedBox(height: 12),
            Center(
              child: TextButton.icon(
                onPressed: loading
                    ? null
                    : () =>
                        ref.read(authControllerProvider.notifier).biometric(),
                icon: Icon(
                  Icons.face_retouching_natural,
                  color: t.primaryDark,
                ),
                label: Text(
                  'Unlock with Face ID',
                  style: TextStyle(color: t.sub, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _field(
    AppTokens t,
    String label,
    TextEditingController controller, {
    required IconData icon,
    bool obscure = false,
    Widget? suffix,
    FocusNode? focusNode,
    TextInputAction? textInputAction,
    ValueChanged<String>? onSubmitted,
  }) {
    OutlineInputBorder border(Color c) => OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: c),
        );

    return Padding(
      padding: const EdgeInsets.only(bottom: 11),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        obscureText: obscure,
        textInputAction: textInputAction,
        onSubmitted: onSubmitted,
        autocorrect: false,
        enableSuggestions: false,
        style: TextStyle(color: t.ink, fontWeight: FontWeight.w700),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: t.sub, fontSize: 12),
          prefixIcon: Icon(icon, color: t.sub, size: 19),
          suffixIcon: suffix,
          filled: true,
          fillColor: t.canvas,
          border: border(t.line),
          enabledBorder: border(t.line),
          focusedBorder: border(t.primary),
        ),
      ),
    );
  }

  Widget _primaryButton(AppTokens t, String label, VoidCallback? onTap) {
    return Opacity(
      opacity: onTap == null ? 0.7 : 1,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 15),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: t.gradient),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 15,
            ),
          ),
        ),
      ),
    );
  }
}
