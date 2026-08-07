import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/prefs.dart';
import '../../../../core/theme/app_theme.dart';
import '../providers/auth_providers.dart';

/// Login screen, matching `.login` in the prototype.
///
/// The backdrop is per-theme and is NOT the brand gradient — Aurora's login is
/// deep navy with cyan/violet radial glows:
///
/// ```css
/// .login{background:
///   radial-gradient(130% 80% at 80% 0%,  var(--loginglow1), transparent 55%),
///   radial-gradient(120% 80% at 0% 30%,  var(--loginglow2), transparent 55%),
///   var(--logingrad)}
/// ```
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
  final _password = TextEditingController(text: 'demo1234');

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
      body: _LoginBackdrop(
        child: SafeArea(
          bottom: false,
          child: LayoutBuilder(
            builder: (context, constraints) => SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Column(
                  // `.login .sheet{margin-top:auto}` pins the sheet down.
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const _LoginHead(),
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
              fontSize: 19,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Enter your company workspace to continue.',
            style: TextStyle(color: t.sub, fontSize: 12.5),
          ),
          const SizedBox(height: 18),
          _LInput(
            icon: Icons.business_outlined,
            label: 'Company',
            controller: _company,
            textInputAction: TextInputAction.next,
          ),
          _LInput(
            icon: Icons.person_outline,
            label: 'Username',
            controller: _username,
            textInputAction: TextInputAction.next,
          ),
          _LInput(
            icon: Icons.lock_outline,
            label: 'Password',
            controller: _password,
            obscure: _obscure,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _submit(),
            trailing: GestureDetector(
              onTap: () => setState(() => _obscure = !_obscure),
              behavior: HitTestBehavior.opaque,
              child: Icon(
                _obscure
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                color: t.sub,
                size: 18,
              ),
            ),
          ),
          // .login .row{font-size:12px;margin:4px 0 16px}
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 4, 0, 16),
            child: Row(
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
                          size: 17,
                          color: _remember ? t.primary : t.sub,
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            'Remember me',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: t.sub,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () {
                    ScaffoldMessenger.of(context)
                      ..hideCurrentSnackBar()
                      ..showSnackBar(
                        const SnackBar(
                          content:
                              Text('Reset link sent to your registered email.'),
                        ),
                      );
                  },
                  behavior: HitTestBehavior.opaque,
                  child: Text(
                    'Forgot password?',
                    style: TextStyle(
                      color: t.primaryDark,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          _cta(
            t,
            loading ? 'Signing in…' : 'Sign in',
            loading ? null : _submit,
          ),
          if (showBiometrics) ...[
            const SizedBox(height: 14),
            Center(
              child: GestureDetector(
                onTap: loading
                    ? null
                    : () =>
                        ref.read(authControllerProvider.notifier).biometric(),
                behavior: HitTestBehavior.opaque,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.face_retouching_natural,
                      color: t.primaryDark,
                      size: 22,
                    ),
                    const SizedBox(width: 9),
                    Text(
                      'Unlock with Face ID',
                      style: TextStyle(
                        color: t.sub,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// `.cta` — brand gradient, white 14px/800, radius 15, glow shadow.
  Widget _cta(AppTokens t, String label, VoidCallback? onTap) {
    return Opacity(
      opacity: onTap == null ? 0.75 : 1,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 15),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: t.gradient,
              stops: const [0.0, 0.55, 1.0],
            ),
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: t.shadow,
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }
}

/// Two radial glows layered over the per-theme `--logingrad`.
class _LoginBackdrop extends StatelessWidget {
  const _LoginBackdrop({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return DecoratedBox(
      // linear-gradient(170deg, a, b 70%, c)
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: const Alignment(-0.17, -1),
          end: const Alignment(0.17, 1),
          colors: t.loginGradient,
          stops: const [0.0, 0.7, 1.0],
        ),
      ),
      child: DecoratedBox(
        // at 0% 30%, extent 55%
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: const Alignment(-1, -0.4),
            radius: 1.2,
            colors: [t.loginGlow2, t.loginGlow2.withValues(alpha: 0)],
            stops: const [0.0, 0.55],
          ),
        ),
        child: DecoratedBox(
          // at 80% 0%, extent 55%
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: const Alignment(0.6, -1),
              radius: 1.3,
              colors: [t.loginGlow1, t.loginGlow1.withValues(alpha: 0)],
              stops: const [0.0, 0.55],
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}

/// `.login .lhead` — wordmark, product line, and the positioning tagline.
class _LoginHead extends StatelessWidget {
  const _LoginHead();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.fromLTRB(30, 60, 30, 0),
      child: Column(
        children: [
          Text(
            'DIGILYZR',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w800,
              letterSpacing: 3.96, // .18em
            ),
          ),
          SizedBox(height: 3),
          Text(
            'eℓway · pharma SFA',
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.6, // .05em
            ),
          ),
          SizedBox(height: 14),
          Text(
            'Field intelligence for medical reps\n& management teams.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 13,
              height: 1.5,
            ),
          ),
          SizedBox(height: 24),
        ],
      ),
    );
  }
}

/// `.linput` — canvas-filled row with a leading glyph and a stacked
/// uppercase label above the value. Deliberately not a Material TextField:
/// the prototype's label sits above the value permanently rather than
/// floating on focus.
class _LInput extends StatelessWidget {
  const _LInput({
    required this.icon,
    required this.label,
    required this.controller,
    this.obscure = false,
    this.trailing,
    this.textInputAction,
    this.onSubmitted,
  });

  final IconData icon;
  final String label;
  final TextEditingController controller;
  final bool obscure;
  final Widget? trailing;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Container(
      margin: const EdgeInsets.only(bottom: 11),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(
        color: t.canvas,
        border: Border.all(color: t.line),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: t.sub),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label.toUpperCase(),
                  style: TextStyle(
                    color: t.sub,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.4, // .04em
                  ),
                ),
                const SizedBox(height: 2),
                TextField(
                  controller: controller,
                  obscureText: obscure,
                  textInputAction: textInputAction,
                  onSubmitted: onSubmitted,
                  autocorrect: false,
                  enableSuggestions: false,
                  cursorColor: t.primary,
                  style: TextStyle(
                    color: t.ink,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                  ),
                  decoration: const InputDecoration(
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                  ),
                ),
              ],
            ),
          ),
          if (trailing != null) ...[
            const SizedBox(width: 8),
            trailing!,
          ],
        ],
      ),
    );
  }
}
