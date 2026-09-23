import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/services/analytics_service.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../shared/providers/auth_provider.dart';
import '../../../../shared/widgets/custom_text_field.dart';
import '../../../../shared/widgets/gradient_background.dart';
import '../../../../shared/widgets/gradient_button.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  bool _loading = false;
  bool _obscure = true;
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await ref
          .read(authServiceProvider)
          .signInWithEmail(email: _email.text, password: _password.text);
      await AnalyticsService.instance.logLogin('password');
      // Router redirect handles navigation.
    } on FirebaseAuthException catch (e) {
      setState(() => _error = e.message ?? 'Sign-in failed');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.xxl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                const SizedBox(height: AppSizes.huge),
                Text('Welcome back', style: context.text.displayMedium)
                    .animate()
                    .fadeIn()
                    .slideY(begin: 0.1, end: 0),
                const SizedBox(height: AppSizes.xs),
                Text(
                  'Sign in to continue',
                  style: context.text.bodyLarge?.copyWith(
                    color: context.isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary,
                  ),
                ).animate().fadeIn(delay: 100.ms),
                const SizedBox(height: AppSizes.huge),

                CustomTextField(
                  hint: 'Email',
                  controller: _email,
                  icon: Icons.mail_outline_rounded,
                  keyboardType: TextInputType.emailAddress,
                ).animate().fadeIn(delay: 150.ms).slideY(begin: 0.1, end: 0),
                const SizedBox(height: AppSizes.md),

                CustomTextField(
                  hint: 'Password',
                  controller: _password,
                  icon: Icons.lock_outline_rounded,
                  obscure: _obscure,
                  suffix: IconButton(
                    icon: Icon(_obscure
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined),
                    onPressed: () =>
                        setState(() => _obscure = !_obscure),
                  ),
                ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1, end: 0),

                if (_error != null) ...<Widget>[
                  const SizedBox(height: AppSizes.md),
                  Text(
                    _error!,
                    style: context.text.bodyMedium?.copyWith(
                      color: AppColors.danger,
                    ),
                  ),
                ],

                const SizedBox(height: AppSizes.xl),
                GradientButton(
                  label: _loading ? 'Signing in…' : 'Sign in',
                  onPressed: _loading ? null : _signIn,
                ).animate().fadeIn(delay: 300.ms),

                const SizedBox(height: AppSizes.lg),
                TextButton(
                  onPressed: () async {
                    try {
                      await ref
                          .read(authServiceProvider)
                          .sendPasswordReset(_email.text);
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Reset email sent'),
                        ),
                      );
                    } catch (_) {}
                  },
                  child: const Text('Forgot password?'),
                ),

                const SizedBox(height: AppSizes.huge),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text('New here?', style: context.text.bodyMedium),
                    TextButton(
                      onPressed: () => context.go(RouteNames.signup),
                      child: const Text('Create account'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
